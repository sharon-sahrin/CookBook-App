import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../recipe.dart';
import '../constants.dart';

class RecipeProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];

  bool _isLoading = false;
  bool _isGridView = true;
  String _searchQuery = '';
  String? _selectedCategory;

  // Filters
  bool _showMyRecipes =
      false; // Toggle between "All Published" and "My Recipes"

  List<Recipe> get recipes => _filteredRecipes;
  List<Recipe> get allRecipes => _allRecipes; // Expose for Admin

  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;
  String? get selectedCategory => _selectedCategory;
  bool get showMyRecipes => _showMyRecipes;

  RecipeProvider();

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void toggleShowMyRecipes(bool showMine) {
    _showMyRecipes = showMine;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setCategory(String? category) {
    if (category == 'All') category = null;
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    final user = _supabase.auth.currentUser;
    _filteredRecipes = _allRecipes.where((recipe) {
      final matchesQuery = recipe.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || recipe.category == _selectedCategory;

      bool matchesTab = true;
      if (_showMyRecipes && user != null) {
        // "My Recipes" tab: Show ONLY my recipes (any status)
        matchesTab = recipe.userId == user.id;
      } else {
        matchesTab = true; // Show ALL recipes temporarily for debugging
        // matchesTab = recipe.status == 'published';
      }

      return matchesQuery && matchesCategory && matchesTab;
    }).toList();
    notifyListeners();
  }

  Future<void> loadRecipes() async {
    try {
      _isLoading = true;
      notifyListeners();
      // Admins fetch everything via RLS policies (or we rely on RLS)
      // Users fetch published + their own via RLS.
      // So we just fetch everything visible to us.
      final response = await _supabase
          .from(AppConstants.recipesTable)
          .select('*, profiles(email)')
          .order('created_at', ascending: false);
      _allRecipes = (response as List).map((e) => Recipe.fromJson(e)).toList();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading recipes with profiles: $e');
      try {
        // Fallback: Load without profiles (Author name will be null)
        final response = await _supabase
            .from(AppConstants.recipesTable)
            .select()
            .order('created_at', ascending: false);
        _allRecipes = (response as List)
            .map((e) => Recipe.fromJson(e))
            .toList();
        _applyFilters();
      } catch (e2) {
        debugPrint('Critical error loading recipes: $e2');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecipe(
    String title,
    String description,
    List<String> ingredients,
    List<String> steps,
    String category,
    String icon,
    String? authorName, {
    bool isAutoPublish = false,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase.from(AppConstants.recipesTable).insert({
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'icon': icon,
      'user_id': user.id,
      'status': isAutoPublish ? 'published' : 'pending_review',
      'author_name': authorName,
    });
    await loadRecipes();
  }

  Future<void> updateRecipe(
    String id,
    String title,
    String description,
    List<String> ingredients,
    List<String> steps,
    String category,
    String icon,
    String? authorName,
  ) async {
    await _supabase
        .from(AppConstants.recipesTable)
        .update({
          'title': title,
          'description': description,
          'ingredients': ingredients,
          'steps': steps,
          'category': category,
          'icon': icon,
          'author_name': authorName,
        })
        .eq('id', id);
    await loadRecipes();
  }

  Future<void> deleteRecipe(String id) async {
    await _supabase.from(AppConstants.recipesTable).delete().eq('id', id);
    _allRecipes.removeWhere((r) => r.id == id);
    _applyFilters();
  }

  // --- New Actions ---

  Future<void> submitForReview(String id) async {
    await _supabase
        .from(AppConstants.recipesTable)
        .update({'status': 'pending_review'})
        .eq('id', id);
    await loadRecipes();
  }

  Future<void> publishRecipe(String id) async {
    await _supabase
        .from(AppConstants.recipesTable)
        .update({'status': 'published'})
        .eq('id', id);
    await loadRecipes();
  }

  Future<void> rejectRecipe(String id) async {
    await _supabase
        .from(AppConstants.recipesTable)
        .update({'status': 'rejected'})
        .eq('id', id);
    await loadRecipes();
  }
}
