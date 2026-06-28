# Flowery Rider - EXTREMELY STRICT WORKING STANDARDS

This document defines the ONLY allowed way to write code in this project. Deviation from these rules is strictly prohibited and will result in immediate rejection of the code.

## 1. Mandatory 4-Layer Architecture
Every feature MUST be divided into exactly these 4 layers with these exact folder names:
1. `api/`: 
    - `api_client/`: Retrofit client (e.g., `feature_api_client.dart`).
    - `data_sources/`: Implementation of remote data source (e.g., `feature_remote_data_source_impl.dart`).
2. `data/`:
    - `data_sources/`: Contracts/Interfaces for data sources.
    - `models/`: 
        - `request/`: Request DTOs.
        - `response/`: Response DTOs (MUST include `toEntity()` method).
    - `repo/`: Implementation of repository contracts.
3. `domain/`:
    - `entities/`: Pure Dart entities.
    - `repo/`: Repository contracts (abstract interfaces).
    - `use_cases/`: Use case classes with a single `call` method.
4. `presentation/`:
    - `screens/`: Feature screens (Widgets).
    - `view_model/`: 
        - `feature_cubit.dart`
        - `feature_events.dart`
        - `feature_states.dart`
    - `widgets/`: Feature-specific reusable widgets (to keep screen files small).

## 2. Model Standards & Mapping (Mandatory)
- MUST use `json_serializable` for all models.
- Response models MUST have a `toEntity()` method to map data to the domain layer.
- **Boundary Rule (Strict Data Validation)**:
    - ALL null-handling MUST happen inside the `toEntity()` method.
    - If a mandatory field from the server is `null`, `toEntity()` MUST throw an `Exception` (e.g., `throw Exception("Order ID is required")`).
    - Optional fields MUST be assigned **Safe Defaults** (e.g., `""`, `0`, `[]`, `const PlaceholderEntity()`).
    - The `toEntity()` method is the ONLY place allowed to handle raw server nullability.
- **Model Organization**: Every Model/Response Class MUST be in its own separate file.
- NO business logic in models.

## 3. Domain Entity Standards (The "No-Null" Policy)
- **Zero Nullability**: ALL fields in a Domain Entity MUST be **non-nullable** and **required**.
- **Pure Dart**: Entities MUST be pure Dart classes. No `@JsonSerializable` or framework annotations.
- **Immutability**: MUST extend `Equatable` and use `final` fields.
- **Manual Helpers**: If caching is needed, add manual `toJson()` and `factory .fromJson()` methods to the Entity to keep it pure but functional for storage (Hive).
- **Separation**: Every Entity MUST be in its own separate file.

## 4. View Model (Cubit) & MVI Standards
- **Inheritance**: MUST extend `BaseCubit<State, BaseUiEvent>` from `lib/config/base_cubit/base_cubit.dart`.
- **Composite States**: Use nested `BaseState` (e.g., `detailsState`, `cancelState`) for granular UI control.
- **Logic Flows**: `Initialize` events should handle the full sequence of startup operations.
- **Safety First**: NEVER use the null-assertion operator `!` on `state.data`. Always use `if (state.data == null) return;`.
- **Side Effects**: Mandatory use of `BaseUiEvent` for all UI interactions.

## 5. Screen & UI Standards (Zero Tolerance for Null logic)
- **Clean UI Logic**: Since Entities are non-nullable, UI code MUST NOT contain null-checks (`?`), null-aware operators (`??`), or assertions (`!`) when accessing Entity properties.
- **Bloc Optimization (Mandatory)**: 
    - `BlocBuilder` MUST ONLY wrap the specific widget(s) that require rebuilding. NEVER wrap a whole screen or large static layouts with a generic `BlocBuilder`.
    - MANDATORY use of `buildWhen`: Every `BlocBuilder` MUST implement `buildWhen` to prevent unnecessary rebuilds by filtering for specific state changes (e.g., `previous.status != current.status`).
- **Zero Hardcoding**: NO hardcoded strings, colors, or dimensions. Use `lib/core/utils/`.
- **Dimensions**: ALWAYS use `ScreenUtil` (h, w, sp, r).
- **Themes**: MANDATORY use of `AppTheme.mainTheme`. Prohibited to hardcode padding/radius/colors in UI.
- **Modern Standards**: ALWAYS use `.withValues(alpha: ...)` instead of `withOpacity()`.
- **Side Effect Handling**: Screens MUST use `UiEventHandler` mixin.

## 6. Error Handling & Response Pattern
- **Centralized Handling**: Every API call in data sources MUST use `ErrorHandler.handleApiCall`.
- **Response Wrapper**: All repository and use case returns MUST use `BaseResponse<T>`.
- **Repository Mapping Safety (Mandatory)**: 
    - Repositories MUST wrap the `toEntity()` call inside a `try-catch` block.
    - If `toEntity()` throws an exception due to missing mandatory data, the Repository MUST catch it and return an `ErrorBaseResponse` with a descriptive message.
    - This ensures that the UI never stays in a loading state if a mapping error occurs.

## 7. General Rules & DI
- **DI**: Use `@injectable` for all Cubits, Repos, and DataSources.
- **Strong Typing**: `dynamic` is strictly forbidden.
- **Clean Code**: Follow SOLID principles. Keep methods small and focused.
- **No ! Operator**: Usage of the `!` operator on Domain Entities in the Presentation layer is prohibited.

## 8. Mandatory Feature Documentation (The "Docs" Rule)
Before starting ANY feature, a documentation file MUST be created in `docs/feature_name.md`. It must include API details, business logic, and an **AI Modification History**.

## 9. Testing Standards (MANDATORY)
- MUST use `mockito`, `flutter_test`, and `bloc_test`.
- MUST cover all success and failure scenarios (including edge cases where `toEntity()` throws exceptions).
- Cubit tests MUST use `blocTest` for state changes and `expectLater` for side effects.

## 10. AI & Developer Execution Protocol (MANDATORY)
1. **Instruction Review**: MUST read the entire `WORKING_STANDARDS.md` before starting.
2. **Implementation Plan**: MUST provide a step-by-step plan and get EXPLICIT user approval.
3. **Final Verification**: MUST run `flutter analyze` to ensure ZERO errors and ZERO warnings.

---
> [!CAUTION]
> **COMPLIANCE IS NON-NEGOTIABLE.** Any code containing nullable entities or null-logic in UI will be REJECTED.
