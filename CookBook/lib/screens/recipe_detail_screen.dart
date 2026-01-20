import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import 'add_edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RecipeProvider>(
      builder: (context, auth, recipeProvider, _) {
        final user = auth.user;
        final isAdmin = auth.isAdmin;
        final isOwner = user != null && user.id == recipe.userId;

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.title),
            actions: [
              if (isOwner || isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditRecipeScreen(recipe: recipe),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (recipe.status != 'published')
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        recipe.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(recipe.status)),
                    ),
                    child: Text(
                      'Status: ${recipe.status.toUpperCase().replaceAll('_', ' ')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _getStatusColor(recipe.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                Center(
                  child: Text(
                    recipe.icon,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (recipe.authorName != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'By: ${recipe.authorName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (recipe.category != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Chip(
                        label: Text(recipe.category!),
                        backgroundColor: Colors.orange.shade50,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                if (recipe.description != null) ...[
                  Text(
                    recipe.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Divider(),
                const SizedBox(height: 16),

                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(i, style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...recipe.steps.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color.fromARGB(255, 178, 255, 214),
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 26, 255, 0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                if (isOwner &&
                    (recipe.status == 'draft' || recipe.status == 'rejected'))
                  _DetailButton(
                    text: 'Submit for Review',
                    isLoading: recipeProvider.isLoading,
                    onPressed: () async {
                      await recipeProvider.submitForReview(recipe.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),

                if (isAdmin && recipe.status == 'pending_review') ...[
                  const Divider(),
                  const Text(
                    'Admin Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await recipeProvider.publishRecipe(recipe.id);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Approve & Publish'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await recipeProvider.rejectRecipe(recipe.id);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'pending_review':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _DetailButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _DetailButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
