import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const AnimatedButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final elevatedButtonTheme = ElevatedButtonTheme.of(context).style;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16), //클릭 효과
      child: AnimatedContainer(
        width: double.infinity,
        duration: Duration(microseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: elevatedButtonTheme?.backgroundColor?.resolve({}) ??
          Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12,),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: elevatedButtonTheme?.foregroundColor?.resolve({}) ??
                  Colors.white, fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}