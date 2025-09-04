// lib/Pages/product_details_page.dart
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_boots/models/products_models.dart';

import '../core/auth_api.dart';

class ProductDetailsPage extends StatefulWidget {
  final RemoteProduct product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedVariant = 0; // which color/variant
  int currentImage = 0; // which image for the variant
  String? selectedSize; // <- NEW: selected size as String
  bool _wishLoading = false;
  bool _isWished = false;

  final _api = AuthApi();

  String _extractId(dynamic obj) {
    if (obj == null) return '';
    // tries common patterns: id, _id, productId, variantId
    for (final k in ['id', '_id', 'productId', 'variantId', 'sId']) {
      final v = (obj as dynamic).toJson?.call()[k] ?? (obj as dynamic)?.$k;
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    // Fallbacks for typical field names if your model exposes them directly:
    try {
      final v = (obj.id ?? obj._id ?? obj.productId ?? obj.variantId);
      if (v != null) return v.toString();
    } catch (_) {}
    return '';
  }

  int _parseSizeToInt(String s) {
    // grabs the first run of digits; "UK 8" -> 8, "8.5" -> 8
    final m = RegExp(r'\d+').firstMatch(s);
    return (m != null) ? int.parse(m.group(0)!) : 0;
  }

  String _productId() {
    final p = widget.product;

    // 1) Try toJson() map first
    try {
      final j = (p as dynamic).toJson?.call();
      if (j is Map) {
        for (final k in ['_id', 'id', 'productId']) {
          final v = j[k];
          if (v != null && v.toString().isNotEmpty) return v.toString();
        }
      }
    } catch (_) {}

    // 2) Fall back to common direct fields
    try {
      final v =
          (p as dynamic).id ?? (p as dynamic)._id ?? (p as dynamic).productId;
      if (v != null && v.toString().isNotEmpty) return v.toString();
    } catch (_) {}

    return '';
  }

  String _variantIdOf() {
    final varient = widget.product.variants[selectedVariant];

    if (varient.id.isNotEmpty) {
      return varient.id;
    }

    print("Variant ID: $varient");
    return '';
  }

  Future<void> _onTapFavorite() async {
    if (_wishLoading) return;
    final variants = widget.product.variants;
    if (variants.isEmpty) return;

    final v = variants[selectedVariant];
    print("Selected varient $selectedVariant");
    final productId = _productId();
    final variantId = _variantIdOf();
    final sizeText = (selectedSize ?? _sizesOf(v).first).toString();
    final sizeInt = _parseSizeToInt(sizeText); // <- always an int

    // selectedSize is String (e.g. "8") -> backend expects int
    // final sizeInt = int.tryParse(selectedSize ?? _sizesOf(v).first);

    if (productId.isEmpty || variantId.isEmpty || sizeInt == 0) {
      print("ProductID: $productId, $variantId, $sizeInt");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing product/variant/size')),
      );
      return;
    }

    setState(() => _wishLoading = true);
    try {
      await _api.addFavorite(
        productId: productId,
        variantId: variantId,
        size: sizeInt,
      );
      if (mounted) {
        setState(() => _isWished = true);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
      }
    } catch (e) {
      if (mounted) {
        print("Error to add favorites: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
      }
    } finally {
      if (mounted) setState(() => _wishLoading = false);
    }
  }

  // Normalize sizes from variant.size (supports int | String | List)
  List<String> _sizesOf(dynamic variant) {
    final raw = variant.sizes;
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [raw.toString()];
  }

  // Tap color: switch variant, keep size if available, else first size
  void _selectByColor(String color) {
    final variants = widget.product.variants;
    final cur = variants[selectedVariant];
    final curSize = selectedSize ?? _sizesOf(cur).first;

    final idx = variants.indexWhere(
      (v) => v.color.toLowerCase() == color.toLowerCase(),
    );
    if (idx != -1) {
      final newV = variants[idx];
      final newVSizes = _sizesOf(newV);
      setState(() {
        selectedVariant = idx;
        currentImage = 0;
        selectedSize = newVSizes.contains(curSize) ? curSize : newVSizes.first;
      });
    }
  }

  // Tap size: just change the size for the current variant
  void _selectBySize(String size) {
    final vSizes = _sizesOf(widget.product.variants[selectedVariant]);
    if (vSizes.contains(size)) {
      setState(() => selectedSize = size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.product.variants;
    if (variants.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.product.name)),
        body: const Center(child: Text('No variants available')),
      );
    }

    final v = variants[selectedVariant];
    final images = v.images;
    final vSizes = _sizesOf(v);
    final selSizeText = selectedSize ?? vSizes.first; // ensure non-null

    // Unique colors across variants (for right panel swatches)
    final colors = <String>{for (final z in variants) z.color}.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Spacer(),
            Text(
              widget.product.category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _iconBox('assets/icons/cart_logo.png'),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HERO-STYLE HEADER =================
            _HeroBanner(
              brandText: widget.product.brand,
              images: images,
              tiltDeg: -18,
              onPageChanged: (i) => setState(() => currentImage = i),
              currentImage: currentImage,
              // pass sizes of CURRENT variant only
              sizes: vSizes, // <- CHANGED to List<String>
              selectedSize: selSizeText, // <- String
              onPickSize: (s) => _selectBySize(s),
              colors: colors,
              selectedColor: v.color,
              onPickColor: (c) => _selectByColor(c),
              isWished: _isWished,
              loading: _wishLoading,
              onToggleWish: _onTapFavorite,
            ),

            const SizedBox(height: 12),

            // ================= TITLE + PRICE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BEST SELLER',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${v.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (v.mrp > v.price)
                        Text(
                          '₹${v.mrp}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black26,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 2,
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        v.inStock ? Icons.check_circle : Icons.cancel,
                        color: v.inStock ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        v.inStock ? 'In stock' : 'Out of stock',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= BOTTOM ACTIONS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _wishLoading
                              ? null
                              : () {
                                _onTapFavorite();
                              },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.black),
                        shape: const StadiumBorder(),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        _isWished ? 'Added to wishlist' : 'Add to wishlist',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: v.inStock ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Add to cart'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(String asset) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black12),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    child: Image.asset(asset, width: 24, height: 24),
  );
}

// ================= HERO-STYLE BANNER =================
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.brandText,
    required this.images,
    required this.tiltDeg,
    required this.currentImage,
    required this.onPageChanged,
    required this.colors,
    required this.selectedColor,
    required this.onPickColor,
    required this.sizes, // <- List<String>
    required this.selectedSize, // <- String
    required this.onPickSize, // <- ValueChanged<String>
    required this.isWished, // NEW
    required this.loading, // NEW
    required this.onToggleWish,
  });

  final String brandText;
  final List<String> images;
  final double tiltDeg;
  final int currentImage;
  final ValueChanged<int> onPageChanged;

  final List<String> colors;
  final String selectedColor;
  final ValueChanged<String> onPickColor;

  final List<String> sizes; // <- CHANGED type to List<String>
  final String selectedSize; // <- CHANGED to String
  final ValueChanged<String> onPickSize;

  final bool isWished; // NEW
  final bool loading; // NEW
  final VoidCallback onToggleWish; // NEW

  @override
  Widget build(BuildContext context) {
    const double heroHeight = 430;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // big rotated brand word
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Transform.rotate(
                  angle: 90 * math.pi / 180,
                  child: Text(
                    (brandText.isEmpty ? 'BRAND' : brandText).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 300,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -8,
                      height: 0.9,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // tilted image carousel
          Positioned.fill(
            child: Center(
              child: Transform.translate(
                offset: const Offset(-20, -30),
                child: Transform.rotate(
                  angle: tiltDeg * math.pi / 180,
                  child: SizedBox(
                    height: 250,
                    child:
                        images.isEmpty
                            ? const Icon(Icons.image_not_supported, size: 48)
                            : CarouselSlider.builder(
                              itemCount: images.length,
                              itemBuilder: (context, idx, __) {
                                final url = images[idx];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    url,
                                    height: 280,
                                    fit: BoxFit.fitHeight,
                                    loadingBuilder:
                                        (c, child, p) =>
                                            p == null
                                                ? child
                                                : const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 48,
                                        ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 380,
                                viewportFraction: 0.7,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: false,
                                onPageChanged: (i, _) => onPageChanged(i),
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ),

          // size chips (left) — sizes of CURRENT variant
          Positioned(
            left: 18,
            top: 90,
            child: _SizeColumn(
              sizes: sizes, // <- List<String>
              selectedSize: selectedSize, // <- String
              onPick: onPickSize,
            ),
          ),

          // right controls: bookmark + color swatches
          Positioned(
            right: 16,
            top: 125,
            child: _RightControls(
              colors: colors,
              selectedColor: selectedColor,
              onPick: onPickColor,
              isWished: isWished,
              loading: loading,
              onToggleWish: onToggleWish,
            ),
          ),

          // dots under the hero (centered)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == currentImage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 12 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: active ? Colors.black : Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeColumn extends StatelessWidget {
  const _SizeColumn({
    required this.sizes,
    required this.selectedSize,
    required this.onPick,
  });

  final List<String> sizes; // <- String list
  final String selectedSize; // <- String
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    Widget chip(String t, bool selected) => GestureDetector(
      onTap: () => onPick(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? Colors.black54 : Colors.black12,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'UK $t',
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        for (final s in sizes)
          chip(s, s.toLowerCase() == selectedSize.toLowerCase()),
      ],
    );
  }
}

class _RightControls extends StatelessWidget {
  const _RightControls({
    required this.colors,
    required this.selectedColor,
    required this.onPick,
    required this.isWished,
    required this.loading,
    required this.onToggleWish,
  });

  final List<String> colors;
  final String selectedColor;
  final ValueChanged<String> onPick;

  final bool isWished; // NEW
  final bool loading; // NEW
  final VoidCallback onToggleWish;

  Widget _swatch(Color c, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: selected ? Colors.black : Colors.black12,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // bookmark
        InkWell(
          onTap: loading ? null : onToggleWish,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:
                loading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(
                      isWished ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isWished ? Colors.red : Colors.black,
                    ),
          ),
        ),
        const SizedBox(height: 80),
        const Text(
          'Colour',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        for (final name in colors)
          _swatch(
            _colorFromName(name),
            name.toLowerCase() == selectedColor.toLowerCase(),
            () => onPick(name),
          ),
      ],
    );
  }
}

// color name -> Color mapper
Color _colorFromName(String name) {
  final s = name.trim().toLowerCase();
  switch (s) {
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'purple':
      return Colors.purple;
    case 'pink':
      return Colors.pink;
    case 'grey':
    case 'gray':
      return Colors.grey;
    case 'brown':
      return Colors.brown;
    case 'navy':
      return const Color(0xFF001F3F);
    default:
      return Colors.grey.shade400;
  }
}
