import 'dart:convert';

import 'package:flutter/foundation.dart';

class OrderDetails {
  final int id;
  final String orderCode;
  final double payableAmount;
  final String orderStatus;
  final String paymentType;
  final String paymentStatus;
  final String pickDate;
  final String deliveryDate;
  final String orderedAt;
  final int items;
  final String userName;
  final String userMobile;
  final String userProfile;
  final String userAddress;
  final List<Product> products;
  final Rider? rider;
  final String? invoicePath;

  OrderDetails({
    required this.id,
    required this.orderCode,
    required this.payableAmount,
    required this.orderStatus,
    required this.paymentType,
    required this.paymentStatus,
    required this.pickDate,
    required this.deliveryDate,
    required this.orderedAt,
    required this.items,
    required this.userName,
    required this.userMobile,
    required this.userProfile,
    required this.userAddress,
    required this.products,
    required this.rider,
    required this.invoicePath,
  });

  OrderDetails copyWith({
    int? id,
    String? orderCode,
    double? payableAmount,
    String? orderStatus,
    String? paymentType,
    String? paymentStatus,
    String? pickDate,
    String? deliveryDate,
    String? orderedAt,
    int? items,
    String? userName,
    String? userMobile,
    String? userProfile,
    String? userAddress,
    List<Product>? products,
    Rider? rider,
    String? invoicePath,
  }) {
    return OrderDetails(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      payableAmount: payableAmount ?? this.payableAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentType: paymentType ?? this.paymentType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pickDate: pickDate ?? this.pickDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderedAt: orderedAt ?? this.orderedAt,
      items: items ?? this.items,
      userName: userName ?? this.userName,
      userMobile: userMobile ?? this.userMobile,
      userProfile: userProfile ?? this.userProfile,
      userAddress: userAddress ?? this.userAddress,
      products: products ?? this.products,
      rider: rider ?? this.rider,
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
      'items': items,
      'user_name': userName,
      'user_mobile': userMobile,
      'user_profile': userProfile,
      'user_address': userAddress,
      'products': products.map((x) => x.toMap()).toList(),
      'rider': rider?.toMap(),
      'invoice_path': invoicePath,
    };
  }

  factory OrderDetails.fromMap(Map<String, dynamic> map) {
    double payableAmount = map['payable_amount'].toDouble();

    return OrderDetails(
      id: map['id'].toInt() as int,
      orderCode: map['order_code'] as String,
      payableAmount: payableAmount,
      orderStatus: map['order_status'] as String,
      paymentType: map['payment_type'] as String,
      paymentStatus: map['payment_status'] as String,
      pickDate: map['pick_date'] as String,
      deliveryDate: map['delivery_date'] as String,
      orderedAt: map['ordered_at'] as String,
      items: map['items'].toInt() as int,
      userName: map['user_name'] as String,
      userMobile: map['user_mobile'] as String,
      userProfile: map['user_profile'] as String,
      userAddress: map['address'] as String,
      products: List<Product>.from(
        (map['products'] as List<dynamic>).map<Product>(
              (x) => Product.fromMap(x as Map<String, dynamic>),
        ),
      ),
      rider: map['rider'] != null
          ? Rider.fromMap(map['rider'] as Map<String, dynamic>)
          : null,
      invoicePath: 'ts',
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderDetails.fromJson(String source) =>
      OrderDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderDetails(id: $id, orderCode: $orderCode, payableAmount: $payableAmount, orderStatus: $orderStatus, paymentType: $paymentType, paymentStatus: $paymentStatus, pickDate: $pickDate, deliveryDate: $deliveryDate, orderedAt: $orderedAt, items: $items, userName: $userName, userMobile: $userMobile, userProfile: $userProfile, userAddress: $userAddress, products: $products, rider: $rider, invoicePath: $invoicePath)';
  }

  @override
  bool operator ==(covariant OrderDetails other) {
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
        other.items == items &&
        other.userName == userName &&
        other.userMobile == userMobile &&
        other.userProfile == userProfile &&
        other.userAddress == userAddress &&
        listEquals(other.products, products) &&
        other.rider == rider &&
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
    items.hashCode ^
    userName.hashCode ^
    userMobile.hashCode ^
    userProfile.hashCode ^
    userAddress.hashCode ^
    products.hashCode ^
    rider.hashCode ^
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
        (map['items'] as List<dynamic>).map<Item>(
              (x) => Item.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Product(serviceName: $serviceName, items: $items)';

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

class Rider {
  final int id;
  final String code;
  final String name;
  final String mobile;
  final String profilePhoto;
  final bool isActive;
  Rider({
    required this.id,
    required this.code,
    required this.name,
    required this.mobile,
    required this.profilePhoto,
    required this.isActive,
  });

  Rider copyWith({
    int? id,
    String? code,
    String? name,
    String? mobile,
    String? profilePhoto,
    bool? isActive,
  }) {
    return Rider(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'mobile': mobile,
      'profile_photo': profilePhoto,
      'is_active': isActive,
    };
  }

  factory Rider.fromMap(Map<String, dynamic> map) {
    return Rider(
      id: map['id'].toInt() as int,
      code: map['code'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String,
      profilePhoto: map['profile_photo'] as String,
      isActive: map['is_active'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rider.fromJson(String source) =>
      Rider.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Rider(id: $id, code: $code, name: $name, mobile: $mobile, profile_photo: $profilePhoto, is_active: $isActive)';
  }

  @override
  bool operator ==(covariant Rider other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.code == code &&
        other.name == name &&
        other.mobile == mobile &&
        other.profilePhoto == profilePhoto &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    code.hashCode ^
    name.hashCode ^
    mobile.hashCode ^
    profilePhoto.hashCode ^
    isActive.hashCode;
  }
}
