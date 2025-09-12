<a id="readme-top"></a>


## About The Project

That evening I spent building a h*nt*i website in Flutter.

Features:
* Browse a grid of h*nt*i videos
* Pagination support
* Search videos without leaving the main page
* Watch videos inside the app
* Simple login/register system
* Comments for videos

### Built With

* Flutter
* Dart
* Provider
* HTTP

## Getting Started

### Prerequisites

* Flutter SDK
* A working backend server

### Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/your_username/hentai-viewer-app.git
2. Navigate into project folder:
    ```bash
    cd hentai-viewer-app
3. Install dependencies:
    ```bash
    flutter pub get


4. Set your backend server URL:
Open `lib/resource.dart` and set the `baseUrl`:
    ```dart
    class Resource {
      static const baseUrl = 'http://your-backend-server.com';
    }

5.Run the app:
  ```bash
      flutter run
