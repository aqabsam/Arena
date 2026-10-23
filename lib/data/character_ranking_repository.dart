import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/character_ranking.dart';

class CharacterRankingRepository {
  static const Map<String, String> libraryCategoryByRankingCategory =
      <String, String>{
        'Indian Cricket Players': 'Cricket Players',
        'International Cricket Players': 'Cricket Players',
        'Indian Singers': 'Singers',
        'International Singers': 'Singers',
        'Indian YouTubers': 'YouTubers',
        'International YouTubers': 'YouTubers',
        'Other Famous Athletes': 'Athletes',
        'Other Cartoons': 'Cartoon Characters',
      };

  static String libraryCategoryName(String rankingCategory) =>
      libraryCategoryByRankingCategory[rankingCategory] ?? rankingCategory;

  static Future<Map<String, List<CharacterRanking>>> loadRankings() async {
    final content = await rootBundle.loadString(
      'assets/data/character_rankings.json',
    );
    final json = jsonDecode(content) as Map<String, dynamic>;
    final categories = json['categories'] as List<dynamic>;
    final rankings = <String, List<CharacterRanking>>{};
    for (final rawCategory in categories) {
      final category = rawCategory as Map<String, dynamic>;
      final categoryName = category['name'] as String;
      if (rankings.containsKey(categoryName)) {
        throw FormatException('Duplicate ranking category: $categoryName');
      }
      final characters = (category['characters'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((entry) {
            final name = entry['name'] as String;
            final rank = entry['rank'] as int;
            return CharacterRanking(
              category: categoryName,
              id: '${_slug(categoryName)}_${rank.toString().padLeft(3, '0')}',
              name: name,
              rank: rank,
            );
          })
          .toList(growable: false);
      validateCategory(categoryName, characters);
      rankings[categoryName] = characters;
    }
    return rankings;
  }

  static void validateCategory(
    String category,
    List<CharacterRanking> characters,
  ) {
    final ranks = <int>{};
    final names = <String>{};
    for (final character in characters) {
      final rank = character.rank;
      if (rank == null || rank < 1 || rank > 50) {
        throw FormatException('Invalid rank in $category: ${character.name}');
      }
      if (!ranks.add(rank)) {
        throw FormatException('Duplicate rank $rank in $category');
      }
      if (!names.add(_normalizedName(character.name))) {
        throw FormatException(
          'Duplicate character in $category: ${character.name}',
        );
      }
    }
    if (ranks.length != 50 || !ranks.contains(1) || !ranks.contains(50)) {
      throw FormatException('$category must define ranks 1 through 50');
    }
  }

  static CharacterRanking? findByName(
    List<CharacterRanking> rankings,
    String name,
  ) {
    final normalized = _normalizedName(name);
    for (final ranking in rankings) {
      if (_normalizedName(ranking.name) == normalized) return ranking;
      final aliasTarget = _aliases[normalized];
      if (aliasTarget != null &&
          _normalizedName(aliasTarget) == _normalizedName(ranking.name)) {
        return ranking;
      }
      final reverseAlias = _aliases[_normalizedName(ranking.name)];
      if (reverseAlias != null && _normalizedName(reverseAlias) == normalized) {
        return ranking;
      }
    }
    return null;
  }

  static String _slug(String input) => input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  static String _normalizedName(String input) => input
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('á', 'a')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  static const Map<String, String> _aliases = <String, String>{
    'wandamaximoff': 'scarletwitch',
    'priyankachoprajonas': 'priyankachopra',
    'flash': 'theflash',
    'joker': 'thejoker',
    'greenlantern': 'greenlanternhaljordan',
    'mbappe': 'kylianmbappe',
    'naruto': 'narutouzumaki',
    'sasuke': 'sasukeuchiha',
    'sakura': 'sakuraharuno',
    'kakashi': 'kakashihatake',
    'hinata': 'hinatahyuga',
    'shikamaru': 'shikamarunara',
    'itachi': 'itachiuchiha',
    'neji': 'nejihyuga',
    'madara': 'madarauchiha',
    'shinchan': 'shinnosukenohara',
    'himawari': 'Himawari Nohara',
    'misae': 'misaenohara',
    'kazama': 'torukazama',
    'nene': 'nenesakurada',
    'masao': 'masaosato',
    'bochan': 'bosuzuki',
    'tohru': 'torukazama',
    'goku': 'songoku',
    'gohan': 'songohan',
  };
}
