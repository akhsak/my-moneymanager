import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/presentation/profile/help_screen/controller/faq_model.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/online_support_screen/controller/online_support_controller.dart';

class OnlineSupportScreen extends StatelessWidget {
  const OnlineSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (_) => OnlineSupportController(),
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
            'Online Support',
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
        body: Consumer<OnlineSupportController>(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConstants.height(2)),

                    // Active Chats Section
                    if (controller.activeChats.isNotEmpty) ...[
                      Text(
                        'Active Chats',
                        style: TextStyles.bodyText(
                          size: SizeConstants.font(3.5),
                          weight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: SizeConstants.height(1.5)),
                      ...controller.activeChats.map(
                        (chat) =>
                            _buildChatItem(context, controller, chat, true),
                      ),
                      SizedBox(height: SizeConstants.height(3)),
                    ],

                    // Ended Chats Section
                    Text(
                      'Ended Chats',
                      style: TextStyles.bodyText(
                        size: SizeConstants.font(3.5),
                        weight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(1.5)),

                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.endedChats.length,
                        itemBuilder: (context, index) {
                          return _buildChatItem(
                            context,
                            controller,
                            controller.endedChats[index],
                            false,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: SizeConstants.height(2)),

                    // Start Another Chat Button
                    SizedBox(
                      width: double.infinity,
                      height: SizeConstants.height(4.5),
                      child: ElevatedButton(
                        onPressed: () => controller.startNewChat(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTheme.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SizeConstants.width(4.5),
                            ),
                          ),
                        ),
                        child: Text(
                          'Start Another Chat',
                          style: TextStyles.buttonText(
                            size: SizeConstants.font(3.5),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConstants.height(1.5)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    OnlineSupportController controller,
    ChatMessage chat,
    bool isActive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
      padding: EdgeInsets.all(SizeConstants.width(3)),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFE8E4FF)
            : const Color(0xFFE8E4FF), // Light purple background
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
      ),
      child: GestureDetector(
        onTap: () => controller.openChat(chat.id),
        child: Row(
          children: [
            // Chat Icon
            Container(
              width: SizeConstants.width(9),
              height: SizeConstants.width(9),
              decoration: BoxDecoration(
                color: ColorTheme.secondaryColor,
                borderRadius: BorderRadius.circular(SizeConstants.width(4.5)),
              ),
              child: Icon(
                Icons.headset_mic,
                color: ColorTheme.mainColor2,
                size: SizeConstants.width(4.5),
              ),
            ),

            SizedBox(width: SizeConstants.width(2.5)),

            // Chat Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.title,
                    style: TextStyles.bodyText(
                      size: SizeConstants.font(3.2),
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: SizeConstants.height(0.5)),
                  Text(
                    chat.message,
                    style: TextStyles.smallText(
                      color: Colors.grey[600],
                      size: SizeConstants.font(2.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time
            Text(
              chat.time,
              style: TextStyles.smallText(
                color: Colors.grey[600],
                size: SizeConstants.font(2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
