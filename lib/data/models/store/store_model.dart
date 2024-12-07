class StoreModel {
  final int id;
  final int accountId;
  final String username;
  final int brandId;
  final String brandName;
  final String logo;
  final String name;
  final String operatingLicense;
  final String address;
  final String phone;
  final double totalRating;
  final bool status;
  final AccountModel account;
  final List<FileModel> files;

  StoreModel({
    required this.id,
    required this.accountId,
    required this.username,
    required this.brandId,
    required this.brandName,
    required this.logo,
    required this.name,
    required this.operatingLicense,
    required this.address,
    required this.phone,
    required this.totalRating,
    required this.status,
    required this.account,
    required this.files,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] ?? 0,
      accountId: map['accountId'] ?? 0,
      username: map['username'] ?? '',
      brandId: map['brandId'] ?? 0,
      brandName: map['brandName'] ?? '',
      logo: map['logo'] ?? '',
      name: map['name'] ?? '',
      operatingLicense: map['operatingLicense'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      totalRating: (map['totalRating'] ?? 0).toDouble(),
      status: map['status'] ?? false,
      account: AccountModel.fromMap(map['account'] ?? {}),
      files: List<FileModel>.from(
        (map['files'] ?? []).map((x) => FileModel.fromMap(x)),
      ),
    );
  }

  static List<StoreModel> fromMapList(List<dynamic> list) {
    return list.map((item) => StoreModel.fromMap(item)).toList();
  }
}

class AccountModel {
  final int id;
  final String username;
  final String password;
  final String avatar;
  final String roleName;
  final String email;
  final DateTime createDate;
  final int status;

  AccountModel({
    required this.id,
    required this.username,
    required this.password,
    required this.avatar,
    required this.roleName,
    required this.email,
    required this.createDate,
    required this.status,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] ?? 0,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      avatar: map['avatar'] ?? '',
      roleName: map['roleName'] ?? '',
      email: map['email'] ?? '',
      createDate: DateTime.parse(map['createDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 0,
    );
  }
}

class FileModel {
  final int id;
  final String file;
  final DateTime createDate;
  final bool status;

  FileModel({
    required this.id,
    required this.file,
    required this.createDate,
    required this.status,
  });

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'] ?? 0,
      file: map['file'] ?? '',
      createDate: DateTime.parse(map['createDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? false,
    );
  }
}