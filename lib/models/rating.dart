class Rating {
  final String id;
  final String agentId;
  final String customerId;
  final String customerName;
  final String? propertyId;
  final String? propertyTitle;
  final double rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;
  final bool isApproved;

  Rating({
    required this.id,
    required this.agentId,
    required this.customerId,
    required this.customerName,
    this.propertyId,
    this.propertyTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isApproved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agentId': agentId,
      'customerId': customerId,
      'customerName': customerName,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isApproved': isApproved,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      agentId: map['agentId'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      propertyId: map['propertyId'],
      propertyTitle: map['propertyTitle'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
      isApproved: map['isApproved'] ?? false,
    );
  }
}

class AgentPoints {
  final String agentId;
  final int totalPoints;
  final int totalRatings;
  final double averageRating;
  final int completedDeals;
  final int responseRate;
  final int rank;

  AgentPoints({
    required this.agentId,
    this.totalPoints = 0,
    this.totalRatings = 0,
    this.averageRating = 0,
    this.completedDeals = 0,
    this.responseRate = 0,
    this.rank = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'agentId': agentId,
      'totalPoints': totalPoints,
      'totalRatings': totalRatings,
      'averageRating': averageRating,
      'completedDeals': completedDeals,
      'responseRate': responseRate,
      'rank': rank,
    };
  }

  factory AgentPoints.fromMap(Map<String, dynamic> map) {
    return AgentPoints(
      agentId: map['agentId'],
      totalPoints: map['totalPoints'] ?? 0,
      totalRatings: map['totalRatings'] ?? 0,
      averageRating: map['averageRating'] ?? 0.0,
      completedDeals: map['completedDeals'] ?? 0,
      responseRate: map['responseRate'] ?? 0,
      rank: map['rank'] ?? 0,
    );
  }
}