import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialLoginButton({
    Key? key,
    required this.iconPath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              // Fallback icon if image asset is not found
              return Icon(
                Icons.account_circle,
                size: 30,
                color: Colors.grey[700],
              );
            },
          ),
        ),
      ),
    );
  }
} 