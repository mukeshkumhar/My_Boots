import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_boots/Pages/product_details_page.dart';
import '../widgets/product_card.dart';
import '../widgets/category_slider.dart'; // Or cupertino.dart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;

  final List<Widget> _cards = [
    _PromoCard(
      title: '20% Discount',
      subtitle: 'on your first purchase',
      cta: 'Shop now',
      image: 'assets/images/blue1.png',
    ),
    _PromoCard(
      title: 'Free Delivery',
      subtitle: 'on orders above ₹999',
      cta: 'Explore',
      image: 'assets/images/green1.png',
    ),
    _PromoCard(
      title: 'New Arrivals',
      subtitle: 'fresh styles every week',
      cta: 'Browse',
      image: 'assets/images/yellow_shoe.png',
    ),
  ];

  // NEW: categories + selected value
  final categories = const ['All', 'Running', 'Sneakers', 'Formal', 'Casual'];
  String selectedCategory = 'All';

  final List<Product> allProducts = [
    Product('Air Max 97', 20.99, 'assets/images/yellow_shoe.png', 'Running'),
    Product('React Presto', 25.99, 'assets/images/blue1.png', 'Sneakers'),
    Product('Oxford Pro', 35.49, 'assets/images/green1.png', 'Formal'),
    Product('City Casual', 22.00, 'assets/images/blue1.png', 'Casual'),
    Product('Marathon Fly', 28.50, 'assets/images/yellow_shoe.png', 'Running'),
    Product('Street Low', 19.99, 'assets/images/green1.png', 'Sneakers'),
  ];

  List<Product> get filtered =>
      selectedCategory == 'All'
          ? allProducts
          : allProducts.where((p) => p.category == selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          margin: EdgeInsets.symmetric(vertical: 100),
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
                child: Image.asset(
                  'assets/icons/lines_icon.png',
                  width: 24,
                  height: 24,
                ),
              ),

              SizedBox(width: 20),
              Image.asset(
                'assets/icons/nike_logo.png',
                width: 65,
                height: 50,
                fit: BoxFit.fitHeight,
              ),

              SizedBox(width: 20),
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
      ),

      // Body
      body: Column(
        children: [
          const SizedBox(height: 24),
          CarouselSlider(
            items: _cards,
            options: CarouselOptions(
              height: 160,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              onPageChanged: (index, reason) {
                setState(() => _current = index);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _cards.asMap().entries.map((entry) {
                  final isActive = entry.key == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 12.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isActive ? Colors.black : Colors.black26,
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 15),

          CategorySlider(
            categories: categories,
            onChanged: (_, label) {
              setState(() => selectedCategory = label);
              // TODO: trigger your product filter here
              // e.g., call Provider/Bloc or filter a local list
            },
          ),
          const SizedBox(height: 12),

          // ===== Product grid (fills remaining space) =====
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filtered.length,
              itemBuilder:
                  (_, i) => ProductCard(
                    product: filtered[i],
                    onTap: () {
                      // TODO: Navigate to details or add to cart
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductDetailsPage(product: filtered[i]),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    ); // Placeholder, you'll replace this
  }
}

// Auto scroll slider

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final String image;

  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Color(0x1A000000),
        //     blurRadius: 12,
        //     offset: Offset(0, 6),
        //   ),
        // ],
      ),
      child: Stack(
        children: [
          // Product image on the right
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(image, width: 200, fit: BoxFit.fitHeight),
          ),
          // Text & button on the left
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 29, 170, 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(height: 0),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 5,
                    ),
                  ),
                  child: Text(cta, style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
