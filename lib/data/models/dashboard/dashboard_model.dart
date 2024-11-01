import 'dart:convert';

import 'package:flutter/foundation.dart';

class DashboardInfo {
  final int todayOrders;
  final String todayEarning;
  final String thisMonthEarnings;
  final int processingOrders;
  final List<Order> orders;
  final int acceptedOrders;
  final int pendingOrders;
  final int canceledOrders;
  final int deniedOrders;
  final int overTimeOrders;
  final int endedOrders;

  DashboardInfo({
    required this.todayOrders,
    required this.todayEarning,
    required this.thisMonthEarnings,
    required this.processingOrders,
    required this.orders,
    required this.acceptedOrders,
    required this.pendingOrders,
    required this.canceledOrders,
    required this.deniedOrders,
    required this.overTimeOrders,
    required this.endedOrders,
  });

  DashboardInfo copyWith({
    int? todayOrders,
    String? todayEarning,
    String? thisMonthEarnings,
    int? processingOrders,
    List<Order>? orders,
    int? acceptedOrders,
    int? pendingOrders,
    int? canceledOrders,
    int? deniedOrders,
    int? overTimeOrders,
    int? endedOrders,
  }) {
    return DashboardInfo(
      todayOrders: todayOrders ?? this.todayOrders,
      todayEarning: todayEarning ?? this.todayEarning,
      thisMonthEarnings: thisMonthEarnings ?? this.thisMonthEarnings,
      processingOrders: processingOrders ?? this.processingOrders,
      orders: orders ?? this.orders,
      acceptedOrders: acceptedOrders ?? this.acceptedOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      canceledOrders: canceledOrders ?? this.canceledOrders,
      deniedOrders: deniedOrders ?? this.deniedOrders,
      overTimeOrders: overTimeOrders ?? this.overTimeOrders,
      endedOrders: endedOrders ?? this.endedOrders,
    );
  }
  factory DashboardInfo.empty() {
  return DashboardInfo(
    todayOrders: 0,
    todayEarning: "0",
    thisMonthEarnings: "0",
    processingOrders: 0,
    orders: [],
    acceptedOrders: 0,
    pendingOrders: 0,
    canceledOrders: 0,
    deniedOrders: 0,
    overTimeOrders: 0,
    endedOrders: 0,
  );
}

  static int countOrdersByStatus(List<Order> orders, String status) {
    return orders.where((order) => order.status == status).length;
  }

  static int calculateTodayEarnings(List<Order> orders) {
    final today = DateTime.now();
    return orders.where((order) {
      return order.createDate.year == today.year &&
          order.createDate.month == today.month &&
          order.createDate.day == today.day;
    }).fold(0, (total, order) => total + order.cost);
  }

  static int calculateThisMonthEarnings(List<Order> orders) {
    final today = DateTime.now();
    return orders.where((order) {
      return order.createDate.year == today.year &&
          order.createDate.month == today.month;
    }).fold(0, (total, order) => total + order.cost);
  }

  static int calculateTodayOrders(List<Order> orders) {
    final today = DateTime.now();
    return orders.where((order) {
      return order.createDate.year == today.year &&
          order.createDate.month == today.month &&
          order.createDate.day == today.day;
    }).length;
  }

  static int calculatePendingOrders(List<Order> orders) {
    return countOrdersByStatus(orders, 'Pending');
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'today_orders': todayOrders,
      'today_earning': todayEarning,
      'this_month_earnings': thisMonthEarnings,
      'processing_orders': processingOrders,
      'accepted_orders': acceptedOrders,
      'pending_orders': pendingOrders,
      'canceled_orders': canceledOrders,
      'denied_orders': deniedOrders,
      'over_time_orders': overTimeOrders,
      'ended_orders': endedOrders,
      'orders': orders.map((x) => x.toMap()).toList(),
    };
  }

  factory DashboardInfo.fromMap(Map<String, dynamic> map) {
    if (map['data'] is List) {
      final List<Order> orders = (map['data'] as List)
          .map((orderMap) => Order.fromMap(orderMap as Map<String, dynamic>))
          .toList();

      final todayOrders = calculateTodayOrders(orders);
      final processingOrders = calculatePendingOrders(orders);
      final todayEarning = calculateTodayEarnings(orders).toString();
      final thisMonthEarnings = calculateThisMonthEarnings(orders).toString();

      final acceptedOrders = countOrdersByStatus(orders, 'Accepted');
      final pendingOrders = countOrdersByStatus(orders, 'Pending');
      final canceledOrders = countOrdersByStatus(orders, 'Canceled');
      final deniedOrders = countOrdersByStatus(orders, 'Denied');
      final overTimeOrders = countOrdersByStatus(orders, 'OverTime');
      final endedOrders = countOrdersByStatus(orders, 'Ended');

      return DashboardInfo(
        todayOrders: todayOrders,
        todayEarning: todayEarning,
        thisMonthEarnings: thisMonthEarnings,
        processingOrders: processingOrders,
        orders: orders,
        acceptedOrders: acceptedOrders,
        pendingOrders: pendingOrders,
        canceledOrders: canceledOrders,
        deniedOrders: deniedOrders,
        overTimeOrders: overTimeOrders,
        endedOrders: endedOrders,
      );
    } else {
      throw Exception("Expected a List<dynamic> but got something else.");
    }
  }

  String toJson() => json.encode(toMap());

  factory DashboardInfo.fromJson(String source) =>
      DashboardInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DashboardInfo(today_orders: $todayOrders, today_earning: $todayEarning, this_month_earnings: $thisMonthEarnings, processing_orders: $processingOrders, accepted_orders: $acceptedOrders, pending_orders: $pendingOrders, canceled_orders: $canceledOrders, denied_orders: $deniedOrders, over_time_orders: $overTimeOrders, ended_orders: $endedOrders, orders: $orders)';
  }

  @override
  bool operator ==(covariant DashboardInfo other) {
    if (identical(this, other)) return true;

    return other.todayOrders == todayOrders &&
        other.todayEarning == todayEarning &&
        other.thisMonthEarnings == thisMonthEarnings &&
        other.processingOrders == processingOrders &&
        other.acceptedOrders == acceptedOrders &&
        other.pendingOrders == pendingOrders &&
        other.canceledOrders == canceledOrders &&
        other.deniedOrders == deniedOrders &&
        other.overTimeOrders == overTimeOrders &&
        other.endedOrders == endedOrders &&
        listEquals(other.orders, orders);
  }

  @override
  int get hashCode {
    return todayOrders.hashCode ^
        todayEarning.hashCode ^
        thisMonthEarnings.hashCode ^
        processingOrders.hashCode ^
        acceptedOrders.hashCode ^
        pendingOrders.hashCode ^
        canceledOrders.hashCode ^
        deniedOrders.hashCode ^
        overTimeOrders.hashCode ^
        endedOrders.hashCode ^
        orders.hashCode;
  }
}



class Order {
  final int id;
  final String fullName;
  final String phone;
  final String serviceName;
  final DateTime createDate;
  final DateTime startTime;
  final String status;
  final String paymentMethod;
  final int cost; 

  Order({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.serviceName,
    required this.createDate,
    required this.startTime,
    required this.status,
    required this.cost, 
    required this.paymentMethod
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'serviceName': serviceName,
      'createDate': createDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'status': status,
      'cost': cost, 
      'paymentMethod': paymentMethod
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
      serviceName: map['serviceName'] as String,
      createDate: DateTime.parse(map['createDate'] as String),
      startTime: DateTime.parse(map['startTime'] as String),
      status: map['status'] as String,
      paymentMethod: map['paymentMethod'] as String,
      cost: map['cost'] as int, // Ánh xạ trường cost từ response JSON
    );
  }
}

