import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: AppColors.warning, size: size);
        } else if (index < rating.ceil() && rating % 1 != 0) {
          return Icon(Icons.star_half, color: AppColors.warning, size: size);
        } else {
          return Icon(Icons.star_border, color: AppColors.warning, size: size);
        }
      }),
    );
  }
}

