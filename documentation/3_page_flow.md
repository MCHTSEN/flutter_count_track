# Page Flow

This document outlines the page flow and navigation of the **Paketleme Takip Sistemi** application.

## Main Screens

The application consists of the following main screens:

- **`HomeScreen`**: The main entry point of the application, providing access to the other features.
- **`DashboardScreen`**: Displays statistics and analytics about the orders and products.
- **`OrderListScreen`**: Displays a list of all orders, with filtering and search functionality.
- **`OrderDetailScreen`**: Displays the details of a specific order, including the order items and barcode scanning functionality.
- **`AddOrderScreen`**: Allows the user to create a new order.
- **`BoxManagementScreen`**: Allows the user to manage the boxes for a specific order.
- **`SupabaseTestScreen`**: A screen for testing the connection to the Supabase backend.

## Navigation Flow

1.  The application starts at the **`HomeScreen`**.
2.  From the **`HomeScreen`**, the user can navigate to:
    - **`DashboardScreen`**
    - **`OrderListScreen`**
    - **`SupabaseTestScreen`**
3.  From the **`OrderListScreen`**, the user can:
    - Tap on an order to navigate to the **`OrderDetailScreen`**.
    - Tap the "+" button to navigate to the **`AddOrderScreen`**.
4.  From the **`OrderDetailScreen`**, the user can:
    - Tap the "Box Management" button to navigate to the **`BoxManagementScreen`**.
