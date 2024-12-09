class ServiceModel {
  final int id;
  final int serviceTypeId;
  final int brandId;
  final String brandName;
  final String name;
  final int revenue;
  final String image;
  final String duration;
  final int cost;
  final String description;
  final int bookingCount;
  final double totalRating;  // Changed to double
  final bool status;
  final String serviceTypeName;
  final List<Certificate> certificate;

  ServiceModel({
    required this.id,
    required this.serviceTypeId,
    required this.brandId,
    required this.brandName,
    required this.name,
    required this.revenue,
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
      revenue: map['revenue'] ?? 0,
      image: map['image'] ?? '',
      duration: map['duration'] ?? '',
      cost: map['cost'] ?? 0,
      description: map['description'] ?? '',
      bookingCount: map['bookingCount'] ?? 0,
      totalRating: (map['totalRating'] ?? 0).toDouble(), // Convert to double here
      status: map['status'] ?? false,
      serviceTypeName: map['serviceTypeName'] ?? '',
      certificate: map['certificate'] != null
          ? List<Certificate>.from(
              map['certificate'].map((x) => Certificate.fromMap(x)))
          : [],
    );
  }

  static List<ServiceModel> fromMapList(List<dynamic> list) {
    return List<ServiceModel>.from(list.map((map) => ServiceModel.fromMap(map)));
  }
}

class Certificate {
  final int id;
  final String name;
  final String description;
  final String file;

  Certificate({
    required this.id,
    required this.name,
    required this.description,
    required this.file,
  });

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      file: map['file'] ?? '',
    );
  }
  static List<Certificate> fromMapList(List<dynamic> list) {
    return list.map((item) => Certificate.fromMap(item)).toList();
  }
}