import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['thumbnail'] != null && json['thumbnail'].toString().isNotEmpty) {
      imageUrl = json['thumbnail'].toString();
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0].toString();
    }

    return ProductModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Unknown',
      image: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'thumbnail': image,
      'images': [image],
    };
  }
}
