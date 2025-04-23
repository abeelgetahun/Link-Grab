# Link Grab

A cross-platform mobile application designed to streamline the process of saving and organizing web links from various social media platforms for easy and effective future retrieval.

## Features

- **Save Links**: Capture links from any app using the share functionality
- **Organize by Categories**: Create and manage categories to organize your links
- **Search**: Quickly find links with the built-in search functionality
- **Local Storage**: All links are stored locally on your device for privacy
- **Share**: Share your saved links with others

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or Visual Studio Code with Flutter extensions
- An Android or iOS device/emulator

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/link-grab.git
   cd link-grab
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Generate Floor database code:
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```
   flutter run
   ```

## Usage

1. **Onboarding**: First-time users will see onboarding screens introducing the app
2. **Add Categories**: Go to the Categories tab and add your categories
3. **Save Links**: Use the + button to manually add links, or share a link from any app to Link Grab
4. **View Links**: Browse your links by category or view all
5. **Search**: Use the search icon to find links by title, URL, or description

## Project Structure

- `/lib/models`: Data models for links and categories
- `/lib/screens`: UI screens
- `/lib/widgets`: Reusable UI components
- `/lib/database`: Database configuration and DAOs
- `/lib/services`: Business logic services
- `/lib/utils`: Utility classes and functions
- `/lib/providers`: State management providers

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
