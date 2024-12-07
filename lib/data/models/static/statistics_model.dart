class Statistics {
  final int numOfAll;
  final int numOfPending;
  final int numOfAccepted;
  final int numOfCanceled;
  final int numOfStores;
  final int numOfReports;
  final List<int> revenues;
  final List<TopService> topServices;

  Statistics({
    required this.numOfAll,
    required this.numOfPending,
    required this.numOfAccepted,
    required this.numOfCanceled,
    required this.numOfStores,
    required this.numOfReports,
    required this.revenues,
    required this.topServices,
  });

  factory Statistics.fromMap(Map<String, dynamic> map) {
    return Statistics(
      numOfAll: map['numOfAll'] ?? 0,
      numOfPending: map['numOfPending'] ?? 0,
      numOfAccepted: map['numOfAccepted'] ?? 0,
      numOfCanceled: map['numOfCanceled'] ?? 0,
      numOfStores: map['numOfStores'] ?? 0,
      numOfReports: map['numOfReports'] ?? 0,
      revenues: List<int>.from(map['revenues'] ?? []),
      topServices: List<TopService>.from(
        (map['topServices'] ?? []).map((x) => TopService.fromMap(x)),
      ),
    );
  }
}

class TopService {
  final int id;
  final String storeName;
  final String serviceName;
  final int numberOfBooking;

  TopService({
    required this.id,
    required this.storeName,
    required this.serviceName,
    required this.numberOfBooking,
  });

  factory TopService.fromMap(Map<String, dynamic> map) {
    return TopService(
      id: map['id'] ?? 0,
      storeName: map['storeName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      numberOfBooking: map['numberOfBooking'] ?? 0,
    );
  }
}
