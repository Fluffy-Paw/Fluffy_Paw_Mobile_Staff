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
  final double totalRating;
  final bool status;
  final String serviceTypeName;
  final List<Certificate> certificates;

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
    required this.certificates,
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
      totalRating: (map['totalRating'] ?? 0).toDouble(),
      status: map['status'] ?? false,
      serviceTypeName: map['serviceTypeName'] ?? '',
      certificates: (map['certificate'] as List?)
          ?.map((cert) => Certificate.fromMap(cert))
          .toList() ?? [],
    );
  }

  static List<ServiceModel> fromMapList(List<dynamic> list) {
    return list.map((item) => ServiceModel.fromMap(item)).toList();
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