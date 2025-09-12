That evening I spent building a hnti website.

What it does
Browse a grid of hnti videos

Pagination support

Search videos without leaving the main page

Watch videos inside the app

Simple login/register system

Comments for videos

Frontend Setup (Flutter)
Clone the repo

git clone <your-repo-url>
cd hentaiz_viewer

Set your backend server URL

Open lib/resource.dart and set the baseUrl to your backend server:

static const String baseUrl = "http://YOUR_SERVER_IP_OR_DOMAIN:5000";

Install Flutter dependencies

flutter pub get

Run the app

flutter run

Backend Setup (Node.js + SQLite3)
Navigate to the backend folder (if separate) or project root.

Install dependencies

npm install

Start the server

node server.js

Server features
Provides paginated video list

Returns video URLs

Handles user login/register

Supports comments for videos

Supports search queries
