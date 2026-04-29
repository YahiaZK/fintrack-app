import 'package:flutter/material.dart';

IconData iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.restaurant;
    case 'car':
    case 'fuel':
    case 'transport':
      return Icons.directions_car_filled;
    case 'shopping':
      return Icons.shopping_bag;
    case 'bills':
    case 'utilities':
      return Icons.receipt_long;
    case 'entertainment':
    case 'leisure':
      return Icons.movie;
    case 'health':
      return Icons.favorite;
    case 'education':
      return Icons.school;
    case 'travel':
      return Icons.flight;
    case 'savings':
      return Icons.savings_outlined;
    case 'home':
      return Icons.home_outlined;
    default:
      return Icons.flag_outlined;
  }
}
