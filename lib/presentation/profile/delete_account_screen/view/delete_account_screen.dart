import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/presentation/profile/delete_account_screen/controller/delete_account_controller.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return ChangeNotifierProvider(
      create: (_) => DeleteAccountController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: CustomAppBar(
          title: 'Delete Account',
          showProfileAvatar: false,
          showBackButton: true,
          showNotification: true,
        ),
        body: Consumer<DeleteAccountController>(
          builder: (context, controller, _) {
            return SafeArea(
              top: false,
              child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConstants.width(5)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: SizeConstants.height(3)),
                      Text(
                        'Are You Sure You Want To Delete\nYour Account?',
                        textAlign: TextAlign.center,
                        style: TextStyles.bodyText(
                          size: SizeConstants.font(4),
                          weight: FontWeight.w700,
                          color: const Color(0xFF0E3C2F),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(3)),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(SizeConstants.width(4)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bullet('This action will permanently delete all of your data, and you will not be able to recover it. Please keep the following in mind before proceeding:'),
                              SizedBox(height: SizeConstants.height(1.5)),
                              _dotBullet('All your expenses, income and associated transactions will be eliminated.'),
                              SizedBox(height: SizeConstants.height(0.8)),
                              _dotBullet('You will not be able to access your account or any related information.'),
                              SizedBox(height: SizeConstants.height(0.8)),
                              _dotBullet('This action cannot be undone.'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(4)),
                      Text(
                        'Please Enter Your Password To Confirm\nDeletion Of Your Account.',
                        textAlign: TextAlign.center,
                        style: TextStyles.bodyText(
                          size: SizeConstants.font(3.6),
                          weight: FontWeight.w700,
                          color: const Color(0xFF0E3C2F),
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(2.5)),
                      _PasswordField(controller: controller),
                      SizedBox(height: SizeConstants.height(2)),
                      
                      // Error Message
                      if (controller.errorMessage != null)
                        _buildErrorMessage(controller.errorMessage!),
                      
                      // Success Message
                      if (controller.successMessage != null)
                        _buildSuccessMessage(controller.successMessage!),
                      
                      SizedBox(height: SizeConstants.height(2)),
                      _PrimaryButton(
                        text: 'Yes, Delete Account',
                        isLoading: controller.isLoading,
                        onPressed: () async {
                          final success = await controller.confirmDelete();
                          if (success && context.mounted) {
                            // Navigate to login screen after successful deletion
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                      ),
                      SizedBox(height: SizeConstants.height(1.5)),
                      _SecondaryButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(height: SizeConstants.height(2)),
                    ],
                  ),
                ),
              ),
            ));
          },
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Text(
      text,
      style: TextStyles.smallText(
        size: SizeConstants.font(3.2),
        color: ColorTheme.mainColor,
      ),
    );
  }

  Widget _dotBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: TextStyles.smallText(
            size: SizeConstants.font(3.2),
            color: ColorTheme.mainColor,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyles.smallText(
              size: SizeConstants.font(3.2),
              color: ColorTheme.mainColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConstants.width(3)),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
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
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
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
}

class _PasswordField extends StatelessWidget {
  final DeleteAccountController controller;
  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.passwordController,
              obscureText: !controller.showPassword,
              onChanged: (value) => controller.onPasswordChanged(),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: 'Enter your password',
                hintStyle: TextStyles.smallText(
                  size: SizeConstants.font(4),
                  color: Colors.grey[600],
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(4),
                  vertical: SizeConstants.height(2.2),
                ),
              ),
              style: TextStyles.smallText(
                size: SizeConstants.font(4),
                color: ColorTheme.mainColor,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.togglePassword,
            icon: Icon(
              controller.showPassword ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF0E3C2F),
              size: SizeConstants.font(4),
            ),
          )
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConstants.width(70),
      height: SizeConstants.height(6.5),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: SizeConstants.width(6),
                height: SizeConstants.width(6),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyles.buttonText(
                  color: Colors.white,
                  size: SizeConstants.font(3.8),
                  weight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _SecondaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConstants.width(70),
      height: SizeConstants.height(6.5),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorTheme.secondaryColor,
          side: BorderSide(color: ColorTheme.secondaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          style: TextStyles.buttonText(
            color: ColorTheme.secondaryColor,
            size: SizeConstants.font(3.8),
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
