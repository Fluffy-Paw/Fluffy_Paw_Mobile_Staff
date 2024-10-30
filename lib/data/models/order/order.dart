import 'dart:convert';

import 'package:flutter/foundation.dart';

class OrderModel {
  final int total;
  final List<Order> orders;
  OrderModel({
    required this.total,
    required this.orders,
  });

  OrderModel copyWith({
    int? total,
    List<Order>? orders,
  }) {
    return OrderModel(
      total: total ?? this.total,
      orders: orders ?? this.orders,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'orders': orders.map((x) => x.toMap()).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      total: map['total'].toInt() as int,
      orders: List<Order>.from(
        (map['orders'] as List<dynamic>).map<Order>(
              (x) => Order.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OrderModel(total: $total, orders: $orders)';

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;

    return other.total == total && listEquals(other.orders, orders);
  }

  @override
  int get hashCode => total.hashCode ^ orders.hashCode;
}

class Order {
  final int id;
  final String orderCode;
  final double payableAmount;
  final String orderStatus;
  final String paymentType;
  final String paymentStatus;
  final String pickDate;
  final String deliveryDate;
  final String orderedAt;
  //final int items;
  final String userName;
  final String userMobile;
  final String userProfile;
  final String address;
  final List<Product> products;
  final String? invoicePath;
  Order({
    required this.id,
    required this.orderCode,
    required this.payableAmount,
    required this.orderStatus,
    required this.paymentType,
    required this.paymentStatus,
    required this.pickDate,
    required this.deliveryDate,
    required this.orderedAt,
    //required this.items,
    required this.userName,
    required this.userMobile,
    required this.userProfile,
    required this.address,
    required this.products,
    required this.invoicePath,
  });

  Order copyWith({
    int? id,
    String? orderCode,
    double? payableAmount,
    String? orderStatus,
    String? paymentType,
    String? paymentStatus,
    String? pickDate,
    String? deliveryDate,
    String? orderedAt,
    //int? items,
    String? userName,
    String? userMobile,
    String? userProfile,
    String? address,
    List<Product>? products,
    String? invoicePath,
  }) {
    return Order(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      payableAmount: payableAmount ?? this.payableAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentType: paymentType ?? this.paymentType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pickDate: pickDate ?? this.pickDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderedAt: orderedAt ?? this.orderedAt,
      //items: items ?? this.items,
      userName: userName ?? this.userName,
      userMobile: userMobile ?? this.userMobile,
      userProfile: userProfile ?? this.userProfile,
      address: address ?? this.address,
      products: products ?? this.products,
      invoicePath: invoicePath ?? this.invoicePath,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'order_code': orderCode,
      'payable_amount': payableAmount,
      'order_status': orderStatus,
      'payment_type': paymentType,
      'payment_status': paymentStatus,
      'pick_date': pickDate,
      'delivery_date': deliveryDate,
      'ordered_at': orderedAt,
      //'items': items,
      'user_name': userName,
      'user_mobile': userMobile,
      'user_profile': userProfile,
      'address': address,
      'products': products.map((x) => x.toMap()).toList(),
      'invoicePath': invoicePath,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? 0, // Giá trị mặc định là 0 nếu null
      orderCode: map['orderCode'] ?? '', // Giá trị mặc định là chuỗi rỗng nếu null
      orderStatus: map['orderStatus'] ?? 'Unknown', // Giá trị mặc định là 'Unknown' nếu null
      payableAmount: (map['payableAmount'] ?? 0).toDouble(), // Chuyển sang double, giá trị mặc định là 0
      paymentType: map['paymentType'] ?? 'Unknown', // Giá trị mặc định
      paymentStatus: map['paymentStatus'] ?? 'Unpaid', // Giá trị mặc định
      pickDate: map['pickDate'] ?? 'Unknown', // Giá trị mặc định
      deliveryDate: map['deliveryDate'] ?? 'Unknown', // Giá trị mặc định
      orderedAt: map['orderedAt'] ?? 'Unknown', // Giá trị mặc định
      //items: map['items'] ?? 0, // Giá trị mặc định là 0 nếu null
      userName: map['userName'] ?? 'Unknown', // Giá trị mặc định
      userMobile: map['userMobile'] ?? 'Unknown', // Giá trị mặc định
      userProfile: map['userProfile'] ?? '', // Giá trị mặc định là chuỗi rỗng nếu null
      address: map['address'] ?? 'Unknown', // Giá trị mặc định
      products: (map['products'] as List<dynamic>?)
          ?.map((product) => Product.fromMap(product as Map<String, dynamic>))
          .toList() ??
          [], // Giá trị mặc định là danh sách trống nếu null
      invoicePath: map['invoicePath'], // Trường này có thể là null
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, order_code: $orderCode, payable_amount: $payableAmount, order_status: $orderStatus, payment_type: $paymentType, payment_status: $paymentStatus, pick_date: $pickDate, delivery_date: $deliveryDate, ordered_at: $orderedAt, user_name: $userName, user_mobile: $userMobile, user_profile: $userProfile, address: $address, products: $products, invoice_path: $invoicePath)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.orderCode == orderCode &&
        other.payableAmount == payableAmount &&
        other.orderStatus == orderStatus &&
        other.paymentType == paymentType &&
        other.paymentStatus == paymentStatus &&
        other.pickDate == pickDate &&
        other.deliveryDate == deliveryDate &&
        other.orderedAt == orderedAt &&
        //other.items == items &&
        other.userName == userName &&
        other.userMobile == userMobile &&
        other.userProfile == userProfile &&
        other.address == address &&
        listEquals(other.products, products) &&
        other.invoicePath == invoicePath;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    orderCode.hashCode ^
    payableAmount.hashCode ^
    orderStatus.hashCode ^
    paymentType.hashCode ^
    paymentStatus.hashCode ^
    pickDate.hashCode ^
    deliveryDate.hashCode ^
    orderedAt.hashCode ^
    //items.hashCode ^
    userName.hashCode ^
    userMobile.hashCode ^
    userProfile.hashCode ^
    address.hashCode ^
    products.hashCode ^
    invoicePath.hashCode;
  }
}

class Product {
  final String serviceName;
  final List<Item> items;
  Product({
    required this.serviceName,
    required this.items,
  });

  Product copyWith({
    String? serviceName,
    List<Item>? items,
  }) {
    return Product(
      serviceName: serviceName ?? this.serviceName,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'service_name': serviceName,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      serviceName: map['service_name'] as String,
      items: List<Item>.from(
        (map['it@ems'] as List<dynamic>).map<Item>(
              (x) => Item.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Product(service_name: $serviceName, items: $items)';

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.serviceName == serviceName && listEquals(other.items, items);
  }

  @override
  int get hashCode => serviceName.hashCode ^ items.hashCode;
}

class Item {
  final int quantity;
  final String name;
  Item({
    required this.quantity,
    required this.name,
  });

  Item copyWith({
    int? quantity,
    String? name,
  }) {
    return Item(
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'quantity': quantity,
      'name': name,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      quantity: map['quantity'].toInt() as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Item(quantity: $quantity, name: $name)';

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;

    return other.quantity == quantity && other.name == name;
  }

  @override
  int get hashCode => quantity.hashCode ^ name.hashCode;
}
