/// Entidad de dominio: Producto del catálogo.
class Product {
  final String id;
  final String categoryId;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final bool isActive;

  const Product({
    required this.id,
    required this.categoryId,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.isActive,
  });
}