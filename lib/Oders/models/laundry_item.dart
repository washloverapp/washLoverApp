class LaundryItem {
  final String id;
  final String name;
  final String detail;
  final int price;
  final String image;
  final String type;

  LaundryItem({
    required this.id,
    required this.name,
    required this.detail,
    required this.price,
    required this.image,
    required this.type,
  });

  factory LaundryItem.fromJson(Map<String, dynamic> json) {
    // API ส่ง path เป็น assets/images/lists/... ซึ่งตรงกับ Flutter asset path
    // ใช้ตามที่ API ส่งมาเลย (Flutter Image.asset ต้องการ path ที่เริ่มต้นด้วย assets/)
    String imagePath = json['image'] as String;
    
    return LaundryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      detail: json['detail'] as String,
      price: json['price'] as int,
      image: imagePath,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'price': price,
      'image': image,
      'type': type,
    };
  }
}
