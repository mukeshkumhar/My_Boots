import 'package:flutter/material.dart';

class CategorySlider extends StatefulWidget {
  const CategorySlider({
    super.key,
    required this.categories,
    required this.onChanged, // (index, label)
    this.initialIndex = 0,
  });

  final List<String> categories;
  final void Function(int index, String label) onChanged;
  final int initialIndex;

  @override
  State<CategorySlider> createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  final _controller = ScrollController();
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  void _select(int i) {
    setState(() => _current = i);
    widget.onChanged(i, widget.categories[i]);
    // optional: scroll selected pill into view
    final approxItemW = 90.0;
    final target =
        (i * (approxItemW + 12)) -
        (MediaQuery.of(context).size.width / 2) +
        approxItemW / 2;
    _controller.animateTo(
      target.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final selected = i == _current;
          return GestureDetector(
            onTap: () => _select(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                widget.categories[i],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? Colors.white : Colors.black.withOpacity(0.35),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
