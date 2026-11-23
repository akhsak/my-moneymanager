import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/bottom_navigation_screen/view/bottom_navigation_screen.dart';
import 'package:monaymanagment/presentation/guest_db/guest_mode_controller.dart';
import 'package:monaymanagment/presentation/welcome/forgot_password/view/forgot_password.dart';
import 'package:monaymanagment/presentation/welcome/sign_up_screen.dart/view/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/welcome/login_screen/controller/login_screen_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    final controller = Provider.of<LoginScreenController>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,

      backgroundColor: ColorTheme.secondaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: SizeConstants.height(8),
                horizontal: SizeConstants.width(6),
              ),
              child: Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor2,
                  size: SizeConstants.font(6),
                  weight: FontWeight.w700,
                ),
              ),
            ),

            // Main Content Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8F7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(SizeConstants.width(8)),
                    topRight: Radius.circular(SizeConstants.width(8)),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConstants.width(6),
                    vertical: SizeConstants.height(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username/Email Field
                      Text(
                        'Username Or Email',
                        style: TextStyles.smallText(
                          color: ColorTheme.mainColor,
                          size: SizeConstants.font(3.5),
                          weight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(1)),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8F7),
                          borderRadius: BorderRadius.circular(
                            SizeConstants.width(4),
                          ),
                          border: Border.all(
                            color: ColorTheme.mainColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: controller.emailController,
                          decoration: InputDecoration(
                            hintText: 'example@example.com',
                            hintStyle: TextStyles.smallText(
                              color: ColorTheme.mainColor.withOpacity(0.5),
                              size: SizeConstants.font(3.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: SizeConstants.width(4),
                              vertical: SizeConstants.height(2),
                            ),
                          ),
                          style: TextStyles.smallText(
                            color: ColorTheme.mainColor,
                            size: SizeConstants.font(3.5),
                          ),
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(3)),

                      // Password Field
                      Text(
                        'Password',
                        style: TextStyles.smallText(
                          color: ColorTheme.mainColor,
                          size: SizeConstants.font(3.5),
                          weight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(1)),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8F7),
                          borderRadius: BorderRadius.circular(
                            SizeConstants.width(4),
                          ),
                          border: Border.all(
                            color: ColorTheme.mainColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyles.smallText(
                              color: ColorTheme.mainColor.withOpacity(0.5),
                              size: SizeConstants.font(3.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: SizeConstants.width(4),
                              vertical: SizeConstants.height(2),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: controller.togglePasswordVisibility,
                              child: Icon(
                                controller.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF0D3B36),
                                size: SizeConstants.width(5),
                              ),
                            ),
                          ),
                          style: TextStyles.smallText(
                            color: ColorTheme.mainColor,
                            size: SizeConstants.font(3.5),
                          ),
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(1)),

                      // Replace the InkWell + inner GestureDetector with just this:
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(),
                              ),
                            );
                            // OR: controller.forgotPassword();
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyles.smallText(
                              color: ColorTheme.mainColor,
                              size: SizeConstants.font(3),
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(4)),

                      // Error Message
                      if (controller.errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(SizeConstants.width(3)),
                          margin: EdgeInsets.only(
                            bottom: SizeConstants.height(2),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              SizeConstants.width(2),
                            ),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            controller.errorMessage!,
                            style: TextStyles.smallText(
                              color: Colors.red,
                              size: SizeConstants.font(3.2),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.secondaryColor,
                            foregroundColor: ColorTheme.mainColor2,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConstants.height(2.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SizeConstants.width(4),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            final response = await controller.login();
                            if (response != null) {
                              // Login successful, navigate to dashboard
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavigationScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          child: controller.isLoading
                              ? SizedBox(
                                  width: SizeConstants.width(5),
                                  height: SizeConstants.width(5),
                                  child: CircularProgressIndicator(
                                    color: ColorTheme.mainColor2,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Log In',
                                  style: TextStyles.buttonText(
                                    color: ColorTheme.mainColor2,
                                    size: SizeConstants.font(4.5),
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(3)),

                      // // Social Login Section
                      // Center(
                      //   child: Text(
                      //     'or sign up with',
                      //     style: TextStyles.smallText(
                      //       color: ColorTheme.mainColor,
                      //       size: SizeConstants.font(3),
                      //     ),
                      //   ),
                      // ),

                      // SizedBox(height: SizeConstants.height(2)),

                      // // Social Icons
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     // _SocialIcon(
                      //     //   icon: 'f',
                      //     //   onTap: controller.loginWithFacebook,
                      //     // ),
                      //     // SizedBox(width: SizeConstants.width(4)),
                      //     _SocialIcon(
                      //       icon: 'G',
                      //       onTap: controller.loginWithGoogle,
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: SizeConstants.height(4)),

                      // Sign Up Link
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyles.smallText(
                              color: ColorTheme.mainColor,
                              size: SizeConstants.font(3.2),
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyles.smallText(
                                      color: const Color(0xFF0D3B36),
                                      size: SizeConstants.font(3.2),
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(3)),

                      Center(
                        child: TextButton(
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
                            'Skip for now (Guest mode)',
                            style: TextStyles.smallText(
                              color: ColorTheme.secondaryColor,
                              size: SizeConstants.font(3.2),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(2)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
