import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_state.dart';
import '../../logic/recipe/recipe_bloc.dart';
import '../../logic/recipe/recipe_event.dart';
import '../../logic/recipe/recipe_state.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({Key? key}) : super(key: key);

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Recipes (e.g. Chicken)",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<RecipeBloc>().add(
                        SearchRecipes(_searchController.text),
                      );
                    }
                  },
                ),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty)
                  context.read<RecipeBloc>().add(SearchRecipes(val));
              },
            ),
          ),

          // 2. Pantry Ingredients Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "From Your Pantry",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          SizedBox(
            height: 60,
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return ActionChip(
                        label: Text(item.name),
                        avatar: const Icon(Icons.add, size: 16),
                        onPressed: () {
                          _searchController.text = item.name;
                          context.read<RecipeBloc>().add(
                            SearchRecipes(item.name),
                          );
                        },
                      );
                    },
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Loading pantry..."),
                );
              },
            ),
          ),

          // 3. Results Grid
          Expanded(
            child: BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, state) {
                if (state is RecipeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RecipeLoaded) {
                  if (state.recipes.isEmpty) {
                    return const Center(child: Text("No recipes found."));
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final recipe = state.recipes[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: CachedNetworkImage(
                                      imageUrl: recipe.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Container(
                                            color: Colors.grey[200],
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      recipe.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }, childCount: state.recipes.length),
                        ),
                      ),
                      if (state.hasMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.read<RecipeBloc>().add(
                                    LoadMoreRecipes(),
                                  );
                                },
                                icon: const Icon(Icons.expand_more),
                                label: Text(
                                  'Load More (${state.recipes.length}/${state.allRecipes.length})',
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  );
                } else if (state is RecipeError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(state.message, textAlign: TextAlign.center),
                    ),
                  );
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Discover Recipes',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Search for recipes using ingredients from your pantry, or type any ingredient to find delicious meals!',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
