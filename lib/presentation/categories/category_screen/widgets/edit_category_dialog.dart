import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/repository/category/model/category_model.dart';

class EditCategoryDialog extends StatefulWidget {
  final CategoryModel category;
  final Function(String name, String icon) onSave;
  final Function() onDelete;
  final List<String> existingCategoryNames;

  const EditCategoryDialog({
    super.key,
    required this.category,
    required this.onSave,
    required this.onDelete,
    this.existingCategoryNames = const [],
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _nameController;
  String _selectedIcon = '';
  bool _isLoading = false;

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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Category',
                  style: TextStyles.bodyText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(4.5),
                    weight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: ColorTheme.mainColor),
                ),
              ],
            ),
            
            SizedBox(height: SizeConstants.height(2)),
            
            // Name Field
            Text(
              'Name',
              style: TextStyles.smallText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(3.4),
                weight: FontWeight.w600,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConstants.width(4),
                vertical: SizeConstants.height(1.2),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter category name',
                ),
              ),
            ),
            
            SizedBox(height: SizeConstants.height(2.5)),
            
            // Icon Selection
            Text(
              'Icon',
              style: TextStyles.smallText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(3.4),
                weight: FontWeight.w600,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Container(
              padding: EdgeInsets.all(SizeConstants.width(3)),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final iconData = _icons[index];
                  final isSelected = _selectedIcon == iconData['id'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['id'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? ColorTheme.secondaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? ColorTheme.secondaryColor : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        iconData['icon'],
                        color: isSelected ? Colors.white : ColorTheme.mainColor,
                        size: SizeConstants.font(3.5),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: SizeConstants.height(3)),
            
            // Action Buttons
            Row(
              children: [
                // Delete Button
                Expanded(
                  child: GestureDetector(
                    onTap: _showDeleteConfirmation,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.5)),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: SizeConstants.font(4),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: SizeConstants.width(2)),
                
                // Cancel Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.5)),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyles.smallText(
                          color: Colors.grey,
                          size: SizeConstants.font(3.2),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: SizeConstants.width(2)),
                
                // Save Button
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _saveCategory,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.5)),
                      decoration: BoxDecoration(
                        color: _isLoading ? ColorTheme.secondaryColor.withOpacity(0.5) : ColorTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: SizeConstants.width(4),
                              height: SizeConstants.width(4),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save',
                              textAlign: TextAlign.center,
                              style: TextStyles.smallText(
                                color: Colors.white,
                                size: SizeConstants.font(3.2),
                                weight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedIcon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an icon'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if the new name already exists (excluding the current category)
    final newName = _nameController.text.trim();
    final currentName = widget.category.name;
    
    print('EditCategoryDialog validation:');
    print('New name: "$newName"');
    print('Current name: "$currentName"');
    print('Existing categories: ${widget.existingCategoryNames}');
    
    // If the name hasn't changed, allow it
    if (newName.toLowerCase() == currentName.toLowerCase()) {
      print('Name unchanged, allowing save');
    } else {
      final nameExists = widget.existingCategoryNames.any((name) => 
        name.toLowerCase() == newName.toLowerCase() && name.toLowerCase() != currentName.toLowerCase());
      
      // Also check for similar names that might cause conflicts (singular/plural)
      final similarNameExists = widget.existingCategoryNames.any((name) => {
        // Check for singular/plural conflicts
        (name.toLowerCase() == '${newName.toLowerCase()}s' && name.toLowerCase() != currentName.toLowerCase()),
        ('${name.toLowerCase()}s' == newName.toLowerCase() && name.toLowerCase() != currentName.toLowerCase()),
      }.any((condition) => condition));
      
      final finalNameExists = nameExists || similarNameExists;
      
      print('Name exists check result: $nameExists');
      print('Similar name exists check result: $similarNameExists');
      print('Final name exists result: $finalNameExists');
      
      if (finalNameExists) {
        print('Preventing save due to duplicate name');
        // Generate suggestions for alternative names
        final suggestions = _generateNameSuggestions(newName);
        final suggestionText = suggestions.isNotEmpty 
            ? ' Suggested alternatives: ${suggestions.join(', ')}'
            : '';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A category with this name already exists. Please choose a different name.$suggestionText'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 6),
          ),
        );
        return;
      }
      
      // Additional warning for potential conflicts that might exist in database but not in current list
      // This is a conservative approach - warn user about potential conflicts
      print('Warning: API might have additional categories not in current list. Proceeding with caution.');
    }
    
    print('Validation passed, proceeding with save');

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(_nameController.text.trim(), _selectedIcon);
      // Note: Navigator.pop and SnackBar are handled by the parent callback
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to generate alternative name suggestions
  List<String> _generateNameSuggestions(String baseName) {
    final suggestions = <String>[];
    
    // Try adding numbers
    for (int i = 2; i <= 5; i++) {
      final suggestion = '$baseName $i';
      if (!widget.existingCategoryNames.any((name) => name.toLowerCase() == suggestion.toLowerCase())) {
        suggestions.add(suggestion);
      }
    }
    
    // Try adding "New" prefix
    final newSuggestion = 'New $baseName';
    if (!widget.existingCategoryNames.any((name) => name.toLowerCase() == newSuggestion.toLowerCase())) {
      suggestions.add(newSuggestion);
    }
    
    // Try adding "My" prefix
    final mySuggestion = 'My $baseName';
    if (!widget.existingCategoryNames.any((name) => name.toLowerCase() == mySuggestion.toLowerCase())) {
      suggestions.add(mySuggestion);
    }
    
    return suggestions.take(3).toList(); // Return max 3 suggestions
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${widget.category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              await widget.onDelete();
              // Note: Edit dialog closing is handled by the parent callback
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
