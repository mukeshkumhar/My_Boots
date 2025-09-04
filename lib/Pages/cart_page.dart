// lib/Pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:my_boots/core/auth_api.dart';
import 'package:my_boots/models/cart_item.dart';

import '../ServicesPage/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _api = AuthApi();
  late Future<List<CartItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.cart();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.cart();
    });
    await _future;
  }

  int _subtotal(List<CartItem> items) {
    var sum = 0;
    for (final it in items) {
      sum += it.unitPrice * it.quantity;
    }
    return sum;
  }

  // Adjust quantity optimistically
  Future<void> _changeQty(List<CartItem> items, int index, int delta) async {
    final it = items[index];
    final oldQty = it.quantity;
    final newQty = (oldQty + delta).clamp(0, 999);
    if (newQty == oldQty) return;

    // If going to 0, we remove the row
    CartItem? removed;
    if (newQty == 0) {
      removed = it;
      items.removeAt(index);
    } else {
      it.quantity = newQty;
    }
    setState(() {});

    try {
      if (newQty == 0) {
        await _api.removeFromCart(it.id);
      } else {
        await _api.updateCartQty(cartId: it.id, quantity: newQty);
      }
    } catch (e) {
      // rollback
      if (removed != null) {
        items.insert(index, removed);
      } else {
        it.quantity = oldQty;
      }
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update cart: $e')));
      }
    }
  }

  Future<void> _removeItem(List<CartItem> items, int index) async {
    final it = items.removeAt(index);
    setState(() {});
    try {
      await _api.removeFromCart(it.id);
    } catch (e) {
      items.insert(index, it);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
      }
    }
  }

  String _price(int v) => '₹$v';

  @override
  Widget build(BuildContext context) {
    // ⬇️ Move Scaffold *inside* FutureBuilder so totals are in scope
    return FutureBuilder<List<CartItem>>(
      future: _future,
      builder: (context, snap) {
        // Loading
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          );
        }

        // Error
        if (snap.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 120),
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Center(child: Text('Failed to load cart')),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final items = snap.data ?? <CartItem>[];

        // Empty
        if (items.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: Colors.black38,
                    ),
                    SizedBox(height: 12),
                    Center(child: Text('Your cart is empty')),
                  ],
                ),
              ),
            ),
          );
        }

        // Success
        final subtotal = _subtotal(items);
        const shipping = 99; // use backend value if available
        const tax = 0;
        final total = subtotal + shipping + tax;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ...List.generate(items.length, (i) {
                    final it = items[i];
                    final img = it.images.isNotEmpty ? it.images.first : null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 72,
                              height: 72,
                              color: Colors.white,
                              child:
                                  img == null
                                      ? const Icon(Icons.image, size: 32)
                                      : Image.network(
                                        img,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) =>
                                                const Icon(Icons.broken_image),
                                      ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Size UK ${it.size} • ${it.color} • Qty ${it.quantity}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                if (it.mrp > it.unitPrice) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _price(it.mrp),
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _price(it.unitPrice * it.quantity),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _changeQty(items, i, -1),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text('${it.quantity}'),
                                  IconButton(
                                    onPressed: () => _changeQty(items, i, 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                onPressed: () => _removeItem(items, i),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _RowPrice(label: 'Subtotal', value: _price(subtotal)),
                  _RowPrice(label: 'Shipping', value: _price(shipping)),
                  _RowPrice(label: 'Tax', value: _price(tax)),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 12),
                  _RowPrice(label: 'Total', value: _price(total), bold: true),
                  const SizedBox(height: 90), // bottom button space
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => CheckoutPage(
                              subtotal: subtotal,
                              shipping: shipping,
                              tax: tax,
                              total: total,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Proceed to Checkout'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RowPrice extends StatelessWidget {
  const _RowPrice({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}
