import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/presentation/profile/pin_chanage_screen/controller/pin_change_controller.dart';

class PinChangeScreen extends StatelessWidget {
  const PinChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return ChangeNotifierProvider(
      create: (_) => PinChangeController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: SizeConstants.width(3.5),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Change Pin',
            style: TextStyles.bodyText(
              color: Colors.white,
              size: SizeConstants.font(4.5),
              weight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
              icon: Icon(
                MyFlutterApp.vector__8_,
                color: Colors.white,
                size: SizeConstants.width(3.5),
              ),
            ),
          ],
        ),
        body: Consumer<PinChangeController>(
          builder: (context, controller, _) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConstants.width(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConstants.height(2)),
                    _PinField(
                      label: 'Current Pin',
                      controller: controller.currentPinController,
                      obscure: !controller.showCurrent,
                      onToggle: controller.toggleCurrent,
                    ),
                    SizedBox(height: SizeConstants.height(3)),
                    _PinField(
                      label: 'New Pin',
                      controller: controller.newPinController,
                      obscure: !controller.showNew,
                      onToggle: controller.toggleNew,
                    ),
                    SizedBox(height: SizeConstants.height(3)),
                    _PinField(
                      label: 'Confirm Pin',
                      controller: controller.confirmPinController,
                      obscure: !controller.showConfirm,
                      onToggle: controller.toggleConfirm,
                    ),
                    SizedBox(height: SizeConstants.height(6)),
                    Center(
                      child: SizedBox(
                        width: SizeConstants.width(60),
                        height: SizeConstants.height(6.5),
                        child: ElevatedButton(
                          onPressed: controller.submitChange,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Change Pin',
                            style: TextStyles.buttonText(
                              color: Colors.white,
                              size: SizeConstants.font(3.8),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  const _PinField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.smallText(
            size: SizeConstants.font(3.6),
            weight: FontWeight.w600,
            color: const Color(0xFF0E3C2F),
          ),
        ),
        SizedBox(height: SizeConstants.height(1)),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  obscureText: obscure,
                  maxLength: 4,
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeConstants.width(4),
                      vertical: SizeConstants.height(2),
                    ),
                  ),
                  style: TextStyles.smallText(
                    size: SizeConstants.font(4),
                    color: ColorTheme.mainColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF0E3C2F),
                  size: SizeConstants.font(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
