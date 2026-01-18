import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({required this.page, this.direction = AxisDirection.left})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide animation
          Offset begin;
          switch (direction) {
            case AxisDirection.up:
              begin = const Offset(0.0, 1.0);
              break;
            case AxisDirection.down:
              begin = const Offset(0.0, -1.0);
              break;
            case AxisDirection.left:
              begin = const Offset(1.0, 0.0);
              break;
            case AxisDirection.right:
              begin = const Offset(-1.0, 0.0);
              break;
          }
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);

          // Fade animation
          var fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeIn));
          var fadeAnimation = animation.drive(fadeTween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
      );
}
