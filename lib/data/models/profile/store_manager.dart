class StoreManagerProfileModel {
  final int id;
  final int accountId;
  final String fullName;
  final DateTime createDate;
  final String name;
  final String logo;
  final String hotline;
  final String brandEmail;
  final String businessLicense;
  final String mst;
  final bool status;
  final String front;
  final String back;

  StoreManagerProfileModel({
    required this.id,
    required this.accountId,
    required this.fullName,
    required this.createDate,
    required this.name,
    required this.logo,
    required this.hotline,
    required this.brandEmail,
    required this.businessLicense,
    required this.mst,
    required this.status,
    required this.front,
    required this.back,
  });

  factory StoreManagerProfileModel.fromMap(Map<String, dynamic> json) {
    return StoreManagerProfileModel(
      id: json['id'],
      accountId: json['accountId'],
      fullName: json['fullName'],
      createDate: DateTime.parse(json['createDate']),
      name: json['name'],
      logo: json['logo'],
      hotline: json['hotline'],
      brandEmail: json['brandEmail'],
      businessLicense: json['businessLicense'],
      mst: json['mst'],
      status: json['status'],
      front: json['front'],
      back: json['back'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'fullName': fullName,
      'createDate': createDate.toIso8601String(),
      'name': name,
      'logo': logo,
      'hotline': hotline,
      'brandEmail': brandEmail,
      'businessLicense': businessLicense,
      'mst': mst,
      'status': status,
      'front': front,
      'back': back,
    };
  }
}
