import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_config.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? imagePath;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.imagePath,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.rw),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.rw),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath ?? 'assets/icons/empty-doctor.jpg',
                height: 150.rh,
                width: 150.rw,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  icon,
                  size: 64.rt,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.rh),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.rt,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.rh),
          Text(
            message,
            style: TextStyle(fontSize: 14.rt, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (onActionPressed != null && actionLabel != null) ...[
            SizedBox(height: 32.rh),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.rw,
                  vertical: 12.rh,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
