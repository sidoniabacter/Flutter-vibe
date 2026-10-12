import 'package:flutter/material.dart';

void main() {
  runApp(const VibeLabApp());
}

const _ink = Color(0xFF172B4D);
const _violet = Color(0xFF7456F1);
const _mint = Color(0xFFB8F2D5);
const _peach = Color(0xFFFFC9A8);
const _lemon = Color(0xFFFFE88A);

class VibeLabApp extends StatefulWidget {
  const VibeLabApp({super.key});

  @override
  State<VibeLabApp> createState() => _VibeLabAppState();
}

class _VibeLabAppState extends State<VibeLabApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeLab',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _violet),
        scaffoldBackgroundColor: const Color(0xFFF7F6FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F6FC),
          foregroundColor: _ink,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _violet,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
      ),
      home: VibeShell(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class VibeShell extends StatefulWidget {
  const VibeShell({
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<VibeShell> createState() => _VibeShellState();
}

class _VibeShellState extends State<VibeShell> {
  int _selectedTab = 0;
  final Set<String> _savedTopics = <String>{};
  int _bestScore = 0;

  static const _tabs = <(String, IconData, IconData)>[
    ('Home', Icons.home_rounded, Icons.home_outlined),
    ('Explore', Icons.explore_rounded, Icons.explore_outlined),
    ('Playground', Icons.palette_rounded, Icons.palette_outlined),
    ('Quiz', Icons.bolt_rounded, Icons.bolt_outlined),
  ];

  void _recordScore(int score) {
    if (score > _bestScore) {
      setState(() => _bestScore = score);
    }
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ProfileScreen(
          savedCount: _savedTopics.length,
          bestScore: _bestScore,
          isDark: widget.isDark,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        savedCount: _savedTopics.length,
        bestScore: _bestScore,
        onExplore: () => setState(() => _selectedTab = 1),
        onPlay: () => setState(() => _selectedTab = 2),
        onQuiz: () => setState(() => _selectedTab = 3),
      ),
      ExploreScreen(
        savedTopics: _savedTopics,
        onToggleSaved: (id) {
          setState(() {
            if (!_savedTopics.add(id)) _savedTopics.remove(id);
          });
        },
      ),
      const PlaygroundScreen(),
      QuizScreen(onScore: _recordScore),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 780;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: wide ? 28 : 20,
            title: const _Brand(),
            actions: [
              IconButton(
                tooltip: 'Your profile',
                onPressed: _openProfile,
                icon: const CircleAvatar(
                  radius: 17,
                  backgroundColor: _lemon,
                  child: Icon(Icons.face_rounded, color: _ink, size: 21),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Row(
            children: [
              if (wide)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                  child: NavigationRail(
                    selectedIndex: _selectedTab,
                    onDestinationSelected: (index) =>
                        setState(() => _selectedTab = index),
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final tab in _tabs)
                        NavigationRailDestination(
                          icon: Icon(tab.$3),
                          selectedIcon: Icon(tab.$2),
                          label: Text(tab.$1),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: IndexedStack(index: _selectedTab, children: pages),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _selectedTab,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedTab = index),
                  destinations: [
                    for (final tab in _tabs)
                      NavigationDestination(
                        icon: Icon(tab.$3),
                        selectedIcon: Icon(tab.$2),
                        label: tab.$1,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _violet,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.bubble_chart_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'vibe lab',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.7),
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.savedCount,
    required this.bestScore,
    required this.onExplore,
    required this.onPlay,
    required this.onQuiz,
    super.key,
  });

  final int savedCount;
  final int bestScore;
  final VoidCallback onExplore;
  final VoidCallback onPlay;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'MONDAY, BUT MAKE IT CREATIVE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: _violet,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your Flutter era\nstarts here.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.02,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 20),
          _HeroCard(onTap: onPlay),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pick your next adventure',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, color: _violet, size: 22),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 680 ? 3 : 1;
              final cards = [
                _AdventureCard(
                  icon: Icons.widgets_rounded,
                  title: 'Explore widgets',
                  subtitle: 'Meet the building blocks',
                  color: _mint,
                  onTap: onExplore,
                ),
                _AdventureCard(
                  icon: Icons.color_lens_rounded,
                  title: 'Make some noise',
                  subtitle: 'Play with live UI controls',
                  color: _peach,
                  onTap: onPlay,
                ),
                _AdventureCard(
                  icon: Icons.bolt_rounded,
                  title: 'Take the tiny quiz',
                  subtitle: 'Your best: $bestScore / 4',
                  color: _lemon,
                  onTap: onQuiz,
                ),
              ];
              if (columns == 1) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i < cards.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _ProgressCard(savedCount: savedCount, bestScore: bestScore),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _violet,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 216,
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: -32,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 28),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -65,
                child: Transform.rotate(
                  angle: -0.35,
                  child: Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                      color: _lemon,
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.17),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'TODAY\'S MINI QUEST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Build a button\nwith main character energy.',
                      style: TextStyle(
                        fontSize: 23,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Let\'s go',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white70,
                          size: 34,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdventureCard extends StatelessWidget {
  const _AdventureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _ink),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.savedCount, required this.bestScore});

  final int savedCount;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.28 : 1,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFF28A42),
            size: 31,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your learning snapshot',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '$savedCount saved · best quiz $bestScore / 4',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.trending_up_rounded, color: _violet),
        ],
      ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: child,
        ),
      ),
    );
  }
}

class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.code,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final IconData icon;
  final Color color;
  final String category;
  final String code;
}

const _topics = <Topic>[
  Topic(
    id: 'container',
    name: 'Container',
    tagline: 'The shape-shifter',
    description: 'A handy box for decorating, sizing, spacing and positioning one child. Think of it as a div with a very stylish wardrobe.',
    icon: Icons.crop_square_rounded,
    color: _peach,
    category: 'Layout',
    code: 'Container(\n  padding: const EdgeInsets.all(16),\n  decoration: BoxDecoration(\n    color: Colors.pink,\n    borderRadius: BorderRadius.circular(20),\n  ),\n  child: const Text("Hello!"),\n)',
  ),
  Topic(
    id: 'row',
    name: 'Row & Column',
    tagline: 'Your layout besties',
    description: 'Row places children horizontally; Column stacks them vertically. Both can align and space their children with a few simple properties.',
    icon: Icons.view_week_rounded,
    color: _mint,
    category: 'Layout',
    code: 'Row(\n  mainAxisAlignment:\n      MainAxisAlignment.spaceAround,\n  children: const [\n    Icon(Icons.star),\n    Text("Side by side!"),\n  ],\n)',
  ),
  Topic(
    id: 'state',
    name: 'setState',
    tagline: 'Give your UI a pulse',
    description: 'When local state changes, setState tells Flutter to rebuild this part of the widget tree so the screen can show the latest value.',
    icon: Icons.favorite_rounded,
    color: _lemon,
    category: 'State',
    code: 'setState(() {\n  likes++;\n});',
  ),
  Topic(
    id: 'animation',
    name: 'Implicit animation',
    tagline: 'Motion, minus the math',
    description: 'AnimatedContainer automatically animates changes to its color, size, padding and more. Update a value and Flutter fills in the motion.',
    icon: Icons.motion_photos_on_rounded,
    color: Color(0xFFD9CCFF),
    category: 'Motion',
    code: 'AnimatedContainer(\n  duration: const Duration(\n    milliseconds: 300,\n  ),\n  color: isOn ? Colors.purple : Colors.orange,\n)',
  ),
  Topic(
    id: 'navigation',
    name: 'NavigationBar',
    tagline: 'Hop between screens',
    description: 'Material navigation components make it easy to move between the top-level destinations in your app and show which one is active.',
    icon: Icons.navigation_rounded,
    color: Color(0xFFBFE7FF),
    category: 'Navigation',
    code: 'NavigationBar(\n  selectedIndex: index,\n  onDestinationSelected: (value) {\n    setState(() => index = value);\n  },\n  destinations: const [...],\n)',
  ),
];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    required this.savedTopics,
    required this.onToggleSaved,
    super.key,
  });

  final Set<String> savedTopics;
  final ValueChanged<String> onToggleSaved;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';

  static const _categories = ['All', 'Layout', 'State', 'Motion', 'Navigation'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = _topics.where((topic) {
      final matchesCategory = _category == 'All' || topic.category == _category;
      final matchesSearch =
          query.isEmpty ||
          topic.name.toLowerCase().contains(query) ||
          topic.tagline.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return _PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The widget zoo',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.9),
          ),
          const SizedBox(height: 6),
          Text(
            'Tiny building blocks. Big main-character energy.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search the zoo...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in _categories) ...[
                  ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No widgets found. Try another search.'),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 670 ? 2 : 1;
                if (columns == 1) {
                  return Column(
                    children: [
                      for (final topic in filtered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TopicCard(
                            topic: topic,
                            isSaved: widget.savedTopics.contains(topic.id),
                            onSave: () => widget.onToggleSaved(topic.id),
                          ),
                        ),
                    ],
                  );
                }
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final topic in filtered)
                      SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: _TopicCard(
                          topic: topic,
                          isSaved: widget.savedTopics.contains(topic.id),
                          onSave: () => widget.onToggleSaved(topic.id),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.isSaved,
    required this.onSave,
  });

  final Topic topic;
  final bool isSaved;
  final VoidCallback onSave;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TopicDetailScreen(
          topic: topic,
          isSaved: isSaved,
          onToggleSaved: onSave,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: topic.color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(topic.icon, color: _ink, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      topic.tagline,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _violet,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isSaved ? 'Remove from saved' : 'Save topic',
                onPressed: onSave,
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border,
                  color: isSaved ? _violet : null,
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    required this.topic,
    required this.isSaved,
    required this.onToggleSaved,
    super.key,
  });

  final Topic topic;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  int _taps = 0;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.name),
        actions: [
          IconButton(
            tooltip: _isSaved ? 'Remove saved topic' : 'Save topic',
            onPressed: () {
              widget.onToggleSaved();
              setState(() => _isSaved = !_isSaved);
            },
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),
      body: _PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: topic.color,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(topic.icon, color: _ink, size: 74),
            ),
            const SizedBox(height: 22),
            Text(
              topic.tagline,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: _violet, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              topic.name,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              topic.description,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 22),
            Text(
              'A little Dart, a lot of possibilities',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF192338),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SelectableText(
                topic.code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFD6CBFF),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: FilledButton.icon(
                onPressed: () => setState(() => _taps++),
                icon: const Icon(Icons.touch_app_rounded),
                label: Text(
                  _taps == 0
                      ? 'Try it: tap me'
                      : 'Nice! You tapped $_taps ${_taps == 1 ? 'time' : 'times'}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  Color _color = _violet;
  double _radius = 28;
  bool _showIcon = true;
  bool _isBig = false;

  static const _swatches = <Color>[
    _violet,
    Color(0xFFEF7292),
    Color(0xFF20A982),
    Color(0xFF3986E8),
    Color(0xFFFF9D4D),
  ];

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The playground',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.9),
          ),
          const SizedBox(height: 6),
          Text(
            'Change a value. Watch the widget react.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            width: double.infinity,
            height: _isBig ? 260 : 220,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: [
                BoxShadow(
                  color: _color.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showIcon
                    ? const Icon(
                        Icons.flutter_dash_rounded,
                        key: ValueKey('dash'),
                        color: Colors.white,
                        size: 92,
                      )
                    : const Text(
                        'Look at me!',
                        key: ValueKey('text'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 27,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _ControlCard(
            title: 'Pick a vibe',
            child: Wrap(
              spacing: 12,
              children: [
                for (final color in _swatches)
                  GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: _color == color ? 43 : 36,
                      height: _color == color ? 43 : 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _color == color
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: _color == color
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ControlCard(
            title: 'Round those corners',
            trailing: Text(
              '${_radius.round()} px',
              style: const TextStyle(
                color: _violet,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Slider(
              value: _radius,
              min: 0,
              max: 64,
              divisions: 16,
              label: '${_radius.round()} px',
              onChanged: (value) => setState(() => _radius = value),
            ),
          ),
          const SizedBox(height: 12),
          _ControlCard(
            title: 'Extra magic',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show the Flutter mascot'),
                  value: _showIcon,
                  onChanged: (value) => setState(() => _showIcon = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Make it extra big'),
                  value: _isBig,
                  onChanged: (value) => setState(() => _isBig = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_rounded),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You just used state, sliders, switches and implicit animations. That\'s real Flutter!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(17, 14, 17, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _Question {
  const _Question(this.prompt, this.options, this.answer, this.fact);

  final String prompt;
  final List<String> options;
  final int answer;
  final String fact;
}

const _questions = <_Question>[
  _Question(
    'What does Flutter use to build its UI?',
    ['Widgets', 'HTML tags', 'DOM nodes', 'Magic beans'],
    0,
    'Almost everything you see in Flutter is a widget — even padding and layout.',
  ),
  _Question(
    'Which widget puts children side by side?',
    ['Column', 'Row', 'StackOverflow', 'Scaffold'],
    1,
    'Row lays out its children horizontally; Column stacks them vertically.',
  ),
  _Question(
    'What tells Flutter local state has changed?',
    ['refreshPage()', 'reloadWidget()', 'setState()', 'updateDOM()'],
    2,
    'setState schedules a rebuild so the UI can reflect the new state.',
  ),
  _Question(
    'What does hot reload help you do?',
    [
      'Try code changes quickly',
      'Make coffee',
      'Publish to the app store',
      'Delete all your widgets',
    ],
    0,
    'Hot reload injects code changes into a running app while keeping its state.',
  ),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({required this.onScore, super.key});

  final ValueChanged<int> onScore;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _finished = false;

  void _answer(int index) {
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = index;
      if (index == _questions[_questionIndex].answer) _score++;
    });
  }

  void _next() {
    if (_questionIndex == _questions.length - 1) {
      setState(() => _finished = true);
      widget.onScore(_score);
    } else {
      setState(() {
        _questionIndex++;
        _selectedAnswer = null;
      });
    }
  }

  void _restart() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _PageFrame(
        child: _QuizResult(score: _score, onRestart: _restart),
      );
    }

    final question = _questions[_questionIndex];
    return _PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The tiny quiz',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.9),
          ),
          const SizedBox(height: 6),
          Text(
            'Four questions. Zero pressure. Maximum bragging rights.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 23),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUESTION ${_questionIndex + 1} OF ${_questions.length}',
                style: const TextStyle(
                  color: _violet,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$_score correct',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (_questionIndex + 1) / _questions.length,
              minHeight: 9,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _lemon,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              question.prompt,
              style: const TextStyle(
                color: _ink,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < question.options.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerTile(
                label: question.options[index],
                index: index,
                selected: _selectedAnswer == index,
                correct: question.answer == index,
                hasAnswered: _selectedAnswer != null,
                onTap: () => _answer(index),
              ),
            ),
          if (_selectedAnswer != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: question.answer == _selectedAnswer ? _mint : _peach,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    question.answer == _selectedAnswer
                        ? Icons.check_circle_rounded
                        : Icons.tips_and_updates_rounded,
                    color: _ink,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question.fact,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _next,
                child: Text(
                  _questionIndex == _questions.length - 1
                      ? 'See my results'
                      : 'Next question',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.label,
    required this.index,
    required this.selected,
    required this.correct,
    required this.hasAnswered,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool selected;
  final bool correct;
  final bool hasAnswered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = hasAnswered && correct
        ? _mint
        : selected
        ? _peach
        : Theme.of(context).colorScheme.surface;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 31,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasAnswered && correct)
                const Icon(Icons.check_rounded, color: _ink),
              if (selected && !correct)
                const Icon(Icons.close_rounded, color: _ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizResult extends StatelessWidget {
  const _QuizResult({required this.score, required this.onRestart});

  final int score;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final message = switch (score) {
      4 => 'Okay, Flutter legend!',
      3 => 'You really get the vibe.',
      2 => 'Your Flutter era is loading.',
      _ => 'Every pro starts somewhere.',
    };
    return Column(
      children: [
        const SizedBox(height: 44),
        Container(
          width: 132,
          height: 132,
          decoration: const BoxDecoration(
            color: _lemon,
            shape: BoxShape.circle,
          ),
          child: Icon(
            score >= 3
                ? Icons.celebration_rounded
                : Icons.rocket_launch_rounded,
            color: _ink,
            size: 66,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          'You got $score out of ${_questions.length} right.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Play again'),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.savedCount,
    required this.bestScore,
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  final int savedCount;
  final int bestScore;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your little corner')),
      body: _PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _violet,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: _lemon,
                    child: Icon(Icons.face_rounded, color: _ink, size: 46),
                  ),
                  SizedBox(height: 13),
                  Text(
                    'Future Flutter dev',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Professional widget explorer',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.bookmark_rounded,
                    value: '$savedCount',
                    label: 'Saved topics',
                    color: _mint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.bolt_rounded,
                    value: '$bestScore / 4',
                    label: 'Best quiz',
                    color: _lemon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 0,
              child: SwitchListTile(
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                ),
                title: const Text(
                  'Night owl mode',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Switch the app theme'),
                value: isDark,
                onChanged: (_) => onToggleTheme(),
              ),
            ),
            const SizedBox(height: 12),
            const _ProfileTip(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _ink),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ProfileTip extends StatelessWidget {
  const _ProfileTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_rounded),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'VibeLab is a tiny playground, not a textbook. Tap around, change things, and learn by seeing what happens.',
              style: TextStyle(fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
