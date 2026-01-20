import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../constants.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  const AddEditRecipeScreen({super.key, this.recipe});
  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController(text: '🍳');
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _authorController.text = widget.recipe!.authorName ?? '';
      _descriptionController.text = widget.recipe!.description ?? '';
      _iconController.text = widget.recipe!.icon;
      _selectedCategory = widget.recipe!.category;
      _ingredientsController.text = widget.recipe!.ingredients.join('\n');
      _stepsController.text = widget.recipe!.steps.join('\n');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final ingredients = _ingredientsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final steps = _stepsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAdmin = authProvider.isAdmin;
      final category = _selectedCategory ?? 'Other';
      final icon = _iconController.text.isEmpty ? '🍳' : _iconController.text;
      final authorName = _authorController.text.trim().isEmpty
          ? null
          : _authorController.text.trim();

      if (widget.recipe == null) {
        await provider.addRecipe(
          _titleController.text,
          _descriptionController.text,
          ingredients,
          steps,
          category,
          icon,
          authorName,
          isAutoPublish: isAdmin,
        );
      } else {
        await provider.updateRecipe(
          widget.recipe!.id,
          _titleController.text,
          _descriptionController.text,
          ingredients,
          steps,
          category,
          icon,
          authorName,
        );
      }
      if (mounted) {
        String message;
        if (isAdmin) {
          message = widget.recipe == null
              ? 'Recipe published successfully!'
              : 'Updated successfully!';
        } else {
          message = 'Recipe submitted for review! An admin will check it soon.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Recipe' : 'New Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Icon and Title Section ---
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: _RecipeInput(
                      controller: _iconController,
                      label: 'Icon',
                      validator: (v) => v!.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RecipeInput(
                      controller: _titleController,
                      label: 'Recipe Title',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              // --- Author & Category Section ---
              const SizedBox(height: 16),
              _RecipeInput(
                controller: _authorController,
                label: 'Author Name',
                validator: null,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Select Category'),
                    isExpanded: true,
                    items: AppConstants.categories
                        .where((c) => c != 'All')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- Description & Ingredients Section ---
              _RecipeInput(
                controller: _descriptionController,
                label: 'Short Description',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _RecipeInput(
                controller: _ingredientsController,
                label: 'Ingredients (One per line)',
                maxLines: 6,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              _RecipeInput(
                controller: _stepsController,
                label: 'Cooking Steps (One per line)',
                maxLines: 8,
                keyboardType: TextInputType.multiline,
              ),
              // --- Action Button Section ---
              const SizedBox(height: 32),
              _RecipeButton(
                onPressed: _save,
                text: isEditing ? 'Update Recipe' : 'Save Recipe',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _RecipeInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _RecipeInput({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<_RecipeInput> createState() => _RecipeInputState();
}

class _RecipeInputState extends State<_RecipeInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: null,
      ),
    );
  }
}

class _RecipeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _RecipeButton({
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
