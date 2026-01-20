class Recipe {
  final String id;
  final String title;
  final String? description;
  final List<String> ingredients;
  final List<String> steps;
  final String? category;
  final String icon;
  final String userId;
  final DateTime createdAt;
  final String status; // 'draft', 'pending_review', 'published', 'rejected'
  final String? authorName;

  Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.ingredients,
    required this.steps,
    this.category,
    required this.icon,
    required this.userId,
    required this.createdAt,
    this.status = 'draft',
    this.authorName,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Priority: 1. Manual `author_name` column, 2. Joined profile email
    String? author = json['author_name'] as String?;
    if (author == null && json['profiles'] != null) {
      author = json['profiles']['email'] as String?;
    }

    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      category: json['category'] as String?,
      icon: json['icon'] as String? ?? '🍳',
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'draft',
      authorName: author,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'icon': icon,
      'user_id': userId,
      'status': status,
      'author_name': authorName,
    };
  }
}
