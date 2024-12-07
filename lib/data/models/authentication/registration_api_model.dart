class RegistrationApiModel {
  final String hotline;
  final String name;
  final String mst;
  final String address;
  final String brandEmail;
  final String userName;
  final String fullName;
  final String confirmPassword;
  final String password;
  final String email;

  RegistrationApiModel({
    required this.hotline,
    required this.name,
    required this.mst,
    required this.address,
    required this.brandEmail,
    required this.userName,
    required this.fullName,
    required this.confirmPassword,
    required this.password,
    required this.email,
  });

  Map<String, String> toMap() {
    return {
      'Hotline': hotline,
      'Name': name,
      'MST': mst,
      'Address': address,
      'BrandEmail': brandEmail,
      'UserName': userName,
      'FullName': fullName,
      'ConfirmPassword': confirmPassword,
      'Password': password,
      'Email': email,
    };
  }
}