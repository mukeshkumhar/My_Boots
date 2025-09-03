// lib/models/products_models.dart  (or your features path)

class ProductVariant {
  final String id;
  final List<String> images;
  final String color;
  final List<String> sizes; // always strings in UI
  final int mrp;
  final int price;
  final bool inStock;

  ProductVariant({
    required this.id,
    required this.images,
    required this.color,
    required this.sizes,
    required this.mrp,
    required this.price,
    required this.inStock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> j) {
    // size can be number, string, or list -> normalize to List<String>
    final rawSize = j['size'] ?? j['sizes'];
    final sizes =
        (rawSize is List)
            ? rawSize.map((e) => e.toString()).toList()
            : rawSize != null
            ? <String>[rawSize.toString()]
            : <String>[];

    return ProductVariant(
      id: (j['_id'] ?? '').toString(),
      images: (j['images'] as List? ?? []).map((e) => e.toString()).toList(),
      color: (j['color'] ?? '').toString(),
      sizes: sizes,
      mrp: _asInt(j['mrp']),
      price: _asInt(j['price']),
      inStock: j['inStock'] == true,
    );
  }
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
            .whereType<Map>()
            .map((v) => ProductVariant.fromJson(Map<String, dynamic>.from(v)))
            .toList(),
  );
}

// ---- helper for ints from num/string
int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
