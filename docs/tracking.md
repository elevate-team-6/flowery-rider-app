# Feature: Tracking (Driver App)

## 1. Overview & UI Design

The Tracking feature is the core of the Rider application, managing the entire lifecycle of an order
from the moment it is accepted until it is successfully delivered to the end-user. The UI is
designed to be highly informative and restrictive to ensure the driver follows the correct sequence
of actions.

### Visual Flow (Design Links)

- **Home - Orders List**: Displays pending orders available for acceptance.
- **Order Details Stages**:
  - ![Accepted](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_accepted.png)
  - ![Arrived at Pickup](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_arrived_pickup.png)
  - ![Picked](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_picked.png)
  - ![Out for Delivery](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_out_delivery.png)
  - ![Arrived to User](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_arrived_user.png)
  - ![Delivered](file:///C:/Users/pc/AppData/Local/Google/AndroidStudio2025.3.4/projects/flowery_rider_app.aa7c2981/.artifacts/20260623-172048-c7a09f30-f98f-4bd3-b2bb-279b07fb6496/order_details_delivered.png)
- **Maps & Routes**: Detailed routing for pickup and delivery.
- **Success Screen**: Final confirmation of delivery.

---

## 2. API Architecture & Mapping Strategy

The Backend uses a simplified state machine, while the UI requires a more granular 6-step flow. We
bridge this gap using a **Mapping Strategy** in the Cubit.

### Endpoint: `/orders/state/{id}` (PUT)

| UI Step    | UI Label          | Backend State | Description                              |
|:-----------|:------------------|:--------------|:-----------------------------------------|
| **Step 1** | Accepted          | `inProgress`  | Driver has taken the order.              |
| **Step 2** | Arrived at Pickup | `inProgress`  | Driver reached the store.                |
| **Step 3** | Picked            | `inProgress`  | Items are now with the driver.           |
| **Step 4** | Out for Delivery  | `inProgress`  | Driver is en route to user.              |
| **Step 5** | Arrived to User   | `inProgress`  | Driver reached delivery location.        |
| **Step 6** | Delivered         | `completed`   | Final hand-off. Triggers success screen. |
| **Revert** | Cancel            | `canceled`    | Reverts order to the public queue.       |

---

## 3. Detailed Business Logic

### A. Initialization & Race Condition Prevention

When the driver navigates to `OrderDetailsScreen`, the `InitializeOrderDetailsEvent` is triggered.

- **Mechanism**: Called within `Future.microtask` in `initState`.
- **Why**: Ensures that the `UiEventHandler` (Stream Listener) is fully active before the Cubit
  emits the first `ShowLoadingEvent`.
- **Loading UI**: Displays the `LoadingDialog` (Custom Flower Animation) as a modal overlay while
  `startOrder` is called.

### B. Order Cancellation (The Safety Net)

Since the driver is restricted from simply "going back", a formal cancellation process is
implemented.

- **Trigger**: System back button or AppBar back icon (handled via `PopScope`).
- **Confirmation Dialog**:
  - **Visual**: Includes a warning emoji ⚠️ in the message to denote significance.
  - **Reactive State**: Wrapped in a `BlocBuilder` using `BlocProvider.value(value: cubit)` to
    maintain state inside the dialog route.
  - **Loading State**: The "Confirm" button replaces its text with a `CircularProgressIndicator`
    while the `RevertOrderToPendingEvent` is in flight.
  - **Security**: All dialog actions are disabled during the API call to prevent race conditions or
    duplicate requests.

### C. Dynamic UI Components

- **OrderStepIndicator**: A 5-segment progress bar that fills based on `uiStep`.
- **OrderStatusCard**: Displays localized status strings, order number, and timestamp.
- **AddressInfoCard**: A unified clickable component for Store and User info. Supports future
  "Click-to-Map" and "Call/WhatsApp" integration.
- **OrderActionButton**: The primary CTA. Its text updates according to the *next* logical step in
  the lifecycle.

---

## 4. Technical Implementation Standards

### State Management: Composite Pattern

We use `OrderDetailsState` which extends `BaseState<OrderEntity>` but adds nested `BaseState`
objects:

- `orderDetailsState`: Manages the main screen data and full-screen loading.
- `cancelOrderState`: Independently manages the loading state of the cancellation dialog buttons.
- **Equatable**: Both nested states are included in `props` to ensure the UI re-renders correctly
  when only a substate (like button loading) changes.

### Theme & Styling (Centralized)

- **Dialogs**: Defined globally in `AppTheme.dialogThemeData` (Shape: `16.r`, Elevation: `0`,
  TitleStyle: `black18600`).
- **Buttons**: All buttons rely on `elevatedButtonTheme` for consistent `double.infinity` width and
  `100.r` border radius.
- **Colors**: Strictly uses `.withValues(alpha: ...)` for all semi-transparent elements to ensure
  compatibility with modern Flutter standards and avoid precision loss.

### Localization & Strings

- **Zero Hardcoding Policy**: Every string, including dialog messages and button labels, is defined
  in `AppStrings` and translated in `ar.json` and `en.json`.
- **Contextual Naming**: Strings are named by their function (e.g., `confirmCancelOrderMessage`)
  rather than their content to maintain clarity.

---

## 5. Map Integration (Sprint Readiness)

The feature is fully prepared for the Map sprint.

- **Navigation Payload**: The `NavigateToMapEvent` sends a comprehensive Map:
  ```dart
  final Map<String, dynamic> navigationPayload = {
    'targetLat': 30.123,
    'targetLong': 31.456,
    'locationType': LocationType.store,
    'order': orderEntity, // Full OrderEntity object
  };
  ```
- **UI Hooks**: `AddressInfoCard` is already wrapped in `InkWell` to trigger map navigation.

---

## AI Modification History

- **2026-06-24**:
  - Implemented communication features (Phone & WhatsApp) in `OrderDetailsScreen`.
  - Added `OpenCommunicationUseCase` in the Domain layer to handle external URL launching (`tel:` and `wa.me`).
  - Added `CallPhoneEvent` and `OpenWhatsAppEvent` to `OrderDetailsEvents`.
  - Updated `OrderDetailsCubit` to handle communication events using the new Use Case.
  - Linked `AddressInfoCard` action buttons (phone and chat icons) to trigger the communication events for both Store and User.
  - Added `url_launcher` dependency to `pubspec.yaml`.
  - Implemented `uiStep` logic (1-6) to synchronize detailed UI stages with simplified Backend
    states (`inProgress`/`completed`).
  - Standardized error handling using `UiEventHandler` for SnackBar and Dialog triggers.
  - Refactored `OrderDetailsCubit` to use nested `BaseState` for granular loading control (Main data
    vs. Dialog buttons).
  - Fixed critical initialization bugs using `Future.microtask`.
  - Integrated centralized `dialogThemeData` and `elevatedButtonTheme`.
  - Enforced `.withValues()` color standard and 100% localization.
- **2026-06-23**: Initial setup of Tracking Domain and Data layers.
