/// Entidad de dominio: Categoría de productos.
class Category {
  final String id;
  final String name;
  final String iconUrl;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.sortOrder,
  });
}