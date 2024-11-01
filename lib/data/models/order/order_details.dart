import 'dart:convert';

import 'package:flutter/foundation.dart';

class OrderDetail {
  final int id;
  final int petId;
  final String? serviceName;
  final String storeName;
  final String address;
  final int storeServiceId;
  final String paymentMethod;
  final int cost;
  final String description;
  final DateTime createDate;
  final DateTime startTime;
  final DateTime endTime;
  final bool checkin;
  final DateTime checkinTime;
  final String status;

  OrderDetail({
    required this.id,
    required this.petId,
    this.serviceName,
    required this.storeName,
    required this.address,
    required this.storeServiceId,
    required this.paymentMethod,
    required this.cost,
    required this.description,
    required this.createDate,
    required this.startTime,
    required this.endTime,
    required this.checkin,
    required this.checkinTime,
    required this.status,
  });

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id'] as int,
      petId: map['petId'] as int,
      serviceName: map['serviceName'] as String?,
      storeName: map['storeName'] as String,
      address: map['address'] as String,
      storeServiceId: map['storeServiceId'] as int,
      paymentMethod: map['paymentMethod'] as String,
      cost: map['cost'] as int,
      description: map['description'] as String,
      createDate: DateTime.parse(map['createDate'] as String),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      checkin: map['checkin'] as bool,
      checkinTime: DateTime.parse(map['checkinTime'] as String),
      status: map['status'] as String,
    );
  }
}
