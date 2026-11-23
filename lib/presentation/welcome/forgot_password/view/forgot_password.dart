import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/profile/otp_screen/view/otp_screen.dart';
import 'package:monaymanagment/presentation/welcome/sign_up_screen.dart/view/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/welcome/forgot_password/controller/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    final controller = Provider.of<ForgotPasswordController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.secondaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConstants.width(3.5)),
        ),
        
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorTheme.secondaryColor,
      body: SafeArea(
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
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor2,
                  size: SizeConstants.font(6),
                  weight: FontWeight.normal
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
                            // Reset Password Title
                            Text(
                              'Reset Password?',
                              style: TextStyles.bodyText(
                                color: ColorTheme.mainColor,
                                
                                weight: FontWeight.bold,
                              ),
                            ),
                            
                            SizedBox(height: SizeConstants.height(2)),
                            
                            // Description Text
                            Text(
                              'Don\'t worry! Enter your email address and we\'ll send you a otp to reset your password.',
                              style: TextStyles.smallText(
                                color: ColorTheme.mainColor,
                                size: SizeConstants.font(3.5),
                                weight: FontWeight.w400,
                              ),
                            ),
                            
                            SizedBox(height: SizeConstants.height(4)),
                            
                            // Email Input Field
                            Text(
                              'Enter Email Address',
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
                                borderRadius: BorderRadius.circular(SizeConstants.width(4)),
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
                            
                            SizedBox(height: SizeConstants.height(4)),
                            
                            // Next Step Button
                            Center(
                              child: SizedBox(
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
                                      borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                                    ),
                                  ),
                                  onPressed: (){
                                    controller.nextStep().then((success) {
                                      if (success && context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OtpScreen(),
                                          ),
                                        );
                                      }
                                    });
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
                                          'Next Step',
                                          style: TextStyles.buttonText(
                                            color: ColorTheme.mainColor2,
                                            size: SizeConstants.font(4.5),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            
                            //SizedBox(height: SizeConstants.height(3)),
                            
                            // Or sign up with text
                            // Center(
                            //   child: Text(
                            //     'or sign up with',
                            //     style: TextStyles.smallText(
                            //       color: ColorTheme.mainColor,
                            //       size: SizeConstants.font(3),
                            //     ),
                            //   ),
                            // ),
                            
                            //SizedBox(height: SizeConstants.height(2)),
                            
                            // Social Icons
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     _SocialIcon(
                            //       icon: 'f',
                            //       onTap: controller.loginWithFacebook,
                            //     ),
                            //     SizedBox(width: SizeConstants.width(4)),
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
                                        onTap: (){
                                          Navigator.push(context,   MaterialPageRoute(builder:(Context)=>SignUpScreen()));
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

// ignore: unused_element
class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.icon,
    required this.onTap,
  });

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: SizeConstants.width(12),
        height: SizeConstants.width(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: ColorTheme.mainColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            icon,
            style: TextStyles.bodyText(
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(5),
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
