/// Modelo de producto. Convierte JSON ↔ entidad Producto.
import 'package:flash_app/features/products/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.categoryId,
    required super.storeId,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.stock,
    required super.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'stock': stock,
      'is_active': isActive,
    };
  }
}