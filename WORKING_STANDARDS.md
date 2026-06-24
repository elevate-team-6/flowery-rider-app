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

## 2. Model Standards (Mandatory)
- MUST use `json_serializable` for all models.
- Response models MUST have a `toEntity()` method to map data to the domain layer.
- NO business logic in models.

## 3. View Model (Cubit) & MVI Standards
- **Inheritance**: MUST extend `BaseCubit<State, BaseUiEvent>` from `lib/config/base_cubit/base_cubit.dart`.
- **State**: State classes MUST inherit from `BaseState<T>` from `lib/config/base_state/base_state.dart`.
- **Composite States (Mandatory for Complex Screens)**:
    - If a screen contains multiple independent operations (e.g., loading on a specific button, fetching details, submitting a form), the main State MUST contain nested `BaseState` objects (e.g., `detailsState`, `cancelState`, `submitState`).
    - This allows granular UI control, where only the affected part of the screen shows a loader or error without blocking the entire UI.
- **Events**: All UI actions must be defined in the `feature_events.dart` file using `sealed class`.
- **Method Structure**:
    - ONLY one public method: `void doEvent(FeatureEvents event)`.
    - All other methods MUST be `private` (starting with `_`).
    - **Logic Flows**: `Initialize` events should handle the full sequence of startup operations (e.g., calling a "Start" API followed by an "Update State" API) to ensure the system reaches a consistent state before user interaction.
    - Pattern inside methods:
        1. `emit(state.copyWith(...))` to update state.
        2. `emitUiEvent(...)` for side effects (Loading, Success, Error, Navigation).
- **Side Effects**: Mandatory use of `BaseUiEvent` for all UI interactions.

## 4. Screen & UI Standards
- **Zero Hardcoding**: NO hardcoded strings, colors, or dimensions.
- **Mandatory Utils**: 
    - Use `lib/core/utils/` for routes, strings, colors, and assets.
    - Use `ScreenUtil` for ALL dimensions (h, w, sp, r).
- **Strict Adherence to `AppTheme`**:
    - MANDATORY use of `AppTheme.mainTheme` for all component styling (Buttons, Dialogs, Inputs, Cards).
    - PROHIBITED to hardcode styling properties (padding, border radius, colors) in UI files if they are already defined in the global theme.
    - If a design requires a new global style, it MUST be added to `lib/core/utils/app_theme.dart` first.
- **Color & Opacity Standard**:
    - STRICT PROHIBITION of `withOpacity()`.
    - ALWAYS use `.withValues(alpha: ...)` for transparency to prevent precision loss and ensure compatibility with modern Flutter standards.
- **Side Effect Handling**: Screens MUST use `UiEventHandler` mixin from `lib/config/base_ui_handler/ui_event_handler_mixin.dart`.
- **File Size**: Screens MUST be split into small widgets located in the feature's `presentation/widgets/` folder.

## 5. Error Handling & Response Pattern
- **Centralized Handling**: Every API call in data sources MUST use `ErrorHandler.handleApiCall` from `lib/config/error_handler/error_handler.dart`.
- **Response Wrapper**: All repository and use case returns MUST use `BaseResponse<T>` from `lib/config/base_response/base_response.dart`.

## 6. General Rules
- **DI**: Use `@injectable` for all Cubits, Repos, and DataSources.
- **Logging**: NO `print()`. Use the `logger` package.
- **Strong Typing**: `dynamic` is forbidden.
- **Modern API Usage**: 
    - NEVER use deprecated Flutter/Dart APIs.
    - Always prefer `withValues()` over `withOpacity()`.
    - Ensure all code is compatible with the latest stable version of Flutter and Dart.
- **Clean Code**: Follow SOLID principles and keep methods small and focused.

## 7. Mandatory Feature Documentation (The "Docs" Rule)
Before starting ANY feature, the developer/AI MUST ensure there is a documentation file in `docs/feature_name.md`. If it doesn't exist, it MUST be created.
Each file MUST contain:
1. **Design**: Links/References to design images/Figma.
2. **API Details**: 
    - Full path for every endpoint.
    - Detailed Request body/params structure.
    - Detailed Response body structure.
3. **Business Requirements**: Detailed feature flow and logic requirements.
4. **AI Modification History**: A complete log of every change made by an AI model, including the date and the specific task performed.
5. **Dynamic Updates**: Any new information provided by the user MUST be immediately added to this document.

## 8. Testing Standards (MANDATORY)
- **Frameworks**: MUST use `mockito`, `flutter_test`, and `bloc_test`.
- **Organization**: Tests MUST be organized into `group()` blocks by function or event.
- **Coverage**: 
    - MUST test every possible state and side effect.
    - MUST cover all success and failure scenarios (including edge cases).
    - Cubit tests MUST use `blocTest` for state changes and `expectLater` for `eventStream` side effects.
- **Mocks**: Use `@GenerateMocks` for all dependencies (UseCases, CacheHelpers, etc.).

## 8. AI & Developer Execution Protocol (MANDATORY)
1. **Instruction Review**: MUST read the entire `WORKING_STANDARDS.md` and all feature files before starting any implementation.
2. **Implementation Plan**: BEFORE writing any code, MUST provide a granular, step-by-step plan of action and get EXPLICIT user approval.
3. **Execution**: ONLY start coding AFTER the user says "Proceed" or "Approved".
4. **Final Verification**: AFTER completion, MUST run `flutter analyze` to ensure ZERO errors and ZERO warnings.

---
> [!CAUTION]
> **COMPLIANCE IS NON-NEGOTIABLE.** Every line of code will be checked against this document.
