# Garden Keeper 🌱🛡️

<div align="center">
  <img src="https://github.com/user-attachments/assets/c60954bd-af50-4cd9-8bd4-1a3b27c4b914" alt="Garden Keeper Logo" width="500"/>
  <br>
  <h3>🐹 Bahçenizi İstilacı Köstebeklerden Koruyun! 🌻</h3>
  <p>
    <a href="#oyun-hakkinda"><strong>Oyun Hakkında</strong></a> •
    <a href="#ozellikler"><strong>Özellikler</strong></a> •
    <a href="#oyun-modlari"><strong>Oyun Modları</strong></a> •
    <a href="#kurulum"><strong>Kurulum</strong></a> •
    <a href="#nasil-oynanir"><strong>Nasıl Oynanır</strong></a> •
    <a href="#teknik-detaylar"><strong>Teknik Detaylar</strong></a>
  </p>
  <p>
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen" alt="Platform">
    <img src="https://img.shields.io/badge/Flutter-3.0+-blue" alt="Flutter">
    <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
    <img src="https://img.shields.io/badge/Version-1.2.0-orange" alt="Version">
  </p>
</div>

<a name="oyun-hakkinda"></a>
## 🎮 Oyun Hakkında

**Garden Keeper**, bahçenize zarar vermeye çalışan köstebeklere karşı mücadele ettiğiniz eğlenceli bir refleks oyunudur. Toprak altından yüzeye çıkan köstebekleri hızlıca vurun, yüksek puan kazanın ve en iyi bahçe koruyucusu olun!

<div align="center">
  <img src="https://github.com/user-attachments/assets/6a77ba69-e4be-40f2-88bb-b665ad7c0591" alt="Gameplay Preview" width="300"/>
</div>

<a name="ozellikler"></a>
## ✨ Mevcut Özellikler

- 🎯 **Basit ve Eğlenceli Oynanış**: Köstebeklere dokunarak onları vurun
- 🎚️ **Üç Zorluk Seviyesi**:
  - 🟢 **Kolay**: Yavaş köstebekler, her vuruşta 10 puan
  - 🟡 **Normal**: Orta hızda köstebekler, her vuruşta 15 puan
  - 🔴 **Zor**: Hızlı köstebekler, her vuruşta 25 puan
- ⏱️ **60 Saniyelik Oyun Süresi**: Kısa ve tempolu oyun deneyimi
- 🔊 **Ses Ayarları**: Oyun müziği ve ses efektlerini açıp kapatabilme
- 🏆 **Yüksek Skor Takibi**: En iyi skorunuzu kaydedin ve kırmaya çalışın
- 📱 **Duyarlı Tasarım**: Farklı ekran boyutlarına otomatik uyum
- 🔨 **Güçlendiriciler**: Oyun sırasında rastgele ortaya çıkan özel güçlendiriciler
- 🏅 **Başarımlar Sistemi**: Özel hedefleri tamamlayarak başarım kazanın

<a name="planlanan-ozellikler"></a>
## 🚀 Planlanan Özellikler

Gelecek güncellemelerde aşağıdaki özellikleri eklemeyi planlıyoruz:

- 📊 **Gelişmiş İstatistikler**: Oyun performansınızı ayrıntılı olarak takip edin
- 🎨 **Özelleştirilebilir Temalar**: Farklı bahçe ve köstebek temaları
- 🧠 **Zorluk Artışı**: Oyun ilerledikçe zorlaşan seviyeler
- 🌐 **Çevrimiçi Skor Tablosu**: Diğer oyuncularla rekabet edin
- 🎁 **Özel Güçler ve Destekler**: Oyun içi kazanılan destekler
- 🌍 **Çoklu Dil Desteği**: Birden fazla dilde oyun deneyimi

<a name="ekran-goruntuleri"></a>
## 📱 Ekran Görüntüleri

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/83b7319f-9e45-431c-a05a-4ca69b28068b" alt="Ana Ekran" width="200"/></td>
      <td><img src="https://github.com/user-attachments/assets/eec67b03-e760-434b-bd28-105c6605e3b7" alt="Oyun Ekranı" width="200"/></td>
      <td><img src="https://github.com/user-attachments/assets/2d543bdf-0d64-43b1-9dba-da3d5ca7b0b5" alt="Oyun Sonu Ekranı" width="200"/></td>
      <td><img src="https://github.com/user-attachments/assets/ba904e16-cc8a-4074-95e5-39e87fcbbbf8" alt="Ayarlar Ekranı" width="200"/></td>
    </tr>
    <tr>
      <td align="center"><strong>Ana Ekran</strong></td>
      <td align="center"><strong>Oyun Ekranı</strong></td>
      <td align="center"><strong>Oyun Sonu</strong></td>
      <td align="center"><strong>Ayarlar</strong></td>
    </tr>
  </table>
</div>

<a name="nasil-oynanir"></a>
## 🕹️ Nasıl Oynanır

1. Ana ekrandaki "OYNA" butonuna tıklayarak oyunu başlatın
2. Toprak altından çıkan köstebeklere dokunarak onları vurmaya çalışın
3. Her başarılı vuruş, zorluk seviyesine göre puan kazandırır:
   - Kolay: 10 puan
   - Normal: 15 puan
   - Zor: 25 puan
4. 60 saniye içinde mümkün olduğunca çok köstebek vurun
5. Oyun sonunda puanınızı görün ve rekor kırdıysanız kutlayın!

<a name="kurulum"></a>
## 🔧 Kurulum

### Gereksinimler
- Flutter SDK (2.10.0 veya üstü)
- Dart SDK (2.16.0 veya üstü)
- Android Studio / VS Code
- Android veya iOS cihaz/emülatör

### Adımlar

```bash
# Repoyu klonlayın
git clone https://github.com/yourusername/garden-keeper.git

# Proje dizinine gidin
cd garden-keeper

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

<a name="teknik-detaylar"></a>
## 🧩 Teknik Detaylar

### Kullanılan Teknolojiler

- **Flutter**: Çapraz platform UI geliştirme framework'ü
- **Provider**: Durum yönetimi için
- **SharedPreferences**: Yerel veri depolama için
- **AudioPlayers**: Ses efektleri ve müzik çalma
- **Flutter Animate**: Animasyonlar için

### Proje Yapısı

```
lib/
├── main.dart                  # Uygulama giriş noktası
├── screens/                   # Uygulama ekranları
│   ├── home_screen.dart       # Ana menü ekranı
│   ├── game_screen.dart       # Oyun ekranı
│   └── settings_screen.dart   # Ayarlar ekranı
├── utils/                     # Yardımcı sınıflar
│   ├── audio_manager.dart     # Ses yönetimi
│   └── game_provider.dart     # Oyun durumu yönetimi
├── widgets/                   # Özel widget'lar
│   ├── game_over_dialog.dart  # Oyun sonu ekranı
│   └── mole_hole.dart         # Köstebek deliği widget'ı
└── models/                    # Veri modelleri
```

<a name="katki"></a>
## 👥 Katkıda Bulunma

Projeye katkıda bulunmak isterseniz:

1. Bu repoyu fork edin
2. Yeni bir feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

<a name="lisans"></a>
## 📜 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakınız.

<a name="iletisim"></a>
## 📧 İletişim

Sorularınız veya önerileriniz için:

- E-posta: kaaanyildz@gmail.com
- GitHub: [MyGithubProfile](https://github.com/Kaaanyildiz)

---

<div align="center">
  <p>
    <strong>Garden Keeper</strong> - Bahçenizi korumak hiç bu kadar eğlenceli olmamıştı!
  </p>
  <p>Made with ❤️ in Türkiye</p>
</div>
