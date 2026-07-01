# Tracking Feature Documentation

## Design
- TBD (Refer to Figma/Design assets)

## API Details
- **Get Pending Orders**: `/api/v1/orders/pending`
- **Start Order**: `/api/v1/orders/{id}/start`
- **Update Order State**: `/api/v1/orders/{id}/state`

## Business Requirements
- Rider can view pending orders.
- Rider can accept an order to see details.
- Rider follows a multi-step process (Pickup, Delivery).
- All domain entities must be non-nullable to ensure data integrity after the data layer.

## AI Modification History
### 2026-06-28
- **Task**: Implement Strict Null Handling and Non-nullable Entities.
- **Changes**:
    - Modified `OrderEntity` and all related child entities in `domain/entities/order_entity.dart` to be fully non-nullable and removed `json_serializable` dependencies to make them Pure Dart Entities.
    - Added manual `toJson` to `OrderEntity` and children to support caching in Presentation layer without external annotations.
    - Updated `toEntity()` in all relevant Response Models (`UserModel`, `StoreModel`, `TrackingOrderModel`, etc.) to enforce mandatory fields (throwing Exceptions if null) and provide safe defaults for optional fields.
    - Cleaned up `HomeCubit`, `OrderDetailsCubit`, `OrderDetailsScreen`, and related widgets by removing redundant null checks (`?`, `??`, `!`).
    - Verified compliance with `WORKING_STANDARDS.md`.
