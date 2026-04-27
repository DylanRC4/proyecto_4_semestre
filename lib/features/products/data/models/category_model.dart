/// Modelo de categoría. Convierte JSON ↔ entidad Category.
import 'package:flash_app/features/products/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconUrl,
    required super.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}