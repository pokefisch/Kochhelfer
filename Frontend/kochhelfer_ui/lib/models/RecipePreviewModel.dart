class RecipePreviewModel {
  final int id;
  final String title;
  final int duration;
  final int portions;
  final String imageUrl;

  RecipePreviewModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.portions,
    required this.imageUrl,
  });

  factory RecipePreviewModel.fromJson(Map<String, dynamic> json) {
    return RecipePreviewModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Kein Titel',
      duration: json['duration'] ?? 0,
      portions: json['portions'] ?? 0,
      imageUrl: json['image'] ?? '',
    );
  }
}
