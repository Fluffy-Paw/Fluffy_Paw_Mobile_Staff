import 'dart:convert';

class StatusWiseOrderCount {
  final String status;
  final int count;
  StatusWiseOrderCount({
    required this.status,
    required this.count,
  });

  StatusWiseOrderCount copyWith({
    String? status,
    int? count,
  }) {
    return StatusWiseOrderCount(
      status: status ?? this.status,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'count': count,
    };
  }

  factory StatusWiseOrderCount.fromMap(Map<String, dynamic> map) {
    return StatusWiseOrderCount(
      status: map['status'] as String,
      count: map['count'].toInt() as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatusWiseOrderCount.fromJson(String source) =>
      StatusWiseOrderCount.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'StatusWiseOrderCount(status: $status, count: $count)';

  @override
  bool operator ==(covariant StatusWiseOrderCount other) {
    if (identical(this, other)) return true;

    return other.status == status && other.count == count;
  }

  @override
  int get hashCode => status.hashCode ^ count.hashCode;
}
