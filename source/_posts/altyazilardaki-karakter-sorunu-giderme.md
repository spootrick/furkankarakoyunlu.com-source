---
title: Altyazılardaki Karakter Sorununu Giderme
tags:
  - Altyazı
  - Altyazı sorunu
  - Altyazı karakter hataları
  - Altyazı karakter düzeltme
  - UTF8 altyazı
categories:
  - Nasıl Yapılır?
date: 2017-03-11 20:10:07
---

![Bozuk hal](https://furkankarakoyunlu.com/images/bozuk_altyazi.jpg)
![Duzeltimlmis hal](https://furkankarakoyunlu.com/images/duzgun_altyazi.jpg)
İzleyeceğimiz film yada diziler için internetten bulduğumuz altyazılarda bazen Türkçe karakterler yukarıdaki örnek resimdeki gibi saçma şekilde görünebiliyor. Bu yazıda bu durumu nasıl düzeltebileceğimizi göstereceğim. Bu sorunun birden fazla çözüm yolu var işte bunlardan birkaç tanesi ..

## 1. Yol: Terminal
Eğer `*NIX` tabanlı bir sisteme sahipseniz ve terminalle aranız iyiyse bu sorunun çözümü 1 satırlık kod kadar uzağınızda.

İşte kodumuz:
```
$ iconv -f ISO-8859-9 -t UTF-8 BOZUK_ALTYAZI.srt > DUZELTILMIS_ALTYAZI.srt
```
Bu komutu çalıştırdıktan sonra karakter seti `UTF-8` ile değiştirilmiş altyazı dosyanız `DUZELTILMIS_ALTYAZI.srt` adında bulunduğunuz klasörde oluşturulacaktır. İşlem bu kadar iyi seyirler :)

## 2. Yol: Sublime Text
Bu adımda bize yardım edecek olan metin editörü [Sublime Text](https://www.sublimetext.com). Bu editörü kullanarak sorunu kolayca çözebilirsiniz. Verdiğim linkten tıklayarak bilgisayarınıza uygun olanı indirip kurun.

Kurulum tamamlandıktan sonra altyazı dosyasını (genellikle `.srt` veya `.sub` uzantılı olurlar) sublime text ile açın.

Dosya açıldıktan sonra aşağıdaki yolu takip edin.
```
File -> Reopen with Encoding -> Turkish(ISO 8859-9)
```
daha sonra düzenlediğimiz dosyayı şu şekilde kaydedin
```
File -> Save with Encoding -> UTF-8 with BOM
```

Bu işlemlerden sonra altyazıyı tekrar oynatıcımıza atarak seyir keyfinize kaldığınız yerden devam edebilirsiniz :)
