class Ad {
  final int id;
  final String title;
  final String description;
  final double price;
  final String city;
  final String category;
  final List<String> images;
  final String? email;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    required this.category,
    required this.images,
    this.email,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      city: json['city'],
      category: json['category'],
      images: List<String>.from(json['images'] ?? []),
      email: json['user']?['email'], // في حال أردت عرض البريد لاحقاً
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'city': city,
      'category': category,
      'images': images,
    };
  }
}
