# Yatzy · Flutter game prototype

[![CI](https://github.com/hamzaguner0/yatzy/actions/workflows/ci.yml/badge.svg)](https://github.com/hamzaguner0/yatzy/actions/workflows/ci.yml)

Flutter/Dart ile Yatzy oyun çalışması. Skor hesaplama, zar tutma/yeniden atma, yerel kayıt, Türkçe/İngilizce arayüz ve farklı yapay oyuncu kararları içerir. Riverpod ve GoRouter kullanır.

## Kurulum

Yerel doğrulama ve CI sürümü: Flutter 3.35.5 / Dart 3.9.2. Bu seçim en yeni sürüm iddiası değildir.

```sh
git clone https://github.com/hamzaguner0/yatzy.git
cd yatzy
flutter pub get
flutter analyze
flutter test
```

Depo uygulama kaynaklarını ve testleri içerir; Android/iOS/Web platform iskeletleri depoda bulunmaz. Çalıştırılabilir platform oluşturmak için geliştirme kopyasında `flutter create --platforms=android,ios,web --project-name yatzy_tr .` kullanın ve hedef platformun araç zincirini kurun. Ardından `flutter run` ile başlatın. Platform kurulumu, imzalama ve mağaza dağıtımı bu depodaki testlerle doğrulanmaz.

## Kontroller ve kapsam

CI biçim, statik analiz ve test çalıştırır. Domain testleri skor, oyun akışı, yerel serileştirme ve AI kararlarını kapsar. Yüzde 100 kapsam, her cihazda performans veya mağazaya hazır ürün iddiası yoktur. AI yaklaşımları sezgiseldir; optimal oyun garantisi vermez. Test sonucu ve kapsam sayılarını ilgili çalışma çıktısından değerlendirin.

Paket adı `yatzy_tr`; GitHub depo adı `yatzy`dir. İkisi farklı amaçlar taşır.
