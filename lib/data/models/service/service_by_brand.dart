class ServiceModel {
  final int id;
  final int serviceTypeId;
  final int brandId;
  final String brandName;
  final String name;
  final String image;
  final String duration;
  final double cost;
  final String description;
  final int bookingCount;
  final int totalRating;
  final bool status;
  final String serviceTypeName;
  final List<dynamic> certificate;

  ServiceModel({
    required this.id,
    required this.serviceTypeId,
    required this.brandId,
    required this.brandName,
    required this.name,
    required this.image,
    required this.duration,
    required this.cost,
    required this.description,
    required this.bookingCount,
    required this.totalRating,
    required this.status,
    required this.serviceTypeName,
    required this.certificate,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? 0,
      serviceTypeId: map['serviceTypeId'] ?? 0,
      brandId: map['brandId'] ?? 0,
      brandName: map['brandName'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      duration: map['duration'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      bookingCount: map['bookingCount'] ?? 0,
      totalRating: map['totalRating'] ?? 0,
      status: map['status'] ?? false,
      serviceTypeName: map['serviceTypeName'] ?? '',
      certificate: map['certificate'] ?? [],
    );
  }

  static List<ServiceModel> fromMapList(List<dynamic> list) {
    return list.map((item) => ServiceModel.fromMap(item)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceTypeId': serviceTypeId,
      'brandId': brandId,
      'brandName': brandName,
      'name': name,
      'image': image,
      'duration': duration,
      'cost': cost,
      'description': description,
      'bookingCount': bookingCount,
      'totalRating': totalRating,
      'status': status,
      'serviceTypeName': serviceTypeName,
      'certificate': certificate,
    };
  }
}