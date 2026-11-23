import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/security_screen/controller/security_controller.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    final controller = SecurityController();
    final items = controller.buildItems(context);

    return Scaffold(
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
          'Security',
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
      body: Container(
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
              Text(
                'Security',
                style: TextStyles.bodyText(
                  size: SizeConstants.font(5),
                  weight: FontWeight.w800,
                  color: const Color(0xFF0E3C2F),
                ),
              ),
              SizedBox(height: SizeConstants.height(3)),
              ...items.expand(
                (item) => [
                  _SecurityTile(title: item.title, onTap: item.onTap),
                  SizedBox(height: SizeConstants.height(1)),
                ],
              ),
              SizedBox(height: SizeConstants.height(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _SecurityTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: SizeConstants.height(2.2)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.smallText(
                    size: SizeConstants.font(3.8),
                    weight: FontWeight.w500,
                    color: const Color(0xFF0E3C2F),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ColorTheme.secondaryColor,
                size: SizeConstants.font(4.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
