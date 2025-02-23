class DrinkLikes {
  final String drinkId;
  final int totalLikes;
  final List<String> usersLiked;
  double likePercentage;

  DrinkLikes({
    required this.drinkId,
    required this.totalLikes,
    required this.usersLiked,
    this.likePercentage = 0,
  });

  factory DrinkLikes.fromJson(Map<String, dynamic> json) {
    return DrinkLikes(
      drinkId: json['drinkId'] ?? '',
      totalLikes: json['total_likes'] ?? 0,
      usersLiked: List<String>.from(json['users_liked'] ?? []),
      likePercentage: json['like_percentage']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'drinkId': drinkId,
        'total_likes': totalLikes,
        'users_liked': usersLiked,
        'like_percentage': likePercentage,
      };
}
