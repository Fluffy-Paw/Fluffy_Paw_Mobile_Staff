// Store Service model
class StoreService {
  final int id;
  final int storeId;
  final int serviceId;
  final DateTime startTime;
  final int limitPetOwner;
  final int currentPetOwner;
  final String status;

  StoreService({
    required this.id,
    required this.storeId,
    required this.serviceId,
    required this.startTime,
    required this.limitPetOwner,
    required this.currentPetOwner,
    required this.status,
  });

  factory StoreService.fromMap(Map<String, dynamic> map) => StoreService(
        id: map['id'] ?? 0,
        storeId: map['storeId'] ?? 0,
        serviceId: map['serviceId'] ?? 0,
        startTime: DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
        limitPetOwner: map['limitPetOwner'] ?? 0,
        currentPetOwner: map['currentPetOwner'] ?? 0,
        status: map['status'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'storeId': storeId,
        'serviceId': serviceId,
        'startTime': startTime.toIso8601String(),
        'limitPetOwner': limitPetOwner,
        'currentPetOwner': currentPetOwner,
        'status': status,
      };

  // Helper method to check if service is available
  bool get isAvailable => status == 'Available';

  // Helper method to calculate remaining spots
  int get remainingSpots => limitPetOwner - currentPetOwner;
}

// Response wrapper model
class StoreServiceResponse {
  final int statusCode;
  final String message;
  final List<StoreService> data;

  StoreServiceResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory StoreServiceResponse.fromMap(Map<String, dynamic> map) => StoreServiceResponse(
        statusCode: map['statusCode'] ?? 0,
        message: map['message'] ?? '',
        data: (map['data'] as List<dynamic>?)
                ?.map((e) => StoreService.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toMap() => {
        'statusCode': statusCode,
        'message': message,
        'data': data.map((e) => e.toMap()).toList(),
      };

  // Helper method to get available services
  List<StoreService> get availableServices => 
      data.where((service) => service.isAvailable).toList();

  // Helper method to get services for a specific date
  List<StoreService> getServicesForDate(DateTime date) {
    return data.where((service) => 
      service.startTime.year == date.year &&
      service.startTime.month == date.month &&
      service.startTime.day == date.day
    ).toList();
  }
}