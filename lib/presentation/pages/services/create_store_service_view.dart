import 'package:fluffypawsm/data/models/service/create_store.dart';
import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/presentation/pages/services/layouts/create_store_service_layout.dart';
import 'package:flutter/material.dart';

class StoreServiceView extends StatelessWidget {
  final int serviceId;
  final CreateScheduleRequest? scheduleToEdit;
  final Function(CreateScheduleRequest)? onUpdate;
  
  const StoreServiceView({
    Key? key,
    required this.serviceId,
    this.scheduleToEdit,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreServiceFormLayout(
      serviceId: serviceId,
      scheduleToEdit: scheduleToEdit,
      onUpdate: onUpdate,
    );
  }
}