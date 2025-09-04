// lib/ServicesPage/checkout_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  final int subtotal;
  final int shipping;
  final int tax;
  final int total;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _upiController =
      TextEditingController(); // user UPI id if they want to pay-to-payee
  final _cardNumber = TextEditingController();
  final _cardHolder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _upiController.dispose();
    _cardNumber.dispose();
    _cardHolder.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  String _price(int v) => '₹$v';

  // --- UPI Deep Link helper ---
  // Replace with your real merchant VPA & name
  static const String _merchantVpa = '9064784636@naviaxis'; // TODO: your UPI ID
  static const String _merchantName = 'MyBoots'; // TODO: your merchant name

  Future<void> _payWithUPI({String? package}) async {
    // Build a UPI URI. Most UPI apps accept this.
    final amount = widget.total.toString();
    final uri = Uri.parse(
      'upi://pay?pa=$_merchantVpa&pn=${Uri.encodeComponent(_merchantName)}'
      '&am=$amount&tn=${Uri.encodeComponent("MyBoots Order")}&cu=INR',
    );

    setState(() => _paying = true);
    try {
      // If you want to target a specific package on Android (e.g., com.phonepe.app),
      // you typically use android_intent_plus. url_launcher alone can still open
      // the chooser or the default app:
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No UPI app found')));
        }
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  // Stub: Card payment (Integrate Stripe/Razorpay SDK in real app)
  Future<void> _payWithCard() async {
    // Basic validation (very light)
    if (_cardNumber.text.trim().length < 12 ||
        _expiry.text.trim().isEmpty ||
        _cvv.text.trim().length < 3 ||
        _cardHolder.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid card details')));
      return;
    }

    setState(() => _paying = true);
    try {
      // TODO: Integrate payment gateway SDK (e.g., razorpay_flutter / stripe_sdk)
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Card payment simulated')));
        Navigator.of(context).pop(); // back to cart/home on success
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row('Subtotal', _price(widget.subtotal)),
          _row('Shipping', _price(widget.shipping)),
          _row('Tax', _price(widget.tax)),
          const Divider(height: 20),
          _row('Total', _price(widget.total), bold: true),
        ],
      ),
    );
  }

  Widget _row(String l, String r, {bool bold = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(l, style: style),
          const Spacer(),
          Text(r, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _summaryCard()),
            const SizedBox(height: 8),
            TabBar(
              controller: _tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: 'UPI'),
                Tab(text: 'Card'),
                Tab(text: 'Wallets'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // --- UPI TAB ---
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay with UPI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You can pay using any UPI app installed on your phone.',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _paying ? null : () => _payWithUPI(),
                                icon: const Icon(Icons.payment),
                                label: Text(
                                  _paying ? 'Opening...' : 'Pay via UPI',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Or enter your UPI ID (optional):'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _upiController,
                          decoration: const InputDecoration(
                            hintText: 'yourname@upi',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Note: In production, set your merchant VPA & validate collect request with your PSP/gateway.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  // --- CARD TAB ---
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay with Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cardHolder,
                          decoration: const InputDecoration(
                            labelText: 'Cardholder Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cardNumber,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Card Number',
                            hintText: 'XXXX XXXX XXXX XXXX',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _expiry,
                                keyboardType: TextInputType.datetime,
                                decoration: const InputDecoration(
                                  labelText: 'Expiry (MM/YY)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _cvv,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _paying ? null : _payWithCard,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _paying
                                  ? 'Processing...'
                                  : 'Pay ₹${widget.total}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Production tip: integrate a gateway SDK (Razorpay, Stripe) for PCI-compliant card flows.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  // --- WALLETS / APPS TAB ---
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay using Wallets/Apps',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _walletButton(
                              'PhonePe',
                              Icons.account_balance_wallet,
                              onTap: _paying ? null : () => _payWithUPI(),
                            ),
                            _walletButton(
                              'Google Pay',
                              Icons.account_balance,
                              onTap: _paying ? null : () => _payWithUPI(),
                            ),
                            _walletButton(
                              'Paytm',
                              Icons.payments,
                              onTap: _paying ? null : () => _payWithUPI(),
                            ),
                            _walletButton(
                              'BHIM',
                              Icons.qr_code,
                              onTap: _paying ? null : () => _payWithUPI(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'All above apps support UPI. We use a standard UPI deep link so your default/selected app handles the payment.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
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

  Widget _walletButton(String label, IconData icon, {VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black12),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
