// lib/models/liked_item.dart
class ProductMini {
  final String id;
  final String sku;
  final String name;
  final String brand;
  final String category;

  ProductMini({
    required this.id,
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
  });

  factory ProductMini.fromJson(Map<String, dynamic> json) {
    final p = json;
    return ProductMini(
      id: (p['_id'] ?? '').toString(),
      sku: (p['sku'] ?? '').toString(),
      name: (p['name'] ?? '').toString(),
      brand: (p['brand'] ?? '').toString(),
      category: (p['category'] ?? '').toString(),
    );
  }
}

class CartItem {
  final String id; // _id of the like document
  final String variantId;
  final int unitPrice;
  final int mrp;
  final String color;
  final int size;
  final List<String> images;
  int quantity;
  final ProductMini product;

  CartItem({
    required this.id,
    required this.variantId,
    required this.unitPrice,
    required this.mrp,
    required this.color,
    required this.size,
    required this.images,
    required this.quantity,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final imgs =
        (json['images'] is List)
            ? (json['images'] as List).map((e) => e.toString()).toList()
            : <String>[];
    final productNode =
        (json['productId'] is Map<String, dynamic>)
            ? ProductMini.fromJson(Map<String, dynamic>.from(json['productId']))
            : ProductMini(
              id: '',
              sku: '',
              name: 'Unknown',
              brand: '',
              category: '',
            );

    return CartItem(
      id: (json['_id'] ?? '').toString(),
      variantId: (json['variantId'] ?? '').toString(),
      unitPrice:
          (json['unitPrice'] is num) ? (json['unitPrice'] as num).toInt() : 0,
      mrp: (json['mrp'] is num) ? (json['mrp'] as num).toInt() : 0,
      color: (json['color'] ?? '').toString(),
      size:
          (json['size'] is num)
              ? (json['size'] as num).toInt()
              : int.tryParse('${json['size']}') ?? 0,
      images: imgs,
      quantity:
          (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 0,
      product: productNode,
    );
  }
}
