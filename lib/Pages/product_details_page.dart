import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../widgets/hero_area.dart';
import '../widgets/product_card.dart'; // if Product class is there

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, size: 20),
              ),
              SizedBox(width: 10),
              Spacer(),
              Text(
                product.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Spacer(),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/cart_logo.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        // title: Text(product.name),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        // elevation: 0,
      ),

      // ✅ Scrollable content
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroArea(
              imagePath: product.image,
              brandWord: 'NIKE',
              heroHeight: 480, // overall section height
              shoeTiltDeg: -18, // rotate shoe
              shoeOffsetY: -40, // move shoe up (-) / down (+)
              shoeScale: 0.60, // 0.50 ~ 0.70 good range
              textOpacity: 0.06, // watermark intensity
              textScale: 1.0, // 0.8 smaller, 1.2 bigger
            ),
          ],
        ),
      ),

      // ✅ Button fixed at bottom (not inside the scroll view)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Add to cart action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
            child: const Text("Add to Cart"),
          ),
        ),
      ),
    );
  }
}
