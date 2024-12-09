class ServiceTypeModel {
  final int id;
  final String name;
  final String image;

  ServiceTypeModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
  static List<ServiceTypeModel> fromMapList(List<dynamic> list) {
    return list.map((json) => ServiceTypeModel.fromJson(json)).toList();
  }
}