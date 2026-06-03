import 'package:hive/hive.dart';
import '../models/rating.dart';

class RatingService {
  static late Box _ratingsBox;
  static late Box _pointsBox;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    _ratingsBox = await Hive.openBox('ratings');
    _pointsBox = await Hive.openBox('agent_points');
    
    _isInitialized = true;
    print('✅ RatingService initialized');
  }

  // Submit a rating for an agent
  static Future<void> submitRating({
    required String agentId,
    required String customerId,
    required String customerName,
    required double rating,
    required String comment,
    String? propertyId,
    String? propertyTitle,
  }) async {
    final ratingId = '${DateTime.now().millisecondsSinceEpoch}_$customerId';
    
    final newRating = Rating(
      id: ratingId,
      agentId: agentId,
      customerId: customerId,
      customerName: customerName,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      isApproved: false, // Needs admin approval
    );
    
    await _ratingsBox.put(ratingId, newRating.toMap());
    print('✅ Rating submitted for agent $agentId');
  }

  // Approve rating (admin only)
  static Future<void> approveRating(String ratingId) async {
    final map = _ratingsBox.get(ratingId);
    if (map != null) {
      final rating = Rating.fromMap(map as Map<String, dynamic>);
      final approvedRating = Rating(
        id: rating.id,
        agentId: rating.agentId,
        customerId: rating.customerId,
        customerName: rating.customerName,
        propertyId: rating.propertyId,
        propertyTitle: rating.propertyTitle,
        rating: rating.rating,
        comment: rating.comment,
        createdAt: rating.createdAt,
        isApproved: true,
      );
      await _ratingsBox.put(ratingId, approvedRating.toMap());
      
      // Update agent points
      await _updateAgentPoints(rating.agentId);
    }
  }

  // Reject rating (admin only)
  static Future<void> rejectRating(String ratingId) async {
    await _ratingsBox.delete(ratingId);
  }

  // Get pending ratings for admin
  static List<Rating> getPendingRatings() {
    return _ratingsBox.values
        .map((map) => Rating.fromMap(map as Map<String, dynamic>))
        .where((rating) => !rating.isApproved)
        .toList();
  }

  // Get approved ratings for an agent
  static List<Rating> getAgentRatings(String agentId) {
    return _ratingsBox.values
        .map((map) => Rating.fromMap(map as Map<String, dynamic>))
        .where((rating) => rating.agentId == agentId && rating.isApproved)
        .toList();
  }

  // Update agent points based on ratings
  static Future<void> _updateAgentPoints(String agentId) async {
    final ratings = getAgentRatings(agentId);
    final totalRatings = ratings.length;
    
    if (totalRatings == 0) return;
    
    final sumRatings = ratings.fold(0.0, (sum, r) => sum + r.rating);
    final averageRating = sumRatings / totalRatings;
    
    // Calculate points: each 5-star = 10 points, 4-star = 5 points, etc.
    int totalPoints = 0;
    for (var rating in ratings) {
      if (rating.rating >= 4.5) {
        totalPoints += 10;
      } else if (rating.rating >= 4.0) totalPoints += 7;
      else if (rating.rating >= 3.0) totalPoints += 5;
      else if (rating.rating >= 2.0) totalPoints += 2;
      else totalPoints += 1;
    }
    
    final agentPoints = AgentPoints(
      agentId: agentId,
      totalPoints: totalPoints,
      totalRatings: totalRatings,
      averageRating: averageRating,
    );
    
    await _pointsBox.put(agentId, agentPoints.toMap());
  }

  // Get agent points
  static AgentPoints? getAgentPoints(String agentId) {
    final map = _pointsBox.get(agentId);
    if (map == null) return null;
    return AgentPoints.fromMap(map as Map<String, dynamic>);
  }

  // Get top agents by points
  static List<AgentPoints> getTopAgents({int limit = 10}) {
    final allPoints = _pointsBox.values
        .map((map) => AgentPoints.fromMap(map as Map<String, dynamic>))
        .toList();
    
    allPoints.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return allPoints.take(limit).toList();
  }
}