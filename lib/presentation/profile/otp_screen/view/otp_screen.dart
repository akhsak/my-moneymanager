import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/welcome/change_password_screen/view/chanage_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/otp_screen/controller/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    final controller = Provider.of<OtpController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.secondaryColor,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConstants.width(3.5))),
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
                'Security Pin',
                textAlign: TextAlign.center,
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor2,
                  size: SizeConstants.font(6),
                  weight: FontWeight.normal,
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
                    children: [
                      SizedBox(height: SizeConstants.height(4)),
                      
                      // Enter Security Pin Text
                      Text(
                        'Enter Security Pin',
                        style: TextStyles.bodyText(
                          color: ColorTheme.mainColor,
                          size: SizeConstants.font(5),
                          weight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: SizeConstants.height(4)),
                      
                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return _OtpInputField(
                            controller: controller.otpControllers[index],
                            focusNode: controller.focusNodes[index],
                            onChanged: (value) => controller.onOtpChanged(value, index),
                          );
                        }),
                      ),
                      
                      SizedBox(height: SizeConstants.height(6)),
                      
                      // Accept Button
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
                              borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                            ),
                          ),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
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
                                  'Accept',
                                  style: TextStyles.buttonText(
                                    color: ColorTheme.mainColor2,
                                    size: SizeConstants.font(4.5),
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: SizeConstants.height(2)),
                      
                      // Send Again Button
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
                              borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                            ),
                          ),
                          onPressed: controller.isLoading ? null : controller.sendAgain,
                          child: Text(
                            'Send Again',
                            style: TextStyles.buttonText(
                              color: ColorTheme.mainColor2,
                              size: SizeConstants.font(4.5),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: SizeConstants.height(4)),
                      
                      // Or sign up with text
                      Center(
                        child: Text(
                          'or sign up with',
                          style: TextStyles.smallText(
                            color: ColorTheme.mainColor,
                            size: SizeConstants.font(3),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: SizeConstants.height(2)),
                      
                      // Social Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIcon(
                            icon: 'f',
                            onTap: controller.loginWithFacebook,
                          ),
                          SizedBox(width: SizeConstants.width(4)),
                          _SocialIcon(
                            icon: 'G',
                            onTap: controller.loginWithGoogle,
                          ),
                        ],
                      ),
                      
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
                                  onTap: controller.navigateToSignUp,
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

class _OtpInputField extends StatelessWidget {
  const _OtpInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConstants.width(12),
      height: SizeConstants.width(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorTheme.secondaryColor,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        style: TextStyles.bodyText(
          color: ColorTheme.secondaryColor,
          size: SizeConstants.font(5),
          weight: FontWeight.w700,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}

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
            color: ColorTheme.secondaryColor,
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
