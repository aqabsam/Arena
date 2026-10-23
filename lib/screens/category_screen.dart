import 'package:flutter/material.dart';

import '../audio/game_audio_service.dart';
import '../data/category_repository.dart';
import '../game/game_session.dart';
import '../models/game_models.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.session});

  final GameSession session;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  GameSession get session => widget.session;
  late String? _selectedCategoryId = session.selectedCategory?.id;

  @override
  Widget build(BuildContext context) {
    final categories = session.categories.where((category) {
      return (category.enabled || category.isRandomMix) &&
          !_removedCategoryIds.contains(category.id);
    }).toList();
    final randomCategory = categories.firstWhere(
      (category) => category.isRandomMix,
      orElse: () => categories.first,
    );
    final selectableCategories = categories
        .where((category) => !category.isRandomMix)
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFF071B46),
      appBar: AppBar(title: const Text('Bid Challenge')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width < 340
                ? 1
                : width < 650
                ? 2
                : width < 960
                ? 3
                : width < 1240
                ? 4
                : 5;
            final horizontalPadding = width >= 1000 ? 28.0 : 16.0;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CategorySectionHeader(
                        count: selectableCategories.length,
                      ),
                      const SizedBox(height: 14),
                      _RandomMixCard(
                        category: randomCategory,
                        onTap: () {
                          setState(
                            () => _selectedCategoryId = randomCategory.id,
                          );
                          _selectCategory(context, session, randomCategory);
                        },
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: selectableCategories.length,
                          key: const ValueKey<String>('category-grid'),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 148,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final category = selectableCategories[index];
                            return _CategoryCard(
                              key: ValueKey<String>(
                                'category-card-${category.id}',
                              ),
                              category: category,
                              accent:
                                  _categoryColors[index %
                                      _categoryColors.length],
                              selected: _selectedCategoryId == category.id,
                              editable: _isEditable(category.id),
                              onTap: () {
                                setState(
                                  () => _selectedCategoryId = category.id,
                                );
                                _selectCategory(context, session, category);
                              },
                              onEdit: () => _editCategoryItems(
                                context,
                                session,
                                category,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

const _removedCategoryIds = <String>{
  'classmates',
  'schoolmates',
  'teachers',
  'friends',
};

bool _isEditable(String id) => id == 'custom';

void _selectCategory(
  BuildContext context,
  GameSession session,
  GameCategory category,
) {
  GameAudioService.instance.play(GameSound.selection);
  session.selectedCategory = category;
  Navigator.of(context).pushNamed('/team-size');
}

class _CategorySectionHeader extends StatelessWidget {
  const _CategorySectionHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'PICK YOUR ARENA',
            style: TextStyle(
              color: Color(0xFF65CFFF),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Choose a category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Pick a world and let the bidding begin.',
            style: TextStyle(color: Color(0xFF9BAAC5), fontSize: 12),
          ),
        ],
      );
      final badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF172744),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF344B70)),
        ),
        child: Text(
          '$count CATEGORIES',
          style: const TextStyle(
            color: Color(0xFFB9C9E7),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
          ),
        ),
      );
      if (constraints.maxWidth < 400) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[title, const SizedBox(height: 8), badge],
        );
      }
      return Row(
        children: <Widget>[
          Expanded(child: title),
          badge,
        ],
      );
    },
  );
}

class _RandomMixCard extends StatefulWidget {
  const _RandomMixCard({required this.category, required this.onTap});
  final GameCategory category;
  final VoidCallback onTap;

  @override
  State<_RandomMixCard> createState() => _RandomMixCardState();
}

class _RandomMixCardState extends State<_RandomMixCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() {
      _hovered = false;
      _pressed = false;
    }),
    child: AnimatedScale(
      scale: _pressed ? .99 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF36321F), Color(0xFF1B2238)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(
                  0xFFFFD36E,
                ).withValues(alpha: _hovered ? .9 : .52),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFFFD36E,
                  ).withValues(alpha: _hovered ? .15 : .07),
                  blurRadius: _hovered ? 22 : 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD36E).withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shuffle_rounded,
                    color: Color(0xFFFFD36E),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Surprise pick from every category',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFB6B4A7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFFFD36E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    super.key,
    required this.category,
    required this.accent,
    required this.selected,
    required this.editable,
    required this.onTap,
    required this.onEdit,
  });

  final GameCategory category;
  final Color accent;
  final bool selected;
  final bool editable;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() {
      _hovered = false;
      _pressed = false;
    }),
    child: AnimatedScale(
      scale: _pressed ? .975 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF192744),
                  Color.lerp(const Color(0xFF101A30), widget.accent, .14)!,
                ],
              ),
              border: Border.all(
                color: widget.selected
                    ? widget.accent
                    : widget.accent.withValues(alpha: _hovered ? .72 : .30),
                width: widget.selected ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(
                    alpha: widget.selected
                        ? .18
                        : _hovered
                        ? .13
                        : .055,
                  ),
                  blurRadius: _hovered || widget.selected ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _CategoryArtwork(
                      category: widget.category,
                      accent: widget.accent,
                    ),
                    const Spacer(),
                    if (widget.editable)
                      IconButton(
                        tooltip: 'Edit category items',
                        visualDensity: VisualDensity.compact,
                        onPressed: widget.onEdit,
                        icon: Icon(
                          Icons.edit_rounded,
                          color: widget.accent,
                          size: 18,
                        ),
                      )
                    else if (widget.selected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: widget.accent,
                        size: 21,
                      )
                    else
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withValues(alpha: .48),
                        size: 19,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.grid_view_rounded,
                      color: widget.accent,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.category.items.length} picks',
                      style: const TextStyle(
                        color: Color(0xFF9BAAC5),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _CategoryArtwork extends StatelessWidget {
  const _CategoryArtwork({required this.category, required this.accent});
  final GameCategory category;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final logoUrl = category.logoUrl;
    final artwork = Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: logoUrl == null
            ? accent.withValues(alpha: .14)
            : category.id == 'bgmi'
            ? const Color(0xFF15233D)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: .28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl == null
          ? Icon(_iconFor(category.id), color: accent, size: 25)
          : Image.network(
              CategoryRepository.categoryLogoRasterUrl(logoUrl),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(_iconFor(category.id), color: accent, size: 25),
            ),
    );
    final attribution = <String?>[
      category.logoName,
      category.logoLicense,
      category.logoSourcePage,
    ].whereType<String>().where((value) => value.isNotEmpty).join('\n');
    return attribution.isEmpty
        ? artwork
        : Tooltip(message: attribution, child: artwork);
  }
}

Future<void> _editCategoryItems(
  BuildContext context,
  GameSession session,
  GameCategory category,
) async {
  final controllers = category.items
      .map((item) => TextEditingController(text: item.name))
      .toList(growable: true);
  try {
    final names = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF12285C),
        title: Text('Edit ${category.name}'),
        content: SizedBox(
          width: 320,
          height: 360,
          child: ListView.builder(
            itemCount: controllers.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: controllers[index],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Item ${index + 1}',
                  filled: true,
                  fillColor: const Color(0xFF0A1C43),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controllers.map((controller) => controller.text).toList(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (names != null) {
      final distinct = names.map((name) => name.trim().toLowerCase()).toSet();
      if (distinct.length !=
          names.where((name) => name.trim().isNotEmpty).length) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Names must be unique.')));
        return;
      }
      // The custom pool can contain fewer items, but must not become empty.
      if (names.every((name) => name.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keep at least one item.')),
        );
        return;
      }
      session.updateEditableCategoryItems(category.id, names);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${category.name} saved for this session.')),
      );
    }
  } finally {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}

const _categoryColors = <Color>[
  Color(0xFFE51C3E),
  Color(0xFF0878E8),
  Color(0xFF343A40),
  Color(0xFFF04D35),
  Color(0xFF1D9AA8),
  Color(0xFF7D43AD),
  Color(0xFF0C5FD6),
  Color(0xFF19A467),
  Color(0xFF1580B8),
  Color(0xFF6B37C8),
  Color(0xFFE52A52),
  Color(0xFF1AAB5C),
  Color(0xFFD87022),
  Color(0xFF14A6BA),
  Color(0xFF4F58CA),
  Color(0xFF0B78D0),
];

IconData _iconFor(String id) => switch (id) {
  'marvel' || 'dc' => Icons.shield_rounded,
  'wwe' => Icons.sports_mma_rounded,
  'bollywood' ||
  'hollywood' ||
  'actors' ||
  'indian-movies' => Icons.movie_rounded,
  'ipl-teams' => Icons.emoji_events_rounded,
  'cricket-players' => Icons.sports_cricket_rounded,
  'intl-cricket' => Icons.flag_rounded,
  'football-clubs' => Icons.stadium_rounded,
  'football-players' => Icons.sports_soccer_rounded,
  'pokemon' => Icons.catching_pokemon_rounded,
  'doraemon' => Icons.toys_rounded,
  'chhota-bheem' => Icons.fitness_center_rounded,
  'ben10' => Icons.watch_rounded,
  'shinchan' => Icons.face_rounded,
  'cartoon-characters' => Icons.animation_rounded,
  'naruto' => Icons.flash_on_rounded,
  'dragon-ball' => Icons.whatshot_rounded,
  'minecraft' => Icons.grid_3x3_rounded,
  'free-fire' => Icons.local_fire_department_rounded,
  'bgmi' => Icons.military_tech_rounded,
  'singers' => Icons.music_note_rounded,
  'youtubers' => Icons.smart_display_rounded,
  'athletes' => Icons.fitness_center_rounded,
  'animals' => Icons.pets_rounded,
  'cars' => Icons.directions_car_rounded,
  'bikes' => Icons.motorcycle_rounded,
  'food' => Icons.restaurant_rounded,
  'countries' => Icons.public_rounded,
  'cities' => Icons.location_city_rounded,
  'brands' => Icons.sell_rounded,
  'superpowers' => Icons.bolt_rounded,
  'custom' => Icons.add_box_rounded,
  _ => Icons.auto_awesome_rounded,
};
