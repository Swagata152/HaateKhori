
class GlobalVariables {
  // Singleton instance
  static final GlobalVariables _instance = GlobalVariables._internal();

  // Global variable
  String userId = "";

  // Private constructor for the singleton pattern
  GlobalVariables._internal();

  // Getter to access the instance
  factory GlobalVariables() {
    return _instance;
  }
}