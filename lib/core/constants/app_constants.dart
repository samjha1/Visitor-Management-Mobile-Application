/// Central application constants and fixed enumerations
class AppConstants {
  // Visitor Types
  static const String visitorTypeCustomer = 'Customer';
  static const String visitorTypeVendor = 'Vendor';
  static const String visitorTypeOther = 'Other';

  static const List<String> visitorTypes = [
    visitorTypeCustomer,
    visitorTypeVendor,
    visitorTypeOther,
  ];

  // Real Estate Projects
  static const String projectA = 'Project A';
  static const String projectB = 'Project B';
  static const String projectC = 'Project C';

  static const List<String> projects = [
    projectA,
    projectB,
    projectC,
  ];

  // Visitor Statuses
  static const String statusRegistered = 'Registered';
  static const String statusCheckedIn = 'Checked In';
  static const String statusCheckedOut = 'Checked Out';

  static const List<String> statuses = [
    statusRegistered,
    statusCheckedIn,
    statusCheckedOut,
  ];

  // API Endpoints
  static const String visitorsEndpoint = '/visitors';
}
