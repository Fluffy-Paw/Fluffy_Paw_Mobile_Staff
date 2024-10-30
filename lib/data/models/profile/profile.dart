class User {
  final int id;
  final int accountId;
  final String username;
  final int brandId;
  final String brandName;
  final String logo;
  final String name;
  final String address;
  final String phone;
  final int totalRating;
  final bool status;
  final Account account;

  User({
    required this.id,
    required this.accountId,
    required this.username,
    required this.brandId,
    required this.brandName,
    required this.logo,
    required this.name,
    required this.address,
    required this.phone,
    required this.totalRating,
    required this.status,
    required this.account,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      accountId: map['accountId'],
      username: map['username'],
      brandId: map['brandId'],
      brandName: map['brandName'],
      logo: map['logo'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      totalRating: map['totalRating'],
      status: map['status'],
      account: Account.fromMap(map['account']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'username': username,
      'brandId': brandId,
      'brandName': brandName,
      'logo': logo,
      'name': name,
      'address': address,
      'phone': phone,
      'totalRating': totalRating,
      'status': status,
      'account': account.toMap(),
    };
  }
}

class Account {
  final int id;
  final String username;
  final String password;
  final String avatar;
  final String roleName;
  final String email;
  final String createDate;
  final int status;

  Account({
    required this.id,
    required this.username,
    required this.password,
    required this.avatar,
    required this.roleName,
    required this.email,
    required this.createDate,
    required this.status,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      avatar: map['avatar'],
      roleName: map['roleName'],
      email: map['email'],
      createDate: map['createDate'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'avatar': avatar,
      'roleName': roleName,
      'email': email,
      'createDate': createDate,
      'status': status,
    };
  }
}
