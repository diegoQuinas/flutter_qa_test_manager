import 'package:flutter/material.dart';

class PageRouteTransitions {
  // Transición de desvanecimiento
  static PageRouteBuilder fadeTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Transición de deslizamiento
  static PageRouteBuilder slideTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    Offset begin;
    
    switch (direction) {
      case SlideDirection.fromRight:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.fromLeft:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.fromBottom:
        begin = const Offset(0.0, 1.0);
        break;
      case SlideDirection.fromTop:
        begin = const Offset(0.0, -1.0);
        break;
    }
    
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOut;
        var curveTween = CurveTween(curve: curve);
        var tween = Tween(begin: begin, end: const Offset(0.0, 0.0))
            .chain(curveTween);
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Transición de escalado
  static PageRouteBuilder scaleTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOut;
        var curveTween = CurveTween(curve: curve);
        var tween = Tween(begin: 0.0, end: 1.0).chain(curveTween);
        
        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Transición combinada (fade + slide)
  static PageRouteBuilder fadeSlideTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    Offset begin;
    
    switch (direction) {
      case SlideDirection.fromRight:
        begin = const Offset(0.2, 0.0);
        break;
      case SlideDirection.fromLeft:
        begin = const Offset(-0.2, 0.0);
        break;
      case SlideDirection.fromBottom:
        begin = const Offset(0.0, 0.2);
        break;
      case SlideDirection.fromTop:
        begin = const Offset(0.0, -0.2);
        break;
    }
    
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOut;
        var curveTween = CurveTween(curve: curve);
        
        var slideTween = Tween(begin: begin, end: const Offset(0.0, 0.0))
            .chain(curveTween);
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(curveTween);
        
        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
    );
  }

  // Transición heroica
  static PageRouteBuilder heroTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // La animación Hero se maneja automáticamente
      },
    );
  }
}

// Direcciones para las transiciones de deslizamiento
enum SlideDirection {
  fromRight,
  fromLeft,
  fromBottom,
  fromTop,
}

// Widget para animar la entrada de elementos en una lista
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final bool animate;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Animación para botones
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.repeat = true,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

// Widget para animar cambios de contenido
class AnimatedContent extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedContent({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Animación de carga personalizada
class LoadingDots extends StatefulWidget {
  final Color color;
  final double size;
  final double spacing;

  const LoadingDots({
    Key? key, 
    this.color = Colors.white,
    this.size = 10.0,
    this.spacing = 4.0,
  }) : super(key: key);

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600),
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
    
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_controllers.length, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Opacity(
                  opacity: 0.3 + (_animations[index].value * 0.7),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}