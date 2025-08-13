# FitnessApp

A comprehensive fitness application with a Flutter-based mobile frontend and a Node.js backend.

## Features

*   User registration and authentication
*   AI-powered workout and meal plan generation
*   Workout logging
*   Meal logging
*   And more!

## Technologies Used

**Frontend:**

*   Flutter
*   Dart

**Backend:**

*   Node.js
*   Express.js
*   MongoDB

## Project Structure

The project is divided into two main directories:

*   `frontend/`: Contains the Flutter mobile application.
*   `backend/`: Contains the Node.js REST API.

## Getting Started

### Prerequisites

*   Flutter SDK
*   Node.js and npm
*   MongoDB

### Backend Setup

1.  Navigate to the `backend` directory:
    ```bash
    cd backend
    ```
2.  Install the dependencies:
    ```bash
    npm install
    ```
3.  Create a `.env` file in the `backend` directory and add the following environment variables:
    ```
    PORT=3000
    MONGO_URI=<your_mongodb_uri>
    JWT_SECRET=<your_jwt_secret>
    ```
4.  Start the server:
    ```bash
    npm start
    ```

### Frontend Setup

1.  Navigate to the `frontend` directory:
    ```bash
    cd frontend
    ```
2.  Install the dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

## API Endpoints

The backend provides the following REST API endpoints:

*   `POST /api/users/register`: Register a new user.
*   `POST /api/users/login`: Log in a user.
*   `GET /api/users/me`: Get the currently logged-in user's profile.
*   `POST /api/ai-plans`: Generate a new AI-powered workout and meal plan.
*   `GET /api/ai-plans`: Get the user's AI-powered workout and meal plan.
*   `POST /api/workout-logs`: Log a new workout.
*   `GET /api/workout-logs`: Get all workout logs for the user.
*   `POST /api/meal-logs`: Log a new meal.
*   `GET /api/meal-logs`: Get all meal logs for the user.
