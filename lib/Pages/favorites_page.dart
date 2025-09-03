import 'package:flutter/material.dart';
import 'package:my_boots/core/auth_api.dart';
import 'package:my_boots/models/liked_item.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _api = AuthApi();
  late Future<List<LikedItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.favorites();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.favorites();
    });
    await _future;
  }

  Future<void> _remove(LikedItem item, int index, List<LikedItem> items) async {
    // Optimistic UI
    final removed = items.removeAt(index);
    setState(() {});

    try {
      await _api.removeFavorite(item.id);
      // success: nothing else to do
    } catch (_) {
      // rollback on error
      items.insert(index, removed);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove. Please try again.')),
        );
      }
    }
  }

  String _price(int v) => '₹$v';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<LikedItem>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                // MAKE LOADING STATE SCROLLABLE so pull-to-refresh works
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }
              if (snap.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 12),
                    const Center(child: Text('Failed to load favorites')),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                );
              }

              final items = snap.data ?? <LikedItem>[];
              if (items.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Icon(
                      Icons.favorite_border,
                      size: 48,
                      color: Colors.black38,
                    ),
                    SizedBox(height: 12),
                    Center(child: Text('No favorites yet')),
                  ],
                );
              }

              return ListView.separated(
                // FORCE SCROLLABILITY even with few items
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final it = items[i];
                  final img = it.images.isNotEmpty ? it.images.first : null;
                  final subtitlePieces = <String>[
                    it.product.category,
                    if (it.color.isNotEmpty) it.color,
                    if (it.size != 0) 'UK ${it.size}',
                  ];
                  final subtitle = subtitlePieces
                      .where((e) => e.trim().isNotEmpty)
                      .join(' • ');

                  return Container(
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
                                subtitle,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _price(it.unitPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (it.mrp > it.unitPrice)
                              Text(
                                _price(it.mrp),
                                style: const TextStyle(
                                  color: Colors.black45,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _remove(it, i, items),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
