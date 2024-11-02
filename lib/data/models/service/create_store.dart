class CreateStoreServiceRequest {
  final int serviceId;
  final List<CreateScheduleRequest> createScheduleRequests;

  CreateStoreServiceRequest({
    required this.serviceId,
    required this.createScheduleRequests,
  });

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'createScheduleRequests': createScheduleRequests.map((x) => x.toJson()).toList(),
  };
}
class CreateScheduleRequest {
  final DateTime startTime;
  final int limitPetOwner;

  CreateScheduleRequest({
    required this.startTime,
    required this.limitPetOwner,
  });

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toUtc().toIso8601String(),
    'limitPetOwner': limitPetOwner,
  };
}