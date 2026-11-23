import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';
import 'package:monaymanagment/presentation/profile/password_settings_screen/controller/password_settings_controller.dart';
import 'package:provider/provider.dart';

class PasswordSettingsScreen extends StatelessWidget {
  const PasswordSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
    return ChangeNotifierProvider(
      create: (_) => PasswordSettingsController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: CustomAppBar(
          title: 'Password Settings',
          showProfileAvatar: false,
          showBackButton: true,
          showNotification: true,
        ),
        body: Consumer<PasswordSettingsController>(
          builder: (context, controller, _) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F8F0), // Light green background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConstants.width(5)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: SizeConstants.height(2)),
                      
                      // Current Password Section
                      _buildSectionTitle('Current Password'),
                      SizedBox(height: SizeConstants.height(1)),
                      _buildPasswordField(
                        controller: controller.currentPasswordController,
                        showPassword: controller.showCurrentPassword,
                        onToggle: controller.toggleCurrentPassword,
                        hintText: 'Enter current password',
                        passwordController: controller,
                      ),
                      
                      SizedBox(height: SizeConstants.height(3)),
                      
                      // New Password Section
                      _buildSectionTitle('New Password'),
                      SizedBox(height: SizeConstants.height(1)),
                      _buildPasswordField(
                        controller: controller.newPasswordController,
                        showPassword: controller.showNewPassword,
                        onToggle: controller.toggleNewPassword,
                        hintText: 'Enter new password',
                        passwordController: controller,
                      ),
                      
                      SizedBox(height: SizeConstants.height(3)),
                      
                      // Confirm Password Section
                      _buildSectionTitle('Confirm New Password'),
                      SizedBox(height: SizeConstants.height(1)),
                      _buildPasswordField(
                        controller: controller.confirmPasswordController,
                        showPassword: controller.showConfirmPassword,
                        onToggle: controller.toggleConfirmPassword,
                        hintText: 'Confirm new password',
                        passwordController: controller,
                      ),
                      
                      SizedBox(height: SizeConstants.height(3)),
                      
                      // Error Message
                      if (controller.errorMessage != null)
                        _buildErrorMessage(controller.errorMessage!),
                      
                      // Success Message
                      if (controller.successMessage != null)
                        _buildSuccessMessage(controller.successMessage!),
                      
                      SizedBox(height: SizeConstants.height(2)),
                      
                      // Update Button
                      _buildUpdateButton(controller),
                      
                      SizedBox(height: SizeConstants.height(40)),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyles.bodyText(
        color: ColorTheme.mainColor,
        size: SizeConstants.font(3.8),
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggle,
    required String hintText,
    required PasswordSettingsController passwordController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        onChanged: (value) => passwordController.onTextChanged(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyles.smallText(
            color: Colors.grey[600],
            size: SizeConstants.font(3.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConstants.width(4),
            vertical: SizeConstants.height(2.5),
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: ColorTheme.mainColor,
              size: SizeConstants.font(4),
            ),
          ),
        ),
        style: TextStyles.bodyText(
          color: ColorTheme.mainColor,
          size: SizeConstants.font(3.5),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConstants.width(3)),
      margin: EdgeInsets.only(bottom: SizeConstants.height(1)),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeConstants.width(2)),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: SizeConstants.font(4),
          ),
          SizedBox(width: SizeConstants.width(2)),
          Expanded(
            child: Text(
              message,
              style: TextStyles.smallText(
                color: Colors.red[700],
                size: SizeConstants.font(3.2),
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConstants.width(3)),
      margin: EdgeInsets.only(bottom: SizeConstants.height(1)),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeConstants.width(2)),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: SizeConstants.font(4),
          ),
          SizedBox(width: SizeConstants.width(2)),
          Expanded(
            child: Text(
              message,
              style: TextStyles.smallText(
                color: Colors.green[700],
                size: SizeConstants.font(3.2),
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(PasswordSettingsController controller) {
    return Center(
      child: SizedBox(
        width: SizeConstants.width(50),
        height: SizeConstants.height(6.5),
        child: ElevatedButton(
        onPressed: controller.isLoading ? null : controller.updatePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConstants.width(16)),
          ),
          elevation: 0,
        ),
        child: controller.isLoading
            ? SizedBox(
                width: SizeConstants.width(6),
                height: SizeConstants.width(6),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Change Password',
                style: TextStyles.buttonText(
                  color: Colors.white,
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.w600,
                ),
              ),
        ),
      ),
    );
  }
}
