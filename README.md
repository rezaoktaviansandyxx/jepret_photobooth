# Jepret 📸 - Solo Photobooth

> Pick a frame, snap 3 photos, get your photo strip. No need to wait for friends.

[Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
[Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
[Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)
[License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Jepret is a solo photobooth app built with Flutter. You choose a frame, the camera takes 3 photos automatically with a 3-2-1 countdown, and you get a cute photo strip ready to download and share.

## 📥 Download APK

[Download Jepret v1.0.0 (Android APK)](https://github.com/rezaoktaviansandyxx/jepret_photobooth/releases/tag/v1.0.0)

This project was built as a fun side project while job hunting, to practice camera handling, image processing, and clean UI slicing in Flutter.

## ✨ Features

- **Frame Picker:** 5 cute frames, Classic, Doodle Love, Berry Sweet, Retro Pastel, and Malang Edition
- **Auto Capture 3x:** Countdown 3-2-1, auto snap 3 photos with 1 second interval, with progress indicator 1/3, 2/3, 3/3
- **Live Filter:** Original, B&W, Vintage, Pinky, using Flutter ColorFilter
- **Retake Per Photo:** Retake only the photo you do not like, no need to restart everything
- **Photo Strip Stitching:** Combine 3 photos into 1 PNG strip with frame background, using `image` package
- **Export & Share:** Download to gallery, share to WhatsApp / Instagram Story
- **In-app Gallery:** All your strips saved locally, with delete and empty state
- **Camera Controls:** Front / back camera, flash on/off, 0.5x / 1x / 2x zoom

## 📸 Preview

[Jepret Mockup](assets/screenshots/mockup.png)

> Put your screenshot / mockup image in `assets/screenshots/mockup.png` to show it here.

Flow: Home > Pick Frame > Camera (3-2-1) > Preview & Filter > Result > Download / Share

## 🛠️ Tech Stack

- **Flutter & Dart:** UI and logic
- **Provider:** State management
- **GoRouter:** Navigation
- **camera:** Camera preview and capture
- **image:** Stitch 3 photos into 1 photo strip
- **path_provider + gal:** Save result to device gallery
- **share_plus:** Share result

No backend, no Firebase for MVP. Everything runs locally so it is fast and easy to try.

## 📁 Project Structure

```
lib/
  main.dart
  core/
    router/app_router.dart
    theme/app_theme.dart
  features/
    booth/
      data/
        frame_model.dart
        filter_model.dart
      provider/
        booth_provider.dart
      screens/
        home_screen.dart
        frame_picker_screen.dart
        camera_screen.dart
        result_screen.dart
        gallery_screen.dart
      widgets/
        photo_strip.dart
        countdown_overlay.dart
        frame_card.dart
  services/
    camera_service.dart
    image_stitcher.dart
    export_service.dart
assets/
  frames/
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Android Studio / Xcode for mobile, or Chrome for web
- A device with camera, or emulator with virtual camera

### Installation

```bash
# Clone the repo
git clone https://github.com/your-username/jepret-photobooth.git
cd jepret-photobooth

# Get dependencies
flutter pub get

# Run on your device
flutter run
```

### Run on Web

```bash
flutter run -d chrome
```

Note: Allow camera permission in your browser when prompted.

## 📱 How to Use

1. Tap **Mulai Jepret** on Home
2. Choose your favorite frame
3. Tap the shutter button, get ready for the countdown
4. Pose for 3 photos, check the preview
5. Pick a filter, retake if needed
6. Tap **Download** to save, or **Share** to post it

## 🎨 Frames & Filters

**Frames:**
- Classic - Minimal white strip
- Doodle Love - Pink doodle with hearts
- Berry Sweet - Strawberry theme
- Retro Pastel - Purple retro vibe
- Malang Edition - Local doodle edition, Bakso Malang + Apel Malang + Bromo + Tugu Malang illustration, with 'Malang Pride' text

**Filters:**
- Original
- B&W
- Vintage
- Pinky

## 🗺️ Roadmap

- [ ] Video Booth mode, 3 second boomerang
- [ ] Custom frame upload
- [ ] Sticker and text on photo strip
- [ ] Cloud gallery with Supabase / Firebase
- [ ] Print mode for mini printer

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repo
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 👨‍💻 Author

**Indra Oki Sandy** - Flutter Developer & Web Developer

- Portfolio: https://indraokisandy-dev.vercel.app/
- LinkedIn: https://www.linkedin.com/in/indraokisandy/

Focused on Flutter, POS systems, and ERP integration with REST API.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

Made with fun. If you try Jepret, tag me and show your photo strip!