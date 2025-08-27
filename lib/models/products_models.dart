// lib/features/products/product_models.dart
class ProductVariant {
  final List<String> images;
  final String color;
  final String size;
  final int mrp;
  final int price;
  final bool inStock;

  ProductVariant({
    required this.images,
    required this.color,
    required this.size,
    required this.mrp,
    required this.price,
    required this.inStock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
    images: (j['images'] as List? ?? []).map((e) => e.toString()).toList(),
    color: (j['color'] ?? '').toString(),
    size: (j['size'] ?? '').toString(),
    mrp: (j['mrp'] ?? 0) as int,
    price: (j['price'] ?? 0) as int,
    inStock: (j['inStock'] ?? false) as bool,
  );
}

class RemoteProduct {
  final String id;
  final String sku;
  final String name;
  final String brand;
  final String category;
  final String description;
  final String careInfo;
  final String material;
  final List<ProductVariant> variants;

  RemoteProduct({
    required this.id,
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.careInfo,
    required this.material,
    required this.variants,
  });

  String get imageUrl =>
      variants.isNotEmpty && variants.first.images.isNotEmpty
          ? variants.first.images.first
          : '';

  int get price => variants.isNotEmpty ? variants.first.price : 0;

  factory RemoteProduct.fromJson(Map<String, dynamic> j) => RemoteProduct(
    id: (j['_id'] ?? '').toString(),
    sku: (j['sku'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    brand: (j['brand'] ?? '').toString(),
    category: (j['category'] ?? '').toString(),
    description: (j['description'] ?? '').toString(),
    careInfo: (j['careInfo'] ?? '').toString(),
    material: (j['material'] ?? '').toString(),
    variants:
        (j['variant'] as List? ?? [])
            .map((v) => ProductVariant.fromJson(Map<String, dynamic>.from(v)))
            .toList(),
  );
}
