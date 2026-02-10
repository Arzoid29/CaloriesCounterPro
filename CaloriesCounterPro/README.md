# CaloriesCounterPro

CaloriesCounterPro is a SwiftUI app designed to help users estimate the calorie content of restaurant dishes by scanning menus. It leverages text recognition and calorie estimation services, stores scan history, and supports multiple restaurants and languages.

## Features

- Scan restaurant menus using the device camera
- Automatic text recognition and calorie estimation
- Save and review scan history
- Manage restaurant information
- Multi-language support (English, Spanish)
- Clean, modern SwiftUI interface

## Project Structure

- `App/` – App entry point and model container setup
- `Data/` – API services, persistence, and repositories
- `Domain/` – Core entities, repositories, and use cases
- `Presentation/` – SwiftUI views, screens, and components
- `Resources/` – Localizations and assets
- `Utils/` – App configuration and theming

## Getting Started

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/CaloriesCounterPro.git
   ```
2. Open `CaloriesCounterPro.xcodeproj` in Xcode.
3. Build and run the app on your simulator or device.

## Requirements

- Xcode 14+
- iOS 16+ / macOS 13+
- Swift 5.7+

## Contributing

Contributions are welcome! Please open issues or pull requests for bug fixes, improvements, or new features.

## License

This project is licensed under the MIT License.
