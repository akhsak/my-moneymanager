import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(String name, IconData icon) onSave;
  
  const AddCategoryDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedIcon = 'drink';
  
  final List<Map<String, dynamic>> _icons = [
    { 'id': 'drink', 'icon': Icons.local_drink, 'name': 'Drink' },
    { 'id': 'bus', 'icon': Icons.directions_bus, 'name': 'Bus' },
    { 'id': 'food', 'icon': Icons.restaurant, 'name': 'Food' },
    { 'id': 'home', 'icon': Icons.home, 'name': 'Home' },
    { 'id': 'watch', 'icon': Icons.watch, 'name': 'Watch' },
    { 'id': 'milk', 'icon': Icons.local_drink, 'name': 'Milk' },
    { 'id': 'cloud', 'icon': Icons.cloud, 'name': 'Cloud' },
    { 'id': 'shopping', 'icon': Icons.shopping_bag, 'name': 'Shopping' },
    { 'id': 'gift', 'icon': Icons.card_giftcard, 'name': 'Gift' },
    { 'id': 'movie', 'icon': Icons.movie, 'name': 'Movie' },
    { 'id': 'medicine', 'icon': Icons.local_pharmacy, 'name': 'Medicine' },
    { 'id': 'wallet', 'icon': Icons.account_balance_wallet, 'name': 'Wallet' },
    { 'id': 'savings', 'icon': Icons.savings, 'name': 'Savings' },
    { 'id': 'money', 'icon': Icons.attach_money, 'name': 'Money' },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_nameController.text.trim().isNotEmpty) {
      final selectedIconData = _icons.firstWhere((icon) => icon['id'] == _selectedIcon)['icon'] as IconData;
      widget.onSave(_nameController.text.trim(), selectedIconData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(SizeConstants.width(5)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConstants.width(3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConstants.width(5),
                vertical: SizeConstants.height(2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Category',
                    style: TextStyles.bodyText(
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(5),
                      weight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(5),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name input
                  Text(
                    'Name',
                    style: TextStyles.smallText(
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(3.5),
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: SizeConstants.height(1)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConstants.width(4),
                      vertical: SizeConstants.height(1.5),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter category name',
                        hintStyle: TextStyles.smallText(
                          color: Colors.grey[600],
                          size: SizeConstants.font(3.2),
                        ),
                      ),
                      style: TextStyles.smallText(
                        color: ColorTheme.mainColor,
                        size: SizeConstants.font(3.2),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: SizeConstants.height(3)),
                  
                  // Icon selection
                  Text(
                    'Icon',
                    style: TextStyles.smallText(
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(3.5),
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: SizeConstants.height(1)),
                  Container(
                    padding: EdgeInsets.all(SizeConstants.width(3)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: SizeConstants.width(2),
                        mainAxisSpacing: SizeConstants.height(1.5),
                        childAspectRatio: 1,
                      ),
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final iconData = _icons[index];
                        final isSelected = _selectedIcon == iconData['id'];
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = iconData['id'] as String;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? ColorTheme.secondaryColor 
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected 
                                    ? ColorTheme.secondaryColor 
                                    : const Color(0xFFE3F2FD),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              iconData['icon'] as IconData,
                              color: isSelected 
                                  ? Colors.white 
                                  : ColorTheme.mainColor,
                              size: SizeConstants.font(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: SizeConstants.height(4)),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: Container(
                          height: SizeConstants.height(5.5),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyles.buttonText(
                                color: Colors.white,
                                size: SizeConstants.font(3.5),
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: SizeConstants.width(3)),
                      
                      // Save button
                      Expanded(
                        child: Container(
                          height: SizeConstants.height(5.5),
                          child: ElevatedButton(
                            onPressed: _saveCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                              ),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyles.buttonText(
                                color: Colors.white,
                                size: SizeConstants.font(3.5),
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: SizeConstants.height(3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
