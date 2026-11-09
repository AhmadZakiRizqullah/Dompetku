import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Maps icon name strings to Material icons for wallet types
class WalletIconWidget extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const WalletIconWidget({
    super.key,
    required this.iconName,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  static IconData _iconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'bca':
        return Icons.credit_card_rounded;
      case 'mandiri':
        return Icons.credit_card_rounded;
      case 'bni':
        return Icons.credit_card_rounded;
      case 'bri':
        return Icons.credit_card_rounded;
      case 'gopay':
      case 'go-pay':
        return Icons.smartphone_rounded;
      case 'ovo':
        return Icons.smartphone_rounded;
      case 'shopeepay':
      case 'shopee':
        return Icons.shopping_bag_rounded;
      case 'dana':
        return Icons.smartphone_rounded;
      case 'linkaja':
        return Icons.link_rounded;
      case 'wallet':
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.secondary.withOpacity(0.12);
    final fgColor = iconColor ?? AppColors.primary;
    final icon = _iconFromName(iconName);
    final iconSize = size * 0.55;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: fgColor, size: iconSize),
    );
  }
}

/// Maps category icon names to Material icons
class CategoryIconWidget extends StatelessWidget {
  final String iconName;
  final String categoryType; // INCOME or EXPENSE
  final double size;

  const CategoryIconWidget({
    super.key,
    required this.iconName,
    required this.categoryType,
    this.size = 40,
  });

  static IconData _iconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bill':
        return Icons.receipt_long_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'communication':
        return Icons.phone_android_rounded;
      case 'salary':
        return Icons.work_rounded;
      case 'bonus':
        return Icons.star_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'freelance':
        return Icons.laptop_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = categoryType == CategoryType.income;
    final bgColor = isIncome
        ? AppColors.income.withOpacity(0.1)
        : AppColors.expense.withOpacity(0.1);
    final fgColor = isIncome ? AppColors.income : AppColors.expense;
    final icon = _iconFromName(iconName);
    final iconSize = size * 0.55;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: fgColor, size: iconSize),
    );
  }
}
