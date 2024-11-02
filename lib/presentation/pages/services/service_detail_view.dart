import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/presentation/pages/services/layouts/service_details_layout.dart';
import 'package:flutter/material.dart';

class ServiceDetailView extends StatelessWidget {
  final Service riderInfo;
  const ServiceDetailView({
    Key? key,
    required this.riderInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiceDetailsLayout(
      service: riderInfo,
    );
  }
}