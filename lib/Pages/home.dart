import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_boots/Pages/cart_page.dart';
import 'package:my_boots/Pages/favorites_page.dart';
import 'package:my_boots/Pages/product_details_page.dart';
import 'package:my_boots/Pages/profile_page.dart';
import '../widgets/product_card.dart';
import '../widgets/category_slider.dart'; // Or cupertino.dart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;
  int _currentIndex = 0;

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
    Product('Air Max 97', 2099, 'assets/images/yellow_shoe.png', 'Running'),
    Product('React Presto', 2599, 'assets/images/blue1.png', 'Sneakers'),
    Product('Oxford Pro', 3549, 'assets/images/green1.png', 'Formal'),
    Product('City Casual', 2200, 'assets/images/blue1.png', 'Casual'),
    Product('Marathon Fly', 2899, 'assets/images/yellow_shoe.png', 'Running'),
    Product('Street Low', 1999, 'assets/images/green1.png', 'Sneakers'),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 100),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconBox('assets/icons/lines_icon.png'),
              const SizedBox(width: 20),
              Image.asset(
                'assets/icons/nike_logo.png',
                width: 65,
                height: 50,
                fit: BoxFit.fitHeight,
              ),
              const SizedBox(width: 20),
              const Spacer(),
              _iconBox('assets/icons/cart_logo.png'),
            ],
          ),
        ),
      ),

      // ✅ Switch pages via IndexedStack
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeBody(), // your existing home UI
          const FavoritesPage(), // make sure these screens exist
          const CartPage(),
          const ProfilePage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // keeps labels visible
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // --- helpers ---

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // --- Carousel ---
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

          // --- Dots ---
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

          // --- Category slider ---
          CategorySlider(
            categories: categories,
            onChanged: (_, label) {
              setState(() => selectedCategory = label);
            },
          ),
          const SizedBox(height: 12),

          // --- Product grid (now NON-scrollable; page scrolls instead) ---
          GridView.builder(
            shrinkWrap: true, // <-- important
            physics: const NeverScrollableScrollPhysics(), // <-- important
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProductDetailsPage(product: filtered[i]),
                      ),
                    );
                  },
                ),
          ),

          const SizedBox(
            height: 16,
          ), // bottom padding so it doesn't hug nav bar
        ],
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
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(18),
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
                  child: Text(cta, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
