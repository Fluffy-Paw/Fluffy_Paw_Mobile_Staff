class BookingModel {
  final int id;
  final String code;
  final String paymentMethod;
  final double cost;
  final String description;
  final DateTime createDate;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  BookingModel({
    required this.id,
    required this.code,
    required this.paymentMethod,
    required this.cost,
    required this.description,
    required this.createDate,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? 0,
      code: map['code'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      createDate: DateTime.parse(map['createDate'] ?? ''),
      startTime: DateTime.parse(map['startTime'] ?? ''),
      endTime: DateTime.parse(map['endTime'] ?? ''),
      status: map['status'] ?? '',
    );
  }
}

class StoreBookingModel {
  final int storeId;
  final double storeRevenue;
  final List<BookingModel> bookings;

  StoreBookingModel({
    required this.storeId,
    required this.storeRevenue,
    required this.bookings,
  });

  factory StoreBookingModel.fromMap(Map<String, dynamic> map) {
    return StoreBookingModel(
      storeId: map['storeId'] ?? 0,
      storeRevenue: (map['storeRevenue'] ?? 0).toDouble(),
      bookings: List<BookingModel>.from(
        (map['bookings'] ?? []).map((x) => BookingModel.fromMap(x)),
      ),
    );
  }
}