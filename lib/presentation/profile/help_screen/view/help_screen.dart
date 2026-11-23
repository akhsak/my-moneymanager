import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/help_screen/controller/help_controller.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (_) => HelpController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorTheme.mainColor2,
              size: SizeConstants.width(4),
            ),
          ),
          title: Text(
            'Help & FAQS',
            style: TextStyles.bodyText(
              color: ColorTheme.mainColor2,
              size: SizeConstants.font(4),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                MyFlutterApp.vector__8_,
                color: ColorTheme.mainColor2,
                size: SizeConstants.width(4),
              ),
            ),
          ],
        ),
        body: Consumer<HelpController>(
          builder: (context, controller, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeConstants.width(6)),
                  topRight: Radius.circular(SizeConstants.width(6)),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConstants.width(4.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConstants.height(2)),

                    // How Can We Help You? Title
                    Text(
                      'How Can We Help You?',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(4),
                        weight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: SizeConstants.height(2)),

                    // Tab Buttons (FAQ and Contact Us)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTabButton(
                            context,
                            controller,
                            'FAQ',
                            controller.selectedTab == 'FAQ',
                          ),
                        ),
                        SizedBox(width: SizeConstants.width(2.5)),
                        Expanded(
                          child: _buildTabButton(
                            context,
                            controller,
                            'Contact Us',
                            controller.selectedTab == 'Contact Us',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConstants.height(2)),

                    // Search Bar (only show in FAQ tab)
                    if (controller.selectedTab == 'FAQ') ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConstants.width(3),
                          vertical: SizeConstants.height(1.5),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            SizeConstants.width(4.5),
                          ),
                          border: Border.all(
                            color: ColorTheme.secondaryColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey[600],
                              size: SizeConstants.width(4),
                            ),
                            SizedBox(width: SizeConstants.width(2.5)),
                            Text(
                              'Search',
                              style: TextStyles.bodyText(
                                color: Colors.grey[600],
                                size: SizeConstants.font(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(2)),
                    ],

                    // Content based on selected tab
                    Expanded(
                      child: controller.selectedTab == 'FAQ'
                          ? _buildFAQContent(controller)
                          : _buildContactContent(context, controller),
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

  Widget _buildTabButton(
    BuildContext context,
    HelpController controller,
    String title,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        controller.setSelectedTab(title);
      },
      child: Container(
        height: SizeConstants.height(4.5),
        decoration: BoxDecoration(
          color: isSelected ? ColorTheme.secondaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(SizeConstants.width(4.5)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyles.bodyText(
              color: isSelected ? ColorTheme.mainColor2 : Colors.grey[700],
              size: SizeConstants.font(3),
              weight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQContent(HelpController controller) {
    return ListView.builder(
      itemCount: controller.faqs.length,
      itemBuilder: (context, index) {
        final faq = controller.faqs[index];
        return Container(
          margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConstants.width(2.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: SizeConstants.width(1),
                offset: Offset(0, SizeConstants.height(0.5)),
              ),
            ],
          ),
          child: Column(
            children: [
              // Question Header
              GestureDetector(
                onTap: () => controller.toggleFAQExpansion(faq.id),
                child: Padding(
                  padding: EdgeInsets.all(SizeConstants.width(3)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: TextStyles.bodyText(
                            size: SizeConstants.font(3),
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        faq.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: SizeConstants.width(4.5),
                      ),
                    ],
                  ),
                ),
              ),

              // Answer (Expandable)
              if (faq.isExpanded)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(SizeConstants.width(3)),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(SizeConstants.width(2.5)),
                      bottomRight: Radius.circular(SizeConstants.width(2.5)),
                    ),
                  ),
                  child: Text(
                    faq.answer,
                    style: TextStyles.smallText(
                      color: Colors.grey[700],
                      size: SizeConstants.font(2.8),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactContent(BuildContext context, HelpController controller) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConstants.width(3),
            vertical: SizeConstants.height(1.5),
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(SizeConstants.width(4.5)),
            border: Border.all(color: ColorTheme.secondaryColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.grey[600],
                size: SizeConstants.width(4),
              ),
              SizedBox(width: SizeConstants.width(2.5)),
              Text(
                'Search',
                style: TextStyles.bodyText(
                  color: Colors.grey[600],
                  size: SizeConstants.font(3),
                ),
              ),
            ],
          ),
        ),
        _buildContactOption(
          context,
          controller,
          'Customer Service',
          Icons.headset_mic,
          () => controller.navigateToCustomerService(context),
        ),
        SizedBox(height: SizeConstants.height(1.5)),
        _buildContactOption(
          context,
          controller,
          'Website',
          Icons.language,
          () => controller.openWebsite(),
        ),
        SizedBox(height: SizeConstants.height(1.5)),
        _buildContactOption(
          context,
          controller,
          'Facebook',
          Icons.facebook,
          () => controller.openFacebook(),
        ),
        SizedBox(height: SizeConstants.height(1.5)),
        _buildContactOption(
          context,
          controller,
          'Whatsapp',
          Icons.message,
          () => controller.openWhatsApp(),
        ),
        SizedBox(height: SizeConstants.height(1.5)),
        _buildContactOption(
          context,
          controller,
          'Instagram',
          Icons.camera_alt,
          () => controller.openInstagram(),
        ),
      ],
    );
  }

  Widget _buildContactOption(
    BuildContext context,
    HelpController controller,
    String title,
    IconData iconData,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SizeConstants.width(3)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConstants.width(2.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: SizeConstants.width(1),
              offset: Offset(0, SizeConstants.height(0.5)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: SizeConstants.width(9),
              height: SizeConstants.width(9),
              decoration: BoxDecoration(
                color: ColorTheme.secondaryColor,
                borderRadius: BorderRadius.circular(SizeConstants.width(4.5)),
              ),
              child: Icon(
                iconData,
                color: ColorTheme.mainColor2,
                size: SizeConstants.width(4.5),
              ),
            ),
            SizedBox(width: SizeConstants.width(3)),
            Expanded(
              child: Text(
                title,
                style: TextStyles.bodyText(
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: SizeConstants.width(3.5),
            ),
          ],
        ),
      ),
    );
  }
}
