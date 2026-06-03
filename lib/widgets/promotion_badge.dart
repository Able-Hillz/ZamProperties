import 'package:flutter/material.dart';

class PromotionBadge extends StatelessWidget {
  final bool isPromoted;
  final double size;

  const PromotionBadge({
    super.key,
    required this.isPromoted,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPromoted) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.3, vertical: size * 0.15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: size * 0.8),
          const SizedBox(width: 2),
          Text(
            'PROMOTED',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}