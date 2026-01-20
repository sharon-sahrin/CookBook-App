import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../constants.dart';
import '../recipe.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    });
    _searchController.addListener(() {
      Provider.of<RecipeProvider>(
        context,
        listen: false,
      ).setSearchQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipes = recipeProvider.recipes;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CookBook 🍳',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    recipeProvider.isGridView
                        ? Icons.view_list
                        : Icons.grid_view,
                  ),
                  onPressed: recipeProvider.toggleViewMode,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<RecipeProvider>(
              builder: (context, provider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.toggleShowMyRecipes(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !provider.showMyRecipes
                                ? Colors.orange
                                : Colors.grey.shade200,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Discover',
                              style: TextStyle(
                                color: !provider.showMyRecipes
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.toggleShowMyRecipes(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: provider.showMyRecipes
                                ? Colors.orange
                                : Colors.grey.shade200,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'My Cookbook',
                              style: TextStyle(
                                color: provider.showMyRecipes
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          const CategoryFilter(),
          const SizedBox(height: 8),

          Expanded(
            child: recipeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : recipes.isEmpty
                ? const Center(child: Text('No recipes found'))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: recipeProvider.isGridView
                        ? MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            itemCount: recipes.length,
                            itemBuilder: (ctx, i) =>
                                _buildRecipeItem(ctx, recipes[i], true),
                          )
                        : ListView.separated(
                            itemCount: recipes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, i) =>
                                _buildRecipeItem(ctx, recipes[i], false),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeItem(BuildContext context, Recipe recipe, bool isGrid) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final canDelete = (auth.user?.id == recipe.userId) || auth.isAdmin;

    return RecipeCard(
      recipe: recipe,
      isGrid: isGrid,
      showDelete: canDelete,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      onDelete: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete?'),
            content: const Text('Sure you want to delete?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          await Provider.of<RecipeProvider>(
            context,
            listen: false,
          ).deleteRecipe(recipe.id);
        }
      },
    );
  }
}

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppConstants.categories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.categories[index];
              final isSelected =
                  (category == 'All' && provider.selectedCategory == null) ||
                  category == provider.selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => provider.setCategory(category),
                  selectedColor: Colors.orange.shade200,
                  backgroundColor: Colors.grey.shade100,
                  checkmarkColor: Colors.orange.shade900,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool showDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isGrid,
    required this.onTap,
    required this.onDelete,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isGrid ? _grid(context) : _list(context),
            ),
          ),
          if (showDelete)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color.fromARGB(255, 54, 244, 184),
                ),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Text(
          recipe.icon,
          style: const TextStyle(fontSize: 48),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          recipe.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (recipe.category != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(
              child: Text(
                recipe.category!,
                style: TextStyle(color: Colors.orange.shade800, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _list(BuildContext context) {
    return Row(
      children: [
        Text(recipe.icon, style: const TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (recipe.category != null)
                Text(
                  recipe.category!,
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
