import 'package:flutter/material.dart';
import 'package:my_boots/Pages/home.dart';
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
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(builder: (context) => HomePage()),
              //     );
              //   },
              //   child: Container(
              //     // Your existing styled container
              //     padding: const EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //       border: Border.all(color: Colors.black12),
              //       color: Colors.white,
              //       boxShadow: const [
              //         BoxShadow(
              //           color: Colors.black12,
              //           blurRadius: 8,
              //           offset: Offset(0, 2),
              //         ),
              //       ],
              //     ),
              //     child: Icon(Icons.arrow_back, size: 20),
              //   ),
              // ),
              // SizedBox(width: 10),
              Spacer(),
              Text(
                product.category,
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
            const SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BEST SELLER',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Text(
                        '\₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '\₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.black12,
                          decorationThickness: 2,
                        ),
                      ),
                      Spacer(),
                      Text("4.5", style: TextStyle(fontSize: 14)),
                      const Icon(Icons.star, color: Colors.black, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Air Jordan is an American brand of basketball shoes athletic, casual, and style clothing produced by Nice...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${product.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Add to cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
