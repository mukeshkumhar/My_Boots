// widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:my_boots/models/products_models.dart';

// class Product {
//   final String name;
//   final double price;
//   final String image; // asset path
//   final String category; // Running, Sneakers, Formal, Casual
//   const Product(this.name, this.price, this.image, this.category);
// }

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});
  final RemoteProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasVariant = product.variants.isNotEmpty;
    final first = hasVariant ? product.variants.first : null;
    final String? img =
        (first != null && first.images.isNotEmpty) ? first.images.first : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(22),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.white10,
        //     blurRadius: 16,
        //     offset: Offset(0, 8),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            SizedBox(
              height: 150,
              child: Center(
                child:
                    img == null || img.isEmpty
                        ? const Icon(Icons.image_not_supported, size: 48)
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            img,
                            height: 140,
                            fit: BoxFit.fitHeight,
                            // small loader while downloading
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                height: 140,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            // fallback if the URL fails
                            errorBuilder:
                                (context, error, stack) =>
                                    const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              product.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            // const SizedBox(height: 0),
            Row(
              children: [
                Text(
                  '\₹${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
