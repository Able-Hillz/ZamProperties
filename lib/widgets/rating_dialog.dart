import 'package:flutter/material.dart';
import '../services/rating_service.dart';
import '../utils/constants.dart';

class RatingDialog extends StatefulWidget {
  final String agentId;
  final String agentName;
  final String customerId;
  final String customerName;
  final String? propertyId;
  final String? propertyTitle;

  const RatingDialog({
    super.key,
    required this.agentId,
    required this.agentName,
    required this.customerId,
    required this.customerName,
    this.propertyId,
    this.propertyTitle,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please leave a comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await RatingService.submitRating(
      agentId: widget.agentId,
      customerId: widget.customerId,
      customerName: widget.customerName,
      rating: _rating,
      comment: _commentController.text.trim(),
      propertyId: widget.propertyId,
      propertyTitle: widget.propertyTitle,
    );

    setState(() => _isSubmitting = false);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your rating! It will be reviewed shortly.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Rate ${widget.agentName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.propertyTitle != null)
              Text(
                'Property: ${widget.propertyTitle}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience with this agent...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Rating'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}