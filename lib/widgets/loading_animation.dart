import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoadingAnimation extends StatelessWidget {
  final String? message;
  
  const LoadingAnimation({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Loading...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}