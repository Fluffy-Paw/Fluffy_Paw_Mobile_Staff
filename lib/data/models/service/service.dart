// Certificate model
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

  factory Certificate.fromMap(Map<String, dynamic> map) => Certificate(
        id: map['id'] ?? 0,
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        file: map['file'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'file': file,
      };
}

// Service model
class Service {
  final int id;
  final int serviceTypeId;
  final int brandId;
  final String name;
  final String image;
  final String duration;
  final double cost;
  final String description;
  final int bookingCount;
  final int totalRating;
  final bool status;
  final String serviceTypeName;
  final List<Certificate> certificate;

  Service({
    required this.id,
    required this.serviceTypeId,
    required this.brandId,
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

  factory Service.fromMap(Map<String, dynamic> map) => Service(
        id: map['id'] ?? 0,
        serviceTypeId: map['serviceTypeId'] ?? 0,
        brandId: map['brandId'] ?? 0,
        name: map['name'] ?? '',
        image: map['image'] ?? '',
        duration: map['duration'] ?? '',
        cost: (map['cost'] ?? 0).toDouble(),
        description: map['description'] ?? '',
        bookingCount: map['bookingCount'] ?? 0,
        totalRating: map['totalRating'] ?? 0,
        status: map['status'] ?? false,
        serviceTypeName: map['serviceTypeName'] ?? '',
        certificate: (map['certificate'] as List<dynamic>?)
                ?.map((e) => Certificate.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'serviceTypeId': serviceTypeId,
        'brandId': brandId,
        'name': name,
        'image': image,
        'duration': duration,
        'cost': cost,
        'description': description,
        'bookingCount': bookingCount,
        'totalRating': totalRating,
        'status': status,
        'serviceTypeName': serviceTypeName,
        'certificate': certificate.map((e) => e.toMap()).toList(),
      };
}

// Response wrapper model
class ServiceResponse {
  final int statusCode;
  final String message;
  final List<Service> data;

  ServiceResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ServiceResponse.fromMap(Map<String, dynamic> map) => ServiceResponse(
        statusCode: map['statusCode'] ?? 0,
        message: map['message'] ?? '',
        data: (map['data'] as List<dynamic>?)
                ?.map((e) => Service.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toMap() => {
        'statusCode': statusCode,
        'message': message,
        'data': data.map((e) => e.toMap()).toList(),
      };
}