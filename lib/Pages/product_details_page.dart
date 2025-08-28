// lib/Pages/product_details_page.dart
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_boots/models/products_models.dart';

class ProductDetailsPage extends StatefulWidget {
  final RemoteProduct product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedVariant = 0; // which variant is active (color+size combo)
  int currentImage = 0; // which image inside the active variant

  // ---- helpers to switch by color or size (pick first matching) ----
  void _selectByColor(String color) {
    final variants = widget.product.variants;
    final curSize = variants[selectedVariant].size;
    // try same size + new color first, else first matching color
    final idxSameSize = variants.indexWhere(
      (v) =>
          v.color.toLowerCase() == color.toLowerCase() &&
          v.size.toLowerCase() == curSize.toLowerCase(),
    );
    final idxAny =
        idxSameSize != -1
            ? idxSameSize
            : variants.indexWhere(
              (v) => v.color.toLowerCase() == color.toLowerCase(),
            );
    if (idxAny != -1) {
      setState(() {
        selectedVariant = idxAny;
        currentImage = 0;
      });
    }
  }

  void _selectBySize(String size) {
    final variants = widget.product.variants;
    final curColor = variants[selectedVariant].color;
    // try same color + new size first, else first matching size
    final idxSameColor = variants.indexWhere(
      (v) =>
          v.size.toLowerCase() == size.toLowerCase() &&
          v.color.toLowerCase() == curColor.toLowerCase(),
    );
    final idxAny =
        idxSameColor != -1
            ? idxSameColor
            : variants.indexWhere(
              (v) => v.size.toLowerCase() == size.toLowerCase(),
            );
    if (idxAny != -1) {
      setState(() {
        selectedVariant = idxAny;
        currentImage = 0;
      });
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

    // build unique color and size lists for the side panels
    final colors = <String>{for (final z in variants) z.color}.toList();
    final sizes = <String>{for (final z in variants) z.size}.toList();

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
              tiltDeg: -18, // same vibe as your HeroArea
              onPageChanged: (i) => setState(() => currentImage = i),
              currentImage: currentImage,
              onPickColor: (c) => _selectByColor(c),
              onPickSize: (s) => _selectBySize(s),
              colors: colors,
              sizes: sizes,
              selectedColor: v.color,
              selectedSize: v.size,
            ),

            const SizedBox(height: 1),

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
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.black),
                        shape: const StadiumBorder(),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Add to wishlist'),
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

  // small UI helper
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
    required this.onPickColor,
    required this.onPickSize,
    required this.colors,
    required this.sizes,
    required this.selectedColor,
    required this.selectedSize,
  });

  final String brandText;
  final List<String> images;
  final double tiltDeg;
  final int currentImage;
  final ValueChanged<int> onPageChanged;

  final List<String> colors;
  final List<String> sizes;
  final String selectedColor;
  final String selectedSize;
  final ValueChanged<String> onPickColor;
  final ValueChanged<String> onPickSize;

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
                      fontSize: 300, // scaled by FittedBox
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

          // size chips (left)
          Positioned(
            left: 18,
            top: 90,
            child: _SizeColumn(
              sizes: sizes,
              selectedSize: selectedSize,
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

  final List<String> sizes;
  final String selectedSize;
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
          // boxShadow: const [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 8,
          //     offset: Offset(0, 2),
          //   ),
          // ],
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
  });

  final List<String> colors;
  final String selectedColor;
  final ValueChanged<String> onPick;

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
        // boxShadow: const [
        //   BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        // ],
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
        Container(
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
          child: const Icon(Icons.bookmark_border, size: 20),
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

// --- color name -> Color mapper ---
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
