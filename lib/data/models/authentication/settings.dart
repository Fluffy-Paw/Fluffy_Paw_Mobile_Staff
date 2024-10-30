import 'dart:convert';

class Settings {
  final String currency;
  final String androidUrl;
  final String? iosUrl;
  final bool twoStepVerification;
  final String? deviceType;
  final bool cashOnDelivery;
  final bool onlinePayment;
  Settings({
    required this.currency,
    required this.androidUrl,
    required this.iosUrl,
    required this.twoStepVerification,
    required this.deviceType,
    required this.cashOnDelivery,
    required this.onlinePayment,
  });

  Settings copyWith({
    String? currency,
    String? androidUrl,
    String? iosUrl,
    bool? twoStepVerification,
    String? deviceType,
    bool? cashOnDelivery,
    bool? onlinePayment,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      androidUrl: androidUrl ?? this.androidUrl,
      iosUrl: iosUrl ?? this.iosUrl,
      twoStepVerification: twoStepVerification ?? this.twoStepVerification,
      deviceType: deviceType ?? this.deviceType,
      cashOnDelivery: cashOnDelivery ?? this.cashOnDelivery,
      onlinePayment: onlinePayment ?? this.onlinePayment,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currency': currency,
      'android_url': androidUrl,
      'ios_url': iosUrl,
      'two_step_verification': twoStepVerification,
      'device_type': deviceType,
      'cash_on_delivery': cashOnDelivery,
      'online_payment': onlinePayment,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      currency: map['currency'] as String,
      androidUrl: map['android_url'] as String,
      iosUrl: map['ios_url'] ?? '',
      twoStepVerification: map['two_step_verification'] as bool,
      deviceType: map['device_type'] ?? '',
      cashOnDelivery: map['cash_on_delivery'] as bool,
      onlinePayment: map['online_payment'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Settings.fromJson(String source) =>
      Settings.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Settings(currency: $currency, android_url: $androidUrl, ios_url: $iosUrl, two_step_verification: $twoStepVerification, device_type: $deviceType, cash_on_delivery: $cashOnDelivery, online_payment: $onlinePayment)';
  }

  @override
  bool operator ==(covariant Settings other) {
    if (identical(this, other)) return true;

    return other.currency == currency &&
        other.androidUrl == androidUrl &&
        other.iosUrl == iosUrl &&
        other.twoStepVerification == twoStepVerification &&
        other.deviceType == deviceType &&
        other.cashOnDelivery == cashOnDelivery &&
        other.onlinePayment == onlinePayment;
  }

  @override
  int get hashCode {
    return currency.hashCode ^
    androidUrl.hashCode ^
    iosUrl.hashCode ^
    twoStepVerification.hashCode ^
    deviceType.hashCode ^
    cashOnDelivery.hashCode ^
    onlinePayment.hashCode;
  }
}
