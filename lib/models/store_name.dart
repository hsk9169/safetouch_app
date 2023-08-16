class StoreName {
  final String name;
  StoreName({required this.name});

  factory StoreName.fromJson(Map<String, dynamic> json) {
    return StoreName(name: json['store_name'] ?? '');
  }

  String get storeName => name;
}
