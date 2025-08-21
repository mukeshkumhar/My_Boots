import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...List.generate(3, (i) => _CartItem(index: i)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const _RowPrice(label: "Subtotal", value: "₹7,197"),
            const _RowPrice(label: "Shipping", value: "₹99"),
            const _RowPrice(label: "Tax", value: "₹0"),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 12),
            const _RowPrice(label: "Total", value: "₹7,296", bold: true),
            const SizedBox(height: 90), // leave room for bottom button
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              child: const Text("Proceed to Checkout"),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image, size: 32),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Air Max 97",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  "Size UK 8 • Qty 1",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const Text("₹2,399", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.remove_circle_outline),
              ),
              const Text("1"),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
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
