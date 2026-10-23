import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/game_models.dart';

class CategoryRepository {
  static String categoryLogoRasterUrl(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.path.toLowerCase().endsWith('.svg')) {
      return imageUrl;
    }
    const commonsPath = '/wikipedia/commons/';
    final pathIndex = uri.path.indexOf(commonsPath);
    if (pathIndex < 0) return imageUrl;
    final filePath = uri.path.substring(pathIndex + commonsPath.length);
    final fileName = filePath.split('/').last;
    return 'https://${uri.host}/wikipedia/commons/thumb/$filePath/160px-$fileName.png';
  }

  static Future<List<GameCategory>> loadCategories() async {
    final data = await rootBundle.loadString('assets/data/categories.json');
    final json = jsonDecode(data) as Map<String, dynamic>;
    final rawCategories = json['categories'] as List<dynamic>;
    final categories = rawCategories
        .map(
          (category) => GameCategory.fromJson(category as Map<String, dynamic>),
        )
        .toList();
    validateCategories(categories);
    return categories;
  }

  static Future<void> validateReferencedAssets(
    List<GameCategory> categories,
  ) async {
    // Character art is loaded from predefined URLs; no character images ship
    // as individual Flutter assets.
  }

  static void validateCategories(List<GameCategory> categories) {
    final categoryIds = <String>{};
    final itemIds = <String>{};
    for (final category in categories) {
      if (!categoryIds.add(category.id)) {
        throw FormatException('Duplicate category id: ${category.id}');
      }
      final itemNames = <String>{};
      for (final item in category.items) {
        if (!itemIds.add(item.id)) {
          throw FormatException('Duplicate item id: ${item.id}');
        }
        if (item.categoryId != category.id) {
          throw FormatException(
            'Item ${item.id} is assigned to ${item.categoryId}, expected ${category.id}',
          );
        }
        if (item.name.trim().isEmpty ||
            !itemNames.add(item.name.trim().toLowerCase())) {
          throw FormatException(
            'Empty or duplicate item name in ${category.name}: ${item.name}',
          );
        }
      }
    }
  }

  static List<GameItem> buildMixedItemPool(List<GameCategory> categories) {
    final items = <GameItem>[];
    for (final category in categories) {
      if (category.enabled && !category.isRandomMix) {
        items.addAll(category.items.where((item) => item.enabled));
      }
    }
    final shuffled = List<GameItem>.from(items);
    shuffled.shuffle();
    return shuffled;
  }
}
