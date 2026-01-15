import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/recipe_detail.dart';
import '../../data/content/recipe_provider.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;
  final String recipeTitle;
  final String imageUrl;

  const RecipeDetailsScreen({
    Key? key,
    required this.recipeId,
    required this.recipeTitle,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late Future<RecipeDetail> _recipeDetailFuture;
  late TabController _tabController;
  final RecipeProvider _recipeProvider = RecipeProvider();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recipeDetailFuture = _recipeProvider.getRecipeDetails(widget.recipeId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchYouTube(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: FutureBuilder<RecipeDetail>(
        future: _recipeDetailFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              // Hero Image with App Bar
              _buildSliverAppBar(context, snapshot.data, isDark),

              // Content
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: _buildErrorState(snapshot.error.toString()),
                )
              else if (snapshot.hasData)
                ..._buildContent(context, snapshot.data!, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    RecipeDetail? detail,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        if (detail?.youtubeUrl != null && detail!.youtubeUrl!.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.play_circle_fill, color: Colors.red[600]),
              onPressed: () => _launchYouTube(detail.youtubeUrl),
              tooltip: 'Watch on YouTube',
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            Hero(
              tag: 'recipe_${widget.recipeId}',
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Icon(Icons.restaurant, size: 60),
                    ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipeTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.category,
                          detail.category,
                          Colors.orangeAccent,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.public,
                          detail.area,
                          Colors.blueAccent,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    RecipeDetail detail,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return [
      // Tab Bar
      SliverPersistentHeader(
        pinned: true,
        delegate: _SliverTabBarDelegate(
          TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Ingredients'),
              Tab(icon: Icon(Icons.format_list_numbered), text: 'Instructions'),
            ],
          ),
          isDark ? const Color(0xFF1E1E1E) : Colors.white,
        ),
      ),

      // Tab Content
      SliverFillRemaining(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Ingredients Tab
            _buildIngredientsTab(detail, isDark, theme),
            // Instructions Tab
            _buildInstructionsTab(detail, isDark, theme),
          ],
        ),
      ),
    ];
  }

  Widget _buildIngredientsTab(
    RecipeDetail detail,
    bool isDark,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: detail.ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = detail.ingredients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0.2),
                    theme.primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            title: Text(
              ingredient.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle:
                ingredient.measure.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        ingredient.measure,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    )
                    : null,
            trailing: const SizedBox(width: 8),
          ),
        );
      },
    );
  }

  Widget _buildInstructionsTab(
    RecipeDetail detail,
    bool isDark,
    ThemeData theme,
  ) {
    // Split instructions into steps
    final steps =
        detail.instructions
            .split(RegExp(r'\r\n|\n|\r'))
            .where((step) => step.trim().isNotEmpty)
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Step content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _cleanStepText(steps[index]),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? Colors.grey[200] : Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Cleans up redundant step prefixes from instruction text
  /// Removes patterns like "Step 1:", "STEP 1.", "1.", "1)", etc.
  String _cleanStepText(String text) {
    // Remove "Step X" or "STEP X" prefix (with optional colon, period, or dash)
    String cleaned = text.replaceFirst(
      RegExp(r'^[Ss][Tt][Ee][Pp]\s*\d+\s*[:\.\-]?\s*', caseSensitive: false),
      '',
    );
    // Remove leading number patterns like "1.", "1)", "1-"
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\s*[:\.\)\-]\s*'), '');
    return cleaned.trim();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _recipeDetailFuture = _recipeProvider.getRecipeDetails(
                    widget.recipeId,
                  );
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom delegate for sticky tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
