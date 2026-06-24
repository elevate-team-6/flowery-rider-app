# Feature: Authentication (Auth)

## Design
- *[Links to design assets should be placed here]*

## API Details

### Sign In
- **Path**: `/auth/signin`
- **Method**: `POST`
- **Request**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "message": "string",
    "token": "string"
  }
  ```

### Forget Password
- **Path**: `/auth/forgotPassword`
- **Method**: `POST`
- **Request**: `{"email": "string"}`
- **Response**: Standard forget password response.

### Verify Reset Code
- **Path**: `/auth/verifyResetCode`
- **Method**: `POST`
- **Request**: `{"resetCode": "string"}`

### Reset Password
- **Path**: `/auth/resetPassword`
- **Method**: `PUT`
- **Request**: `{"email": "string", "newPassword": "string"}`

## Business Requirements
- Support "Remember Me" functionality using secure storage.
- Support password visibility toggling.
- Handle 3-step forget password flow (Email -> OTP -> Reset).
- Centralized error handling for all API calls.

## AI Modification History
- **2026-06-23**: Initial documentation created by AI and standards finalized.
