import 'package:image_picker/image_picker.dart';

class TrackingFile {
  final int id;
  final String file;
  final DateTime createDate;
  final bool status;
  final bool isTemp;
  final String? error;

  TrackingFile({
    required this.id,
    required this.file,
    required this.createDate,
    required this.status,
    this.isTemp = false,
    this.error,
  });

  factory TrackingFile.fromMap(Map<String, dynamic> map) {
    return TrackingFile(
      id: map['id'] as int? ?? 0,
      file: map['file'] as String? ?? '',
      createDate: DateTime.parse(map['createDate'] as String),
      status: map['status'] as bool? ?? false,
    );
  }

  factory TrackingFile.temp({
    required String filePath,
  }) {
    return TrackingFile(
      id: DateTime.now().millisecondsSinceEpoch,
      file: filePath,
      createDate: DateTime.now(),
      status: false,
      isTemp: true,
    );
  }

  TrackingFile copyWith({
    int? id,
    String? file,
    DateTime? createDate,
    bool? status,
    bool? isTemp,
    String? error,
  }) {
    return TrackingFile(
      id: id ?? this.id,
      file: file ?? this.file,
      createDate: createDate ?? this.createDate,
      status: status ?? this.status,
      isTemp: isTemp ?? this.isTemp,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file': file,
      'createDate': createDate.toIso8601String(),
      'status': status,
    };
  }
}

class TrackingInfo {
  final int id;
  final int bookingId;
  final DateTime uploadDate;
  final String description;
  final bool status;
  final List<TrackingFile> files;
  final bool isTemp;
  final String? error;

  TrackingInfo({
    required this.id,
    required this.bookingId,
    required this.uploadDate,
    required this.description,
    required this.status,
    required this.files,
    this.isTemp = false,
    this.error,
  });

  factory TrackingInfo.fromMap(Map<String, dynamic> map) {
    return TrackingInfo(
      id: map['id'] as int? ?? 0,
      bookingId: map['bookingId'] as int? ?? 0,
      uploadDate: DateTime.parse(map['uploadDate'] as String),
      description: map['description'] as String? ?? '',
      status: map['status'] as bool? ?? false,
      files: (map['files'] as List<dynamic>?)
              ?.map((x) => TrackingFile.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory TrackingInfo.temp({
    required int bookingId,
    required String description,
    required List<XFile> images,
  }) {
    return TrackingInfo(
      id: DateTime.now().millisecondsSinceEpoch,
      bookingId: bookingId,
      uploadDate: DateTime.now(),
      description: description,
      status: false,
      files: images.map((file) => TrackingFile.temp(
        filePath: file.path,
      )).toList(),
      isTemp: true,
    );
  }

  TrackingInfo copyWith({
    int? id,
    int? bookingId,
    DateTime? uploadDate,
    String? description,
    bool? status,
    List<TrackingFile>? files,
    bool? isTemp,
    String? error,
  }) {
    return TrackingInfo(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      uploadDate: uploadDate ?? this.uploadDate,
      description: description ?? this.description,
      status: status ?? this.status,
      files: files ?? this.files,
      isTemp: isTemp ?? this.isTemp,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'status': status,
      'files': files.map((x) => x.toMap()).toList(),
    };
  }
}