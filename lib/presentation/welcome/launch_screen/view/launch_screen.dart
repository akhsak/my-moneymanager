import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/bottom_navigation_screen/view/bottom_navigation_screen.dart';
import 'package:monaymanagment/presentation/guest_db/guest_mode_controller.dart';
import 'package:monaymanagment/presentation/welcome/forgot_password/view/forgot_password.dart';
import 'package:monaymanagment/presentation/welcome/login_screen/view/login_screen.dart';
import 'package:monaymanagment/presentation/welcome/sign_up_screen.dart/view/sign_up_screen.dart';
import 'package:provider/provider.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return Scaffold(
      backgroundColor: ColorTheme.mainColor2, // light background (white)
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(6)),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        child: Image.asset(
                          'assets/on_boarding/finura.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(1.5)),
                      Text(
                        'Welcome to FINURA - Your personal finance\nmanagement companion for a better future.',
                        textAlign: TextAlign.center,
                        style: TextStyles.smallText(
                          size: SizeConstants.font(3.5),
                          weight: FontWeight.w400,
                          color: ColorTheme.mainColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(4)),
                      _PrimaryButton(
                        label: 'Log In',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: SizeConstants.height(2)),
                      _PrimaryButton(
                        label: 'Create An Account',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: SizeConstants.height(2.5)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyles.smallText(
                            size: SizeConstants.font(3),
                            weight: FontWeight.w600,
                            color: ColorTheme.mainColor,
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(1.5)),
                      TextButton(
                        onPressed: () async {
                          final guestController = context
                              .read<GuestModeController>();
                          await guestController.enterGuestMode();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BottomNavigationScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: Text(
                          'Continue as Guest',
                          style: TextStyles.smallText(
                            size: SizeConstants.font(3),
                            weight: FontWeight.w600,
                            color: ColorTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.secondaryColor,
          foregroundColor: ColorTheme.mainColor2,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConstants.width(6)),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyles.buttonText(
            size: SizeConstants.font(4),
            color: ColorTheme.mainColor2,
          ),
        ),
      ),
    );
  }
}
