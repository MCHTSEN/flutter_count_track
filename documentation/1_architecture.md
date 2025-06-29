# Project Architecture

This document provides a high-level overview of the architecture of the **Paketleme Takip Sistemi** (Packaging Tracking System) application.

## Core Principles

The application is built upon the following core architectural principles:

- **Clean Architecture:** The project is structured to separate concerns, making it more maintainable, scalable, and testable. This is evident in the `features` directory, where each feature is divided into `data`, `domain`, and `presentation` layers.
- **MVVM (Model-View-ViewModel):** The presentation layer loosely follows the MVVM pattern, where:
    - **View:** The Flutter widgets in the `presentation/screens` and `presentation/widgets` directories.
    - **ViewModel:** The Riverpod `StateNotifier` classes in the `presentation/notifiers` directory.
    - **Model:** The data classes in the `data/models` directory.
- **Offline-First:** The application is designed to be fully functional without an internet connection. Data is stored locally in a SQLite database, and synchronization with the backend is handled when a connection is available.
- **Hybrid Sync:** The application uses a hybrid synchronization model with Supabase. Data is first written to the local database and then synchronized with the Supabase backend.
- **Riverpod for State Management:** Riverpod is used for dependency injection and state management, providing a robust and scalable way to manage application state.

## Directory Structure

The project is organized into the following main directories:

- **`lib/`**: The main directory for the application's Dart code.
    - **`core/`**: Contains the core components of the application, such as:
        - **`config/`**: Configuration files, like Supabase credentials.
        - **`constants/`**: Application-wide constants, such as route names and error messages.
        - **`database/`**: The local database setup, including the Drift schema and migrations.
        - **`services/`**: Services that provide functionality across the application, such as the `SupabaseService`.
        - **`theme/`**: The application's theme and styling.
        - **`utils/`**: Utility classes and functions.
    - **`features/`**: Contains the different features of the application, each with its own `data`, `domain`, and `presentation` layers.
        - **`barcode_scanning/`**: Handles barcode scanning and processing.
        - **`dashboard/`**: Displays statistics and analytics.
        - **`order_management/`**: Manages orders, order items, and related operations.
    - **`shared_widgets/`**: Widgets that are shared across multiple features.
- **`assets/`**: Contains static assets, such as sounds and images.
- **`documentation/`**: Contains the project documentation.

## Key Technologies

- **Flutter:** The UI framework for building the application.
- **Drift (Moor):** A reactive persistence library for Flutter and Dart, used for the local SQLite database.
- **Riverpod:** A state management library for Flutter.
- **Supabase:** The backend-as-a-service (BaaS) platform used for data storage and synchronization.
- **Syncfusion Charts:** A library for creating charts and graphs in the dashboard.
