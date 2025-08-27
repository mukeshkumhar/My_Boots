import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/products_models.dart';

class HeroArea extends StatelessWidget {
  const HeroArea({
    super.key,
    required this.imagePath,
    required this.product,
    this.brandWord = 'NIKE',
    this.heroHeight = 480,
    this.shoeTiltDeg = -18,
    this.shoeOffsetY = 30,
    this.shoeScale = 2.80, // relative to heroHeight
    this.textOpacity = 0.08,
    this.textScale = 1.0,
  });
  final RemoteProduct product;

  final String imagePath;
  final String brandWord;
  final double heroHeight;
  final double shoeTiltDeg;
  final double shoeOffsetY;
  final double shoeScale;
  final double textOpacity;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final hasVariant = product.variants.isNotEmpty;
    final first = hasVariant ? product.variants.first : null;
    final String? img =
        (first != null && first.images.isNotEmpty) ? first.images.first : null;
    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none, // allow parts to overflow visually
        alignment: Alignment.center,
        children: [
          // ---------- BIG ROTATED WORD (auto-scales) ----------
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Transform.rotate(
                  angle: 90 * math.pi / 180, // 90° CCW
                  child: Text(
                    brandWord,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // very large, then scaled by FittedBox and textScale
                      fontSize: 360 * textScale,
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

          // ---------- SHOE (on top) ----------
          Positioned.fill(
            child: Center(
              child: Transform.translate(
                offset: Offset(-20, 15), // move up/down
                child: Transform.rotate(
                  angle: shoeTiltDeg * math.pi / 180, // tilt
                  child: Hero(
                    tag: imagePath,
                    child:
                        img == null || img.isEmpty
                            ? const Icon(Icons.image_not_supported, size: 48)
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                img,
                                height: 290,
                                fit: BoxFit.fitHeight,
                                // small loader while downloading
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
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
                                    (context, error, stack) => const Icon(
                                      Icons.broken_image,
                                      size: 48,
                                    ),
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ),

          // ---------- LEFT SIZE CHIPS ----------
          Positioned(left: 16, top: 80, child: _SizeColumn()),

          // ---------- RIGHT CONTROLS ----------
          Positioned(right: 16, top: 80, child: _RightControls()),
        ],
      ),
    );
  }
}

class _SizeColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget chip(String t) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        chip('UK 6'),
        chip('UK 7'),
        chip('UK 8'),
        chip('UK 9'),
      ],
    );
  }
}

class _RightControls extends StatelessWidget {
  const _RightControls();

  Widget _swatch(Color c) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    child: Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        _swatch(Colors.red),
        _swatch(Colors.indigo),
      ],
    );
  }
}
