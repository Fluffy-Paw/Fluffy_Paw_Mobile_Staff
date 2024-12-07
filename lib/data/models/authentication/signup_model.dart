class SignUpModel {
  final String userName;
  final String fullName;
  final String password;
  final String confirmPassword;
  final String email;
  final String storeName;
  final String mst;
  final String address;
  final String hotline;
  final String brandEmail;

  SignUpModel({
    required this.userName,
    required this.fullName,
    required this.password,
    required this.confirmPassword,
    required this.email,
    required this.storeName,
    required this.mst,
    required this.address,
    required this.hotline,
    required this.brandEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserName': userName,
      'FullName': fullName,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'Email': email,
      'Name': storeName,
      'MST': mst,
      'Address': address,
      'Hotline': hotline,
      'BrandEmail': brandEmail,
    };
  }

  factory SignUpModel.fromMap(Map<String, dynamic> map) {
    return SignUpModel(
      userName: map['UserName'] ?? '',
      fullName: map['FullName'] ?? '',
      password: map['Password'] ?? '',
      confirmPassword: map['ConfirmPassword'] ?? '',
      email: map['Email'] ?? '',
      storeName: map['Name'] ?? '',
      mst: map['MST'] ?? '',
      address: map['Address'] ?? '',
      hotline: map['Hotline'] ?? '',
      brandEmail: map['BrandEmail'] ?? '',
    );
  }
}