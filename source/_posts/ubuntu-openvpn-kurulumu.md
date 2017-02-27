---
title: OpenVPN Kurulumu (Ubuntu 16.04)
tags:
  - VPN
  - OpenVPN
  - Ubuntu
  - Ubuntu 16.04
  - Ubuntu OpenVPN
  - OpenVPN Mac OS X
  - OpenVPN Windows
  - OpenVPN Linux
  - OpenVPN Android
  - OpenVPN iOS
categories:
  - Tutorial
---

![OpenVPN Server Setup Ubuntu 16.04](https://furkankarakoyunlu.com/images/ubuntu_openvpn_kurulum.jpg)

## Nedir bu VPN?
İnternete güvenli bir şekilde bağlanmak mı istiyorsunuz? Starbucks, avm yada otel WIFI'ını kullanarak güvenemeyeceğiniz ortak bir ağdan mı bağlanmak zorundasınız? Tamam, işte aradığınız şey VPN! (Kime anlatıyorum ya, güzel ülkemizde sürekli internet yasakları yüzünden el kadar çocuklar bile VPN kullanır oldu. Sevinsek mi üzülsek mi bilmiyorum.)

Bu yazımda ticari amaçlarla piyasaya sürülen VPN servisleri yerine aylık 5 dolar gibi cüzzi bir miktar ile kendinize ait bir VPN sunucusu kurmayı anlatmaya çalışacağım.

Şimdi biraz daha teknik konulara girelim. VPN, yani Virtual Private Network adından da anlaşılacağı üzere sanal özel bir ağdır. Bu ağ aracılığı ile başka bir ağa fiziksel olarak bağlıymışsınız gibi o ağ üzerinden veri alışverişlerinde bulunabilirsiniz. Az laf çok iş hadi başlayalım.

## Gerekenler
Bu yazıyı takip edebilmeniz için size gerekenler;
* Ubuntu 16.04 Sunucu
* non-root `sudo` kullanıcı
* Firewall

Eğer bu terimler size tanıdık gelmiyorsa [Ubuntu 16.04 Server Setup](https://furkankarakoyunlu.com/ubuntu-server-setup/) yazımı okuyup kendinize yeni bir sunucu hazırlayabilirsiniz. Herşey tamam ama sunucuyu nereden bulacağız diyorsanız ben [DigitalOcean](https://m.do.co/c/56e2f8751615) servislerini kullanıyorum. Saatlik 0.007 dolar (aylık 5 dolara geliyor) harcayarak 512MB RAM, 1.8 GHz CPU, 20GB SSD ve aylık 1TB trafik hakkı olan bir sunucu kiralayabiliyorsunuz. DigitalOcean kullanımını başka bir yazımda ele alacağım. Bence gayet uygun. Eğer isterseniz başka servisler de var tabii; amazon aws, rackspace, vultr, ... Seçim size kalmış.

## OpenVPN Kurulumu
Ubuntu'nun varsayılan repository'lerinde OpenVPN halihazırda bulunmakta. Kurmak için `apt` kullanabilirsiniz. OpenVPN'e ek olarak `easy-rsa` pakedini de yükleyelim ki VPN'imiz için dahili CA (certificate authority) kurmamızda yardımcı olsun.

Önce sunucumuzdaki paket dizinini güncelleyelim
```
$ sudo apt-get update && sudo apt-get -y upgrade
```
şimdi gerekli paketleri yükleyebiliriz
```
$ sudo apt-get install openvpn easy-rsa
```

## CA Dizini
OpenVPN, anahtar değişimi için SSL/TLS kullanan özel bir güvenlik protokolüne sahiptir. Yani sunucu ve istemciler arasındaki trafiği şifrelemek için sertifikalar kullanır. Bu güvenlik sertifikalarını çıkartabilmek için kendi CA'mızı kurmamız gerekecek.

Öncelikle sertifikalarımız için ev dizinimizin içine `easy-rsa` şablonunu kullanarak bir sertifika dizini oluşturalım.
```
$ make-cadir ~/openvpn-CA
```

## CA Değişkenlerinin Ayarlanması
Az önce oluşturduğumuz dizinin içine girelim.
```
$ cd ~/openvpn-CA
```
CA'mızın kullanacağı değerleri ayarlamak için `vars` dosyasını düzenlememiz gerekecek. Bu dosyayı açalım:
```
$ vi vars
```
Burada sertifikalarımızın nasıl oluşturulacağı ile ilgili bazı değişkenler bulunuyor. Bizim işimize yarayacak olan kısım dosyanın sonuna doğru bakacak olursak şu kısım:
```
...
# These are the default values for fields
# which will be placed in the certificate.
# Don't leave any of these fields blank.
export KEY_COUNTRY="US"
export KEY_PROVINCE="CA"
export KEY_CITY="SanFrancisco"
export KEY_ORG="Fort-Funston"
export KEY_EMAIL="me@myhost.mydomain"
export KEY_OU="MyOrganizationalUnit"
...
```
Bu değerleri uygun şekilde değiştirelim:
```
...
export KEY_COUNTRY="NL"
export KEY_PROVINCE="AMS"
export KEY_CITY="Amsterdam"
export KEY_ORG="Lahmacun LTD STI"
export KEY_EMAIL="furkankarakoyunlu@gmail.com"
export KEY_OU="N/A"
...
```
Buraya yazdığımız bilgiler sertifikamızda kullanılacak. Bunlara ek olarak `KEY_NAME` kısmını da değiştirmemiz lazım. Ben `kebap` olarak değiştireceğim.
```
export KEY_NAME="kebap"
```
Gereken yerleri değiştirdikten sonra dosyayı kaydedip çıkabilirsiniz.

## Sertifika Otoritesini Oluşturmak (CA)
Bu adımda az önce ayarladığımız `vars` dosyasını `easy-rsa` ile kullanarak CA'mızı oluşturmak için kullanacağız.

Oluşturduğumuz `openvpn-CA` klasörünün içindeyken aşağıdaki komutları girelim:
```
$ source vars
```
Bu komut şu şekilde bir çıktı verecektir:
```
NOTE: If you run ./clean-all, I will be doing a rm -rf on /home/spootrick/openvpn-CA/keys
```

Temiz bir ortamda çalıştığımızdan emin olmak için şunu yazalım:
```
$ ./clean-all
```
Şimdi aşağıdaki komutu yazarak kök CA (root CA)'mızı oluşturabiliriz.
```
$ ./build-ca
```
Bu komut, kök CA (root CA) için sertifika ve anahtar oluşturma işlemini başlatacak. Komut ekranında size aşağıdaki gibi bazı seçimler soracak. Biz daha önceden `vars` dosyasında bu değişiklikleri yaptığımız için seçimleri `ENTER` tuşuyla onaylayıp geçebilirsiniz.
```
Generating a 2048 bit RSA private key
..............................................+++
....................................................................................................................................................................................................+++
writing new private key to 'ca.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [NL]:
State or Province Name (full name) [AMS]:
Locality Name (eg, city) [Amsterdam]:
Organization Name (eg, company) [Lahmacun LTD STI]:
Organizational Unit Name (eg, section) [N/A]:
Common Name (eg, your name or your server's hostname) [Lahmacun LTD STI CA]:
Name [kebap]:
Email Address [furkankarakoyunlu@gmail.com]:
```
Bu aşamadan sonra gerekli diğer dosyaları oluşturmak için kullanacağımız CA'mızı oluşturmuş olduk.

## Sunucu Sertifikası, Anahtar ve Şifreleme Dosyalarını Oluşturmak
Bu adımda sunucu sertifikamızı, anahtar çiftlerimizi ve şifreleme işlemi sırasında kullanılacak diğer dosyaları oluşturacağız.

OpenVPN sunucu sertifikası ve anahtar çiftimizi oluşturmakla başlayalım.
```
$ ./build-key-server kebap
```
Not: Eğer buradakinden farklı bir sunucu ismi seçtiyseniz bazı kısımları ayarlamanız gerekecek. Örneğin, oluşturduğumuz dosyaları `/etc/openvpn` dizinine kopyalarken koyduğunuz ismi ayarlamanız gerekecek. Aynı zamanda `/etc/openvpn/kebap.conf` dosyasını da geçerli `.crt` ve `.key` dosyalarına hedef göstermeniz gerekecek.

Bu komutla birlikte bir sefer daha oluşturduğumuz sunucumuza göre (kebap) seçimlerimizi soracak. Varsayılan değerleri değiştirmeden `ENTER` tuşu ile geçebilirsiniz. Herhangi bir `challenge password` değeri girmeyin. Son olarak iki soruyu da `y` ile işaretleyerek sertifikamızı imzalayıp tamamlıyoruz. Çıktı şu şekilde olacak:
```
Generating a 2048 bit RSA private key
.....................+++
..........................................................................................+++
writing new private key to 'server.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [NL]:
State or Province Name (full name) [AMS]:
Locality Name (eg, city) [Amsterdam]:
Organization Name (eg, company) [Lahmacun LTD STI]:
Organizational Unit Name (eg, section) [N/A]:
Common Name (eg, your name or your server's hostname) [kebap]:
Name [kebap]:
Email Address [furkankarakoyunlu@gmail.com]:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
Using configuration from /home/spootrick/openvpn-CA/openssl-1.0.0.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
countryName           :PRINTABLE:'NL'
stateOrProvinceName   :PRINTABLE:'AMS'
localityName          :PRINTABLE:'Amsterdam'
organizationName      :PRINTABLE:'Lahmacun LTD STI'
organizationalUnitName:PRINTABLE:'N/A'
commonName            :PRINTABLE:'kebap'
name                  :PRINTABLE:'kebap'
emailAddress          :IA5STRING:'furkankarakoyunlu@gmail.com'
Certificate is to be certified until Feb  3 15:28:52 2027 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```
Ardından, anahtar değişimi sırasında kullanmak üzere güçlü bir Diffie-Hellman anahtarları oluşturacağız. Şu şekilde:
```
$ ./build-dh
```
Bu işlemin tamamlanması kullandığınız sunucunun gücüne bağlı olarak biraz zaman alabilir.

Sonrasında sunucumuzun TLS bütünlük doğrulama kapasitesini güçlendirmek için HMAC (Hash-based message authentication code) imzası üreteceğiz.
```
$ openvpn --genkey --secret keys/ta.key
```

## İstemci Sertifikası ve Anahtar Çifti Oluşturma
Şimdi sırada istemci serfitikası ve anahtar çifti oluşturma işlemleri var. Bu işlemleri istemci makinada yapıp daha sonra güvenlik amacıyla sunucu üzerinde imzalayabiliriz. Fakat anlatımın karışmaması için sunucu üzerinde oluşturup devam edeceğim.

Bu adımda bir tane istemci için anahtar/sertifika oluşturacağım. Eğer birden fazla istemcinin VPN sunucumuza bağlanmasını istiyorsanız bu adımları istediğiniz kadar tekrar edebilirsiniz. Her istemci için farklı bir değer kullanmayı unutma!

İlk istemcimizin adı `spootrickLaptop` olsun.
```
$ cd ~/openvpn-CA
$ source vars
$ ./build-key spootrickLaptop
```
build komutunu bu şekilde kullandığımızda bağlantılar için şifre istemeyecek ve istemcimiz otomatik olarak VPN servisimize bağlanacaktır.

Eğer şifreli bağlantılar oluşturmak istersek komutları şu şekilde girmemiz gerekir:
```
$ cd ~/openvpn-CA
$ source vars
$ ./build-key-pass spootrickLaptop
```
yine karşımıza gelen varsayılan değerleri değiştirmeden hepsini `ENTER` ile geçebiliriz. Challenge password değerini boş bırakın! Son iki soruyu da `y` ile işaretleyerek sertifikamızı imzalayıp tamamlamış olduk.

## OpenVPN Hizmetini Yapılandırma
Oluşturduğumuz kimlik bilgilerini ve dosyaları kullanrak OpenVPN hizmetimizi yapılandırmaya başlayabiliriz.

### Dosyaları OpenVPN Dizinine Kopyalama
Bu adımda ihtiyacımız olan dosyaları `/etc/openvpn` yapılandırma dizinine kopyalayacağız.

Bundan önceki adımlarda oluşturmuş olduğumuz dosyaları kopyalamamız gerekiyor. Bu dosyalar `~/openvpn-CA/keys` dizininde. Kopyalamamız gereken dosyalar şunlar:
* `ca.crt`      (CA sertifikası)
* `ca.key`      (CA anahtarı)
* `kebap.crt`   (sunucumuzun sertifikası)
* `kebap.key`   (sunucumuzun anahtarı)
* `ta.key`      (HMAC imzası)
* `dh2048.pem`  (Diffie-Hellman dosyamız)

Bunun için şu komutu girelim:
```
$ sudo cp ~/openvpn-CA/keys/{ca.crt,ca.key,kebap.crt,kebap.key,ta.key,dh2048.pem} /etc/openvpn
```
Dosyaların kopyalandığını şu komutla kontrol edebilirsiniz:
```
$ ls /etc/openvpn
```
Kopyaladığınız dosyaları göreceksiniz.

Şimdi OpenVPN örnek ayar dosyasını zipten çıkarıp ayar yapacağımız dizine kopyalayalım. Bu şekilde kurulumumuzda temel olarak bu dosyayı kullanmış olacağız.
```
$ gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/kebap.conf
```
Dosyamızın kopyalandığını doğrulayalım:
```
$ ls /etc/openvpn | grep kebap.conf
```
dosyayı görüyorsanız işlem tamam.

### OpenVPN Ayarlarının Yapılması
Kopyaladığımız dosyaları düzenleyelim.
```
$ sudo vi /etc/openvpn/kebap.conf
```
İlk olarak HMAC ayarlarını bulalım. Bunun için `tls-auth` kısmına bakın. Aşağıdaki satırı bulun
```
...
;tls-auth ta.key 0 # This file is secret
...
```
Satır başındaki `;` işaretini silin ve hemen altına `key-direction 0` satırını ekleyin. Şu şekilde gözükecek:
```
...
tls-auth ta.key 0 # This file is secret
key-direction 0
...
```
Sonra cryptographic cipher bölümünden `AES-128-CBC` kısmını aktfileştirelim. `AES-128-CBC` ileri düzey bir şifreleme sunuyor. Bunun için satır başındaki `;` işaretini kaldırmamız lazım.
```
...
;cipher BF-CBC        # Blowfish (default)
cipher AES-128-CBC   # AES
;cipher DES-EDE3-CBC  # Triple-DES
...
```
Bu kısmın hemen altına HMAC özeti algoritması seçmek için `auth` yetkilendirme satırını ekleyelim. Bunun için `SHA256` iyi bir seçim olacaktır.
```
...
auth SHA256
...
```
Şimdi `user` ve `group` bölümünü bulup başlarındaki `;` işaretlerini kaldıralım. Bu OpenVPN daemon (arkaplan işlemi) nin yetkilerini kısıtlar
```
...
user nobody
group nogroup
...
```
Son olarak sunucumuzun sertifikalarını belirtelim.
```
...
ca ca.crt
cert kebap.crt
key kebap.key  # This file should be kept secret
...
```
Bütün değişiklikleri tamamladıktan sonra dosyamızı kaydedip kapatabiliriz.

### Tüm Trafiğin Yönlendirilmesi
Şu ana kadar yaptığımız bütün ayarlar kullandığımız cihaz ve VPN sunucumuz arasındaki bağlantıyı sağlamak içindi. Bu yazıdaki amacımız trafiğimizi VPN sunucumuza yönlendirmek olduğu için `/etc/openvpn/kebap.conf` dosyamızda bir kaç ayar daha yapmamız gerekiyor.

Tüm trafiğimizi VPN'e yönlendirmek için DNS ayarlarını istemci bilgisayarımıza iletmemiz gerekiyor.

Bunun için `kebap.conf` dosyasında bazı satırların yorum sembolünü kaldırarak yapabiliriz.

Öncelikle dosyamızı açalım:
```
$ sudo vi /etc/openvpn/kebap.conf
```
Dosyada `redirect-gateway` adlı kısmı bulalım ve `push "redirect-gateway def1 bypass-dhcp"` satırının başındaki `;` işaretini silelim.
```
...

# If enabled, this directive will configure
# all clients to redirect their default
# network gateway through the VPN, causing
# all IP traffic such as web browsing and
# and DNS lookups to go through the VPN
# (The OpenVPN server machine may need to NAT
# or bridge the TUN/TAP interface to the internet
# in order for this to work properly).

push "redirect-gateway def1 bypass-dhcp"

...
```
Hemen altındaki `dhcp-option` kısmındaki 2 satırın da yorum işaretlerini silelim:
```
...

# Certain Windows-specific network settings
# can be pushed to clients, such as DNS
# or WINS server addresses.  CAVEAT:
# http://openvpn.net/faq.html#dhcpcaveats
# The addresses below refer to the public
# DNS servers provided by opendns.com.

push "dhcp-option DNS 208.67.222.222"
push "dhcp-option DNS 208.67.220.220"

...
```
Bu ayarlamalar istemci bilgisayarda VPN servisimizi varsayılan ağ geçidi olarak kullanmak için DNS ayarlarını yeniden yapılandırmada yardımcı olacaktır.

## Sunucu Ağ Yapılandırması
OpenVPN'in trafiği doğru bir şekilde yönlendirmesi için birkaç ayar yapmamız lazım.

Bunun için `/etc/sysctl.conf` dosyamızı açalım:
```
$ sudo vi /etc/sysctl.conf
```
Dosyanın içinde `net.ipv4.ip_forward` kısmını bulup başındaki `#` işaretini kaldıralım.
```
...
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
...
```
Dosyamızı kaydedip kapatalım.

Ardından değişikliklerin geçerli olması için şunu yazın:
```
$ sudo sysctl -p
```

## Firewall Ayarlarının Yapılması
Eğer sunucunuzda bir firewall aktifse -ki umuyorum aktiftir :)- VPN servisimiz için ayarlamamız gerekiyor. Bunun için `/etc/ufw/before.rules` dosyasında değişiklikler yapacağız. Dosyamızı açalım:
```
$ sudo vi /etc/ufw/before.rules
```
Bu dosya ufw kuralları yüklenmeden önce uygulanması gereken yapılandırma ayarlarını içerir.

Dosyanın içine gerekli satırları ekleyelim:
```
#
# rules.before
#
# Rules that should be run before the ufw command line added rules. Custom
# rules should be added to one of these chains:
#   ufw-before-input
#   ufw-before-output
#   ufw-before-forward
#

# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to eth0
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES

...
```
Dosyaya `# START OPENVPN RULES` ve `# END OPENVPN RULES` tag ları arasındaki kısımları ekledikten sonra kaydedip kapatalım.

Buna ek olarak UFW'ye varsayılan olarak iletilen paketlere izin vermesini söylemeliyiz. Bunun için ayar dosyamızı açalım:
```
$ sudo vi /etc/default/ufw
```
Dosyanın içinde `DEFAULT_FORWARD_POLICY` satırını bulup değerini `ACCEPT` olarak değiştirelim.
```
DEFAULT_FORWARD_POLICY="ACCEPT"
```
Değişikliğimizi yaptıktan sonra dosyayı kaydedip kapatalım.

### Port Ayarlarının Yapılması
Şimdi firewall ımızda portlarımızı açalım ve aktifleştirelim. OpenVPN varsayılan olarak `1194` portunu kullanıyor. `1194` portunu `UDP` trafiğine açalım. Öncesinde ufw durumunu kontrol edelim:
```
$ sudo ufw status
```
şimdi portumuzu açalım
```
$ sudo ufw allow 1194/udp
```
Bu işlemlerden sonra sunucumuz OpenVPN trafiğini düzgün bir şekilde işleyebilecektir.

## OpenVPN Servisinin Başlatılması
OpenVPN servisimizi çalıştırmak için `systemd` kullanabiliriz.

Sunucumuzun konfigurasyon dosyası adı ile birlikte çalıştırmamız gerekiyor. Sunucumuzun konfigurasyon dosyası `/etc/openvpn/kebap.conf` bu yüzden komutun sonuna `@kebap` ekleyeceğiz.
```
$ sudo systemctl start openvpn@kebap
```
servisimizin başarılı bir şekilde çalıştığını doğrulayalım:
```
$ sudo systemctl status openvpn@kebap
```
Her şey doğru gittiyse şu şekilde bir çıktı alacaksınız:
```
● openvpn@kebap.service - OpenVPN connection to kebap
   Loaded: loaded (/lib/systemd/system/openvpn@.service; disabled; vendor preset: enabled)
   Active: active (running) since Tue 2017-02-21 14:09:01 UTC; 6s ago
     Docs: man:openvpn(8)
           https://community.openvpn.net/openvpn/wiki/Openvpn23ManPage
           https://community.openvpn.net/openvpn/wiki/HOWTO
  Process: 27686 ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --script-security 2 --config /etc/openvpn/%i.conf -
 Main PID: 27690 (openvpn)
   CGroup: /system.slice/system-openvpn.slice/openvpn@kebap.service
           └─27690 /usr/sbin/openvpn --daemon ovpn-kebap --status /run/openvpn/kebap.status 10 --cd /etc/openvpn --script-security 2 --config /etc/openvpn/kebap.co

Feb 21 14:09:01 sandbox ovpn-kebap[27690]: /sbin/ip addr add dev tun0 local 10.8.0.1 peer 10.8.0.2
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: /sbin/ip route add 10.8.0.0/24 via 10.8.0.2
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: GID set to nogroup
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: UID set to nobody
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: UDPv4 link local (bound): [undef]
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: UDPv4 link remote: [undef]
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: MULTI: multi_init called, r=256 v=256
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: IFCONFIG POOL: base=10.8.0.4 size=62, ipv6=0
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: IFCONFIG POOL LIST
Feb 21 14:09:01 sandbox ovpn-kebap[27690]: Initialization Sequence Completed
```
Bu da tamamsa servisimizi etkinleştirelim ki sunucumuz yeniden başlatılırsa otomatik olarak boot aşamasında çalışsın:
```
$ sudo systemctl enable openvpn@kebap
```
Artık sunucumuzdaki OpenVPN servisi aktif ve çalışıyor durumda. Sırada bu servise bağlanacak kullanıcılar için olan ayarlamaları yapacağız.

## İstemci Yapılandırma Altyapısı Oluşturma
Sıradaki işimiz kullanıcılarımız için ayar dosyalarını oluşturmak. Bunun için `home` klasörümüze `client-configs` ve bunun içine `files` dosyalarını oluşturalım.
```
$ mkdir -p ~/client-configs/files
```
`files` klasörümüzde sunucularımıza bağlanacak olan istemcilerin anahtarları bulunacağı için güvenlik amacıyla klasöre erişimi kısıtlayalım:
```
$ chmod 700 ~/client-configs/files
```

### Temel Ayarları Oluşturmak
Temel ayarlarımız için openvpn örnek ayar dosyasını `base.conf` adıyla kopyalayalım:
```
$ cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
```
Kopyaladığımız dosyayı açalım:
```
$ vi ~/client-configs/base.conf
```
Burada `remote` bölümünü bulup sunucumuzun IP adresini girelim.
```
...
# The hostname/IP and port of the server.
# You can have multiple remote entries
# to load balance between the servers.
remote buraya_IP_adresi_gelecek 1194
...
```
Yine aynı dosya içinde `proto` bölümünden protokolün `udp` olduğunu kontrol edelim.
```
# Are we connecting to a TCP or
# UDP server?  Use the same setting as
# on the server.
proto udp
```
`user` ve `group` kısmını bulup baştaki `;` işaretini kaldıralım.
```
# Downgrade privileges after initialization (non-Windows only)
user nobody
group nogroup
```
Sonrasında yine aynı dosya içinde sertifikaların olduğu bölümü bulup satıları yorum haline getirelim. Sertifikalarımızın içine bu anahtarları ekleyeceğiz burada tanımlamamıza gerek yok.
```
# SSL/TLS parms.
# See the server config file for more
# description.  It's best to use
# a separate .crt/.key file pair
# for each client.  A single ca
# file can be used for all clients.
# ca ca.crt
# cert client.crt
# key client.key
```
Daha sonra ise dosyamızın en altına, `/etc/openvpn/kebap.conf` dosyasında yaptığımız şifreleme ayarlarını kopyalayalım:
```
cipher AES-128-CBC
auth SHA256
```
Bunun altına `key-direction` satırını ekleyelim.
```
key-direction 1
```

### Ayar Dosyalarını Oluşturan Script'i Yazmak
Şimdi temel yapılandırma ayarlarımızı sertifika, anahtar ve şifreleme dosyaları ile derlemek için küçük bir script yazacağız. Bu çıktıları da `~/client-configs/files` klasöründe depolayacağız.

`~/client-configs` klasörünün içine `make_config.sh` adında bir script oluşturalım.
```
$ vi ~/client-configs/make_config.sh
```
Dosyamızın içine şunları yazalım:
```
#!/bin/bash

# First argument: Client identifier

KEY_DIR=~/openvpn-ca/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn
```
sonrasında kaydedip kapatalım.

Bu dosyayı çalıştırabilmek için izinleri ayarlayalım:
```
$ chmod u+x ~/client-configs/make_config.sh
```

## İstemci Ayarlarını Oluşturmak
Artık istemcilerimiz için ayar dosyalarını kolayca oluşturabiliriz.

Eğer bu anlatımı takip ettiyseniz [İstemci Sertifikası ve Anahtar Çifti Oluşturma](https://furkankarakoyunlu.com/ubuntu-openvpn-kurulumu/#Istemci-Sertifikasi-ve-Anahtar-Cifti-Olusturma) adımında `./build-key spootrickLaptop` komutunu kullanarak `spootrickLaptop` adında bir istemci sertifikası ve anahtarı oluşturmuştuk. (`spootrickLaptop.crt` ve `spootrickLaptop.key`)

Şimdi az önce oluşturduğumuz `make_config.sh` scripti kullanarak `spootrickLaptop` için yapılandırma ayarlarını oluşturabiliriz.
```
$ cd ~/client-configs
$ ./make_config.sh spootrickLaptop
```
Bu komut `~/client-configs/files` yoluna `spootrickLaptop.ovpn` adında bir dosya oluşturacak.
```
$ ls -lh ~/client-configs/files
```
```
-rw-rw-r-- 1 spootrick spootrick 13K Feb 21 16:40 spootrickLaptop.ovpn
```

## Yapılandırma Dosyalarının Transferi
Az önceki aşamada oluşturmuş olduğumuz `.ovpn` uzantılı dosyayı hangi cihazda kullanacaksak ona aktarmamız gerekli. Bunun için SCP (secure copy) kullanacağım.

Kendi local bilgisayarımdan (sunucudan değil!) bir terminal açıp şu komutu giriyorum:
```
$ scp -Pxxxx -r KULLANICI_ADI@SUNUCU_IP_ADRESI:client-configs/files/. ~/Desktop
```
yukarıda -Pxxxx yazan kısmı sunucunuzda SSH portunu değiştirdiyseniz, değiştirdiğiniz portu belirtmeniz için.

Bu komut `~/client-configs/files` klasöründeki bütün dosyaları local bilgisayarınızdaki masaüstüne kopyalar.

Bu işlemi grafik arabirimi olan [FileZilla](https://filezilla-project.org/) ile de gerçekleştirebilirsiniz.

## İstemci Yapılandırmasını Yüklemek
Artık VPN sunucumuzda bütün ayarları tamamladık. Bu aşamada VPN sunucunuzu hangi cihazda kullanmak istiyorsanız onunla ilgili bölüme geçebilirsiniz.

### Linux
Linux dağıtımınıza bağlı olarak birçok uygulama bulunmakta. Ben Ubuntu'da OpenVPN'in kendi uygulamasını kullanıyorum. Ubuntu veya Debian için şu yolu izleyebilirsiniz:
```
local $ sudo apt-get update && sudo apt-get install openvpn
```

Bağlanmak için ise, yükleme işleminden sonra local makinamıza çektiğimiz `.ovpn` uzantılı dosyamızla bağlantımızı oluşturabiliriz.
```
local $ sudo openvpn --config ~/Desktop/spootrickLaptop.ovpn
```

### OSX
Mac OS X için açık kaynak kodlu olan [Tunnelblick](https://tunnelblick.net/) OpenVPN istemcisini kullanabilirsiniz.

Kurulumun sonuna doğru sizden config dosyasını isteyecektir. Bu aşamada `No` seçip kurulumu tamamladıktan sonra Finder'dan `.ovpn` uzantılı dosyamıza çift tıklarsak Tunnelblick istemci profilini kuracaktır. (Yönetici yetkileri gerektirir.)

Bağlanmak için ise, uygulamayı çalıştırdıktan sonra menü çubuğundan ikonuna tıkladıktan sonra `Connect` menüsünden bağlantı ismini seçip bağlanabilirsiniz. Bağlantı ismi `.ovpn` uzantılı dosya isminizle aynı olacaktır.

### Windows
Bilgisayarınıza uyumlu olan sürümü [OpenVPN indirme sayfası](https://openvpn.net/index.php/open-source/downloads.html)ndan indirebilirsiniz.

Programı indirip kurduktan sonra (yönetici izni gerektirir) `.ovpn` uzantılı dosyayı;
```
C:\Program Files\OpenVPN\config
```
klasörünün içine kopyalayın.

Programı çalıştırdığınızda OpenVPN istemci profilinizi otomatik olarak algılayacaktır. OpenVPN programını her seferinde yönetici izinleri ile çalıştırmanız gerekecektir. Bunu kolay hale getirmek için program ikonuna sağ tıkladıktan sonra
```
Özellikler -> Uyumluluk -> Bu programı yönetici olarak çalıştır
```
kutucuğunu işaretleyin.

Bağlanmak için ise, uygulamayı açtıktan sonra (uygulama sistem tepsisinde -sağ altta- başlayacaktır) ikona sağ tıklayıp `.ovpn` uzantılı istemci profil isminizi seçip bağlanabilirsiniz.

### Android
Telefonunuza/tabletinize `.ovpn` uzantılı istemci profil dosyanızı aktarın. Sonra [OpenVPN Connect](https://play.google.com/store/apps/details?id=net.openvpn.openvpn) uygulamasını Google Play'den indirdin.

Bağlanmak için ise, uygulamayı açın. Sağ üstteki 3 noktaya basın. Ardından import seçeneğini seçin. Açılan ekrandan `.ovpn` uzantılı dosyanızı bulun ve ana ekranda çıkan **Connect** butonuna tıklayın.

### iOS
Telefonunuza/tabletinize [OpenVPN Connect](https://itunes.apple.com/us/app/id590379981) uygulamasını iTunes'dan indirip kurun. `.ovpn` uzantılı dosyanızı aktarmak için telefonunuzu bilgisayara bağlayın. iTunes'dan **iPhone -> apps** kısmına gelin. **Dosya paylaşımı** bölümünden OpenVPN uygulamasını seçin. Sağ kısımdaki **OpenVPN Dosyaları** kısmına `.ovpn` uzantılı dosyanızı sürükleyip bırakın.

Telefonunuzdan uygulamayı açtığınızda yeni profilin içe aktarılmaya hazır olduğuna dair bir bildirim alacaksınız. Yeşil **+** butonuna basın.

Bağlanmak için ise, **Connect** butonunu **On** pozisyonuna doğru kaydırın.

## VPN Bağlantı Testi
Her şey kurulduktan sonra VPN sunucumuzun düzgün çalıştığını kontrol etmek için bir test yapalım.

VPN bağlantınız **etkin olmadan** bir tarayıcı sayfası açın ve şu adrese gidin: [DNSLeakTest](https://www.dnsleaktest.com/)

Bu site size, servis sağlayıcınız tarafından atanan IP adresinizi gösterecektir. Hangi DNS sunucularını kullandığınızı görmek için **Extended Test** butonuna basın.

Şimdi VPN bağlantınızı **aktifleştirin** ve tekrar [DNSLeakTest](https://www.dnsleaktest.com/) sayfasını açın. Şu anda size VPN sunucunuzun IP adresini göstermesi gerekiyor. Tekrar **Extended Test** tuşuna basarak kullandığınız DNS sunucularını görebilirsiniz.

## İstemci Sertifikalarını İptal Etmek
Bazen, bazı istemcilerin VPN servisine erişimini kesmek isteyebilirsiniz. Bunun için istemci sertifikalarını iptal etmeniz gerekir.

Bunun için CA dizinimize gidip `vars` dosyamızı re-soruce etmemiz gerekiyor.
```
$ cd ~/openvpn-CA
$ source vars
```
Sonrasında `revoke-full` komutuyla sertifikasını iptal edebilirsiniz:
```
$ ./revoke-full spootrickLaptop
```
Bu işlem `error 23` kodu ile sonuçlanacaktır. Bu işlemin başarılı bir şekilde gerekli iptal bilgilerini ürettiğini gösterir. Bu bilgiler `keys` klasöründe `crl.pem` adlı dosyada toplanır.

Bu dosyayı `/etc/openvpn` klasörüne kopyalayalım:
```
$ sudo cp ~/openvpn-CA/keys/crl.pem /etc/openvpn
```
Sonra OpenVPN sunucu ayar dosyamızı açalım:
```
$ sudo vi /etc/openvpn/kebap.conf
```
Dosyanın en altına `crl-verify` satırını ekleyelim. Bu işlem OpenVPN sunucumuzun sertifika iptallerini kontrol etmesini sağlar.
```
crl-verify crl.pem
```
Kaydedip kapatın.

Son olarak OpenVPN işlemini yeniden başlatmamız gerekiyor:
```
$ sudo systemctl restart openvpn@kebap
```

Takip ettiğimiz adımları özetleyecek olursak:
* `vars` dosyasını re-soruce ederek `revoke-full` komutunu çalıştırmak.
* Oluşturulan yeni sertfika iptal listesini `/etc/openvpn` dizinine kopyalamak ve varsa eski listenin üzerine yazmak.
* OpenVPN servisini yeniden başlatmak.

Bu işlemler ile önceden oluşturduğunuz bütün sertifikaları iptal edebilirsiniz.

## Yeni İstemci Ekleme
Daha fazla istemci eklemek için şu adımları takip edebilirsin:
* [İstemci Sertifikası ve Anahtar Çifti Oluşturma](https://furkankarakoyunlu.com/ubuntu-openvpn-kurulumu/#Istemci-Sertifikasi-ve-Anahtar-Cifti-Olusturma)
* [İstemci Ayarlarını Oluşturmak](https://furkankarakoyunlu.com/ubuntu-openvpn-kurulumu/#Istemci-Ayarlarini-Olusturmak)

adımlarını takip edebilirsin.

Unutma her bir istemci için yeni bir sertifika kullanman lazım. Eğer aynı sertifikayı 2 ayrı cihazda kullanmaya çalışırsan cihazlardan birisi VPN servisine bağlanamayacaktır. Aynı anda bir sertifika ile sadece bir istemci bağlı kalabilir.

## Sonuç
Valla öncelikle seni tebrik ediyorum, bu kadar uzun bir anlatımı bitirdin. Artık ülkemizdeki internet yasaklamalarına takılmayacaksın. Ayrıca internette gezinirken kimliğini, lokasyon bilgilerini ve trafiğini gizli ve güvenli tutacaksın.

