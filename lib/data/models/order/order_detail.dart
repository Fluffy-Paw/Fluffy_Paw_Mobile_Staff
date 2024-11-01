// class OrderDetail {
//   final int id;
//   final String orderCode;
//   final String paymentType;
//   final String orderedAt;
//   final String status;
//   final double payableAmount;
//   final String userAddress;
//   final DateTime createDate;
//   final DateTime endTime;
//   final String userProfile;
//   final String userName;
//   final String userMobile;
//   final String serviceName;
//   final double cost;
//   final RiderInfo? rider;

//   OrderDetail({
//     required this.id,
//     required this.orderCode,
//     required this.paymentType,
//     required this.orderedAt,
//     required this.status,
//     required this.payableAmount,
//     required this.userAddress,
//     required this.createDate,
//     required this.endTime,
//     required this.userProfile,
//     required this.userName,
//     required this.userMobile,
//     required this.serviceName,
//     required this.cost,
//     this.rider,
//   });

//   factory OrderDetail.fromOrder(Order order) {
//     return OrderDetail(
//       id: order.id,
//       orderCode: order.orderCode ?? '',
//       paymentType: order.paymentType ?? 'Cash',
//       orderedAt: order.createDate,
//       status: order.status,
//       payableAmount: order.cost,
//       userAddress: order.address ?? '',
//       createDate: DateTime.parse(order.createDate),
//       endTime: DateTime.parse(order.startTime),
//       userProfile: order.userProfile ?? '',
//       userName: order.fullName,
//       userMobile: order.phone,
//       serviceName: order.serviceName,
//       cost: order.cost,
//       rider: null,
//     );
//   }
// }

// class OrderService {
//   final String serviceName;
//   final List<OrderItem> items;

//   OrderService({
//     required this.serviceName,
//     required this.items,
//   });

//   factory OrderService.fromJson(Map<String, dynamic> json) {
//     return OrderService(
//       serviceName: json['serviceName'],
//       items: (json['items'] as List)
//           .map((item) => OrderItem.fromJson(item))
//           .toList(),
//     );
//   }
// }

// class OrderItem {
//   final String name;
//   final int quantity;

//   OrderItem({
//     required this.name,
//     required this.quantity,
//   });

//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       name: json['name'],
//       quantity: json['quantity'],
//     );
//   }
// }

// class RiderInfo {
//   final String name;
//   final String mobile;
//   final String profilePhoto;

//   RiderInfo({
//     required this.name,
//     required this.mobile,
//     required this.profilePhoto,
//   });

//   factory RiderInfo.fromJson(Map<String, dynamic> json) {
//     return RiderInfo(
//       name: json['name'],
//       mobile: json['mobile'],
//       profilePhoto: json['profilePhoto'],
//     );
//   }
// } 