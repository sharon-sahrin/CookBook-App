import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Reviews'),
              Tab(text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [const PendingReviewsTab(), const UserManagementTab()],
        ),
      ),
    );
  }
}

class PendingReviewsTab extends StatefulWidget {
  const PendingReviewsTab({super.key});

  @override
  State<PendingReviewsTab> createState() => _PendingReviewsTabState();
}

class _PendingReviewsTabState extends State<PendingReviewsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        // Use allRecipes exposed for Admin
        final pendingRecipes = provider.allRecipes
            .where((r) => r.status == 'pending_review')
            .toList();

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pendingRecipes.isEmpty) {
          return const Center(child: Text('No pending reviews'));
        }

        return ListView.builder(
          itemCount: pendingRecipes.length,
          itemBuilder: (context, index) {
            final recipe = pendingRecipes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Text(
                  recipe.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(recipe.title),
                subtitle: Text(
                  'By: ${recipe.userId}',
                ), // Ideally show username but we only have ID
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      // NOTE: This usually requires specific policies for Admin to read all profiles.
      // We assume policies allow it or we fail gracefully.
      // We fetch id, role, email (if stored in profiles, schema had email)
      final response = await _supabase.from('profiles').select();
      _profiles = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_profiles.isEmpty) {
      return const Center(child: Text('No users found (or permission denied)'));
    }

    return ListView.builder(
      itemCount: _profiles.length,
      itemBuilder: (context, index) {
        final profile = _profiles[index];
        final isMe = _supabase.auth.currentUser?.id == profile['id'];
        return ListTile(
          title: Text(profile['email'] ?? 'Unknown Email'),
          subtitle: Text('Role: ${profile['role']}'),
          trailing: isMe ? const Chip(label: Text('You')) : null,
        );
      },
    );
  }
}
