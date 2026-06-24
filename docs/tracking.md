# Feature: Tracking

## Design

![Home - Orders List](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/home_orders_list.png)
![Order Details - Accepted](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_accepted.png)
![Order Details - Arrived at Pickup](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_arrived_pickup.png)
![Order Details - Picked](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_picked.png)
![Order Details - Out for Delivery](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_out_delivery.png)
![Order Details - Arrived to User](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_arrived_user.png)
![Order Details - Delivered](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_delivered.png)
![Map - Pickup Route](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/map_pickup_route.png)
![Map - Delivery Route](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/map_delivery_route.png)
![Order Success](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_success.png)

## API Details

### Get Driver Orders

- **Path**: `/drivers/all-orders`
- **Method**: `GET`
- **Response**:
  ```json
  {
    "message": "string",
    "metadata": {
      "currentPage": "number",
      "numberOfPages": "number",
      "limit": "number",
      "nextPage": "number"
    },
    "orders": [
      {
        "_id": "string",
        "driver": "string",
        "order": {
          "_id": "string",
          "user": {
            "_id": "string",
            "firstName": "string",
            "lastName": "string",
            "email": "string",
            "phoneNumber": "string"
          },
          "orderItems": [
            {
              "product": {
                "_id": "string",
                "price": "number",
                "title": "string"
              },
              "price": "number",
              "quantity": "number",
              "_id": "string"
            }
          ],
          "totalPrice": "number",
          "shippingAddress": {
            "street": "string",
            "city": "string",
            "phone": "string",
            "lat": "string",
            "long": "string"
          },
          "paymentType": "string",
          "isPaid": "boolean",
          "paidAt": "string",
          "isDelivered": "boolean",
          "state": "string",
          "createdAt": "string",
          "updatedAt": "string",
          "orderNumber": "string"
        },
        "store": {
          "name": "string",
          "image": "string",
          "address": "string",
          "phoneNumber": "string",
          "latLong": "string"
        }
      }
    ]
  }
  ```

### Start Order

- **Path**: `/orders/start/{id}`
- **Method**: `PUT`
- **Params**: `id` (Order ID)
- **Response**:
  ```json
  {
    "message": "string"
  }
  ```

### Update Order State

- **Path**: `/orders/state/{id}`
- **Method**: `PUT`
- **Params**: `id` (Order ID)
- **Request Body**:
  ```json
  {
    "state": "accepted | inProgress | completed | canceled"
  }
  ```
- **Response**:
  ```json
  {
    "message": "string"
  }
  ```

## Business Requirements & Detailed Flow

### 1. Order Acceptance Flow

- **Action**: When the driver taps "Accept" on any order in the list.
- **Navigation**: Navigates to the **Order Details** screen passing the `OrderEntity`.
- **Constraint**: Once accepted, the driver **cannot** simply go back to the previous screen.
- **Back Button Logic**: If the driver tries to use the system back button or a back icon, a *
  *Confirmation Dialog** must appear.
- **Order Cancellation/Reversion**: If the driver confirms they want to leave, the order state must
  be reverted to `pending` in the database, and then the driver is navigated back to the orders
  list.

### 2. Order Details & States

- **State Management**: The Order Details screen manages 4 main states/stages:
    1. **Accepted**: Initial state after acceptance.
    2. **Picked**: Order has been collected from the store.
    3. **Out for Delivery**: Driver is on the way to the user.
    4. **Delivered**: Final state, order completed.
- **Pending State**: Used for orders that are available for acceptance or when an order is reverted.
- **API Sync**: Every state transition must be sent to the backend using the Update Order State API.
- **Notifications (Future)**: The Repository layer should be designed to support sending
  notifications to the User App upon state changes (to be implemented later).

### 3. Navigation to Maps (Upcoming Sprint)

- **Interactions**:
    - Tapping the **Store ListTile** -> Navigate to Map showing the route between Current Location
      and Store Location.
    - Tapping the **User ListTile** -> Navigate to Map showing the route between Current Location
      and User Location.
- **Note**: The Map UI and routing logic are planned for the next sprint, but the presentation layer
  should account for these interaction points.

### 4. Data Usage (`OrderEntity`)

- All fields in `OrderEntity` (User details, Store details, Order items, Shipping address, Prices)
  must be correctly displayed as per the designs.

## AI Modification History

- **2026-06-23**: Implemented the Order Details View Model following the "Composite State" pattern.
  This included:
    - `order_details_events.dart`: Defined a sealed class for all UI actions, including a unified
      `UpdateOrderStateEvent` and specialized initialization/reversion events.
    - `order_details_states.dart`: Implemented a Composite State inheriting from
      `BaseState<OrderEntity>` with nested `BaseState` objects (`orderDetailsState`,
      `canselOrderState`) for granular UI control over independent operations (e.g., specific
      loading indicators for buttons vs. screen data).
    - `order_details_cubit.dart`: Implemented the full logic flow. The `Initialize` event handles
      the sequential chain of `startOrder` followed by an `updateOrderState(accepted)` to ensure
      system consistency. Reversion logic handles API synchronization before navigating back.
- **2026-06-23**: Updated with detailed business flow (acceptance logic, back button constraints,
  state transitions, and future map integration) as per user instructions.
- **2026-06-23**: Initial documentation created by AI based on existing codebase and
  `WORKING_STANDARDS.md`.
