import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/welcome/change_password_done_screen/controller/change_password_done_controller.dart';
import 'package:monaymanagment/presentation/welcome/login_screen/view/login_screen.dart';

class ChangePasswordDoneScreen extends StatefulWidget {
  const ChangePasswordDoneScreen({super.key});

  @override
  State<ChangePasswordDoneScreen> createState() => _ChangePasswordDoneScreenState();
}

class _ChangePasswordDoneScreenState extends State<ChangePasswordDoneScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _pulseAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    _iconOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start icon animation
    _iconController.forward();
    
    // Start text animation after icon animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Start pulse animation after text animation
    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);

    // Navigate to login after a brief delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && !_navigated) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
    return ChangeNotifierProvider(
      create: (context) => ChangePasswordDoneController(),
      child: Consumer<ChangePasswordDoneController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF2F366F), // Dark blue background
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Success Icon
                    AnimatedBuilder(
                      animation: _iconController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _iconScaleAnimation.value,
                          child: Opacity(
                            opacity: _iconOpacityAnimation.value,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: SizeConstants.width(25),
                                    height: SizeConstants.width(25),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: SizeConstants.width(8),
                                        height: SizeConstants.width(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: SizeConstants.height(6)),
                    
                    // Animated Success Text
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Opacity(
                            opacity: _textOpacityAnimation.value,
                            child: Text(
                              'Password Has Been\nChanged Successfully',
                              textAlign: TextAlign.center,
                              style: TextStyles.bodyText(
                                color: Colors.white,
                                size: SizeConstants.font(5.5),
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: SizeConstants.height(8)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}