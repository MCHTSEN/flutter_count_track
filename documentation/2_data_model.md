# Data Model

This document describes the data model of the **Paketleme Takip Sistemi** application, including the local database schema and the data models used in the application.

## Local Database (Drift/SQLite)

The local database is managed using the **Drift** persistence library, which provides a reactive API for SQLite.

### Tables

The database consists of the following tables:

- **`Orders`**: Stores the main information about orders.
- **`OrderItems`**: Stores the individual items within each order.
- **`Products`**: Stores information about the products.
- **`ProductCodeMappings`**: Maps customer-specific product codes to internal product codes.
- **`BarcodeReads`**: Logs every barcode scan attempt.
- **`Boxes`**: Manages the boxes used for packing orders.
- **`Deliveries`**: Stores information about deliveries.
- **`DeliveryItems`**: Stores the items included in each delivery.

### Schema

For a detailed view of the database schema, please refer to the `lib/core/database/app_database.dart` file.

## Data Models

The application uses several data models to represent the data from the database and the API.

- **`Order`**: Represents an order.
- **`OrderItem`**: Represents an item in an order.
- **`Product`**: Represents a product.
- **`ProductCodeMapping`**: Represents a mapping between a customer product code and an internal product code.
- **`BarcodeRead`**: Represents a barcode scan.
- **`Box`**: Represents a box.
- **`Delivery`**: Represents a delivery.
- **`DeliveryItem`**: Represents an item in a delivery.
- **`DashboardStats`**: Represents the statistics displayed on the dashboard.
