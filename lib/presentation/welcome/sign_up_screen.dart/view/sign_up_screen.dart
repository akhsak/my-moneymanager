import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/welcome/login_screen/view/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/welcome/sign_up_screen.dart/controller/sign_up_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    final controller = Provider.of<SignUpController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.secondaryColor,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios, color: ColorTheme.mainColor2, size: SizeConstants.width(3.5))),
      ),
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
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor2,
                  size: SizeConstants.font(5.5),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConstants.width(6),
                        vertical: SizeConstants.height(4),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      // Full Name Field
                      _buildInputField(
                        label: 'Full Name',
                        controller: controller.fullNameController,
                        hintText: 'Enter Name',
                      ),
                      
                      SizedBox(height: SizeConstants.height(3)),
                      
                      // Email Field
                      _buildInputField(
                        label: 'Email',
                        controller: controller.emailController,
                        hintText: 'example@example.com',
                      ),
                      
                      SizedBox(height: SizeConstants.height(3)),
                      
                      // Password Field
                      _buildPasswordField(
                        label: 'Password',
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword,
                        onToggleVisibility: controller.togglePasswordVisibility,
                      ),
                      
                      SizedBox(height: SizeConstants.height(3)),
                      
                      // Confirm Password Field
                      _buildPasswordField(
                        label: 'Confirm Password',
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmPassword,
                        onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                      ),
                      
                      SizedBox(height: SizeConstants.height(3)),
                      
                      // Terms and Privacy Policy
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyles.smallText(
                              color: ColorTheme.mainColor,
                              size: SizeConstants.font(3),
                            ),
                            children: [
                              const TextSpan(text: 'By continuing, you agree to '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: controller.openTermsOfUse,
                                  child: Text(
                                    'Terms of Use',
                                    style: TextStyles.smallText(
                                      color: const Color(0xFF0D3B36),
                                      size: SizeConstants.font(3),
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: controller.openPrivacyPolicy,
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyles.smallText(
                                      color: const Color(0xFF0D3B36),
                                      size: SizeConstants.font(3),
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: SizeConstants.height(4)),
                      
                      // Error Message
                      if (controller.errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(SizeConstants.width(3)),
                          margin: EdgeInsets.only(bottom: SizeConstants.height(2)),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                      
                      // Sign Up Button
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
                          onPressed: () async {
                            final response = await controller.signUp();
                            if (response != null) {
                              // Registration successful, navigate to login
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Registration successful! Please log in.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
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
                                  'Sign Up',
                                  style: TextStyles.buttonText(
                                    color: ColorTheme.mainColor2,
                                    size: SizeConstants.font(4.5),
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: SizeConstants.height(4)),
                      
                      // Login Link
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyles.smallText(
                              color: ColorTheme.mainColor,
                              size: SizeConstants.font(3.2),
                            ),
                            children: [
                              const TextSpan(text: "Already have an account? "),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                  },
                                  child: Text(
                                    'Log In',
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
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
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            obscureText: obscureText,
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
                onTap: onToggleVisibility,
                child: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
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
      ],
    );
  }
}
