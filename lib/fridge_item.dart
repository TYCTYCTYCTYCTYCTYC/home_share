import 'dart:convert';

class FridgeItem {
  int? home_id;
  String? category;
  String? description;
  final String? imageUrl;
  String? name;
  final DateTime? dateAdded;
  DateTime? _dateExpiring;

  FridgeItem({
    this.home_id,
    this.category,
    this.description,
    this.imageUrl,
    this.name,
    this.dateAdded,
  });

  factory FridgeItem.fromJson(Map<String, dynamic> json) {
    return FridgeItem(
      
      category: json['product']['category'],
      description: json['product']['description'],
      imageUrl: json['product']['image_url'],
      name: json['product']['product_name'],
      dateAdded: DateTime.now(),
    );
  }

  factory FridgeItem.fromSharedPrefs(Map<String, dynamic> json) {
    FridgeItem item = FridgeItem(
      category: json['category'],
      description: json['description'],
      imageUrl: json['image_url'],
      name: json['name'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
    item.dateExpiring = DateTime.parse(json['dateExpiring']);
    return item;
  }

  factory FridgeItem.invalid() {
    return FridgeItem(
      category: "",
      description: "",
      imageUrl: null,
      name: "",
      dateAdded: DateTime.now(),
    );
  }

  DateTime? get dateExpiring => _dateExpiring;

  set dateExpiring(DateTime? value) {
    _dateExpiring = value;
  }

  static Map<String, dynamic> toMap(FridgeItem item) => {
        'category': item.category,
        'description': item.description,
        'imageUrl': item.imageUrl,
        'name': item.name,
        'dateAdded': item.dateAdded.toString(),
        'dateExpiring': item.dateExpiring.toString(),
      };

  static String encode(List<FridgeItem> items) => jsonEncode(
        items
            .map<Map<String, dynamic>>((item) => FridgeItem.toMap(item))
            .toList(),
      );

  static List<FridgeItem> decode(String items) =>
      (jsonDecode(items) as List<dynamic>)
          .map<FridgeItem>((item) => FridgeItem.fromSharedPrefs(item))
          .toList();

  @override
  String toString() {
    return 'FridgeItem{category: $category, description: $description, imageUrl: $imageUrl, name: $name, dateAdded: $dateAdded, dateExpiring: $dateExpiring}';
  }
}
