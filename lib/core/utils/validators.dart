/// Form and input validation functions matching the visitor management specification.
class Validators {
  static final RegExp _mobileRegex = RegExp(r'^[0-9]{10}$');
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates visitor name (required).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Visitor name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates mobile number: required, exactly 10 numeric digits.
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final trimmed = value.trim();
    if (!_mobileRegex.hasMatch(trimmed)) {
      return 'Mobile number must be exactly 10 numeric digits';
    }
    return null;
  }

  /// Validates email address: optional, but must be valid format if entered.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates purpose of visit (required).
  static String? validatePurpose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Purpose of visit is required';
    }
    if (value.trim().length < 3) {
      return 'Purpose must be at least 3 characters';
    }
    return null;
  }

  /// Validates dropdown selection (visitor type or project).
  static String? validateRequiredSelection(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a $fieldName';
    }
    return null;
  }

  /// Validates QR code payload (must be non-empty visitor ID string).
  static String? validateQrPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return 'Scanned payload is empty';
    }
    return null;
  }
}
