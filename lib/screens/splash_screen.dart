import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/animations.dart';
import '../utils/app_localizations.dart';
import 'test_case_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
    
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteTransitions.fadeTransition(
            page: const TestCaseListScreen(),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
              ? [const Color(0xFF1A237E), const Color(0xFF006064)]
              : [const Color(0xFF42A5F5), const Color(0xFF26C6DA)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SvgPicture.asset(
                        'assets/svg/qa_logo.svg',
                        height: screenHeight * 0.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  AnimatedOpacity(
                    opacity: _controller.value > 0.7 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context).appTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const LoadingDots(
                          color: Colors.white,
                          size: 12,
                          spacing: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}