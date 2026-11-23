import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/analysis/search_screen/controller/search_controller.dart'
    as search_controller;
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (context) => search_controller.SearchController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        body: Consumer<search_controller.SearchController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                // Header Section
                _buildHeader(context),
                // Main Content
                Expanded(child: _buildMainContent(controller, context)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SizeConstants.width(5)),
          child: Column(
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: SizeConstants.width(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Search',
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyText(
                        color: Colors.white,
                        size: SizeConstants.font(4.5),
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                  NotificationIconButton(
                    iconColor: Colors.white,
                    iconSize: SizeConstants.font(6),
                    showBadge: true,
                    badgeCount: 5,
                  ),
                ],
              ),
              SizedBox(height: SizeConstants.height(2)),
              // Search Bar
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<search_controller.SearchController>(
      builder: (context, controller, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConstants.width(4),
            vertical: SizeConstants.height(1),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            onChanged: controller.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyles.smallText(
                color: Colors.grey[400],
                size: SizeConstants.font(3.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyles.bodyText(
              color: ColorTheme.mainColor,
              size: SizeConstants.font(3.5),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
    search_controller.SearchController controller,
    BuildContext context,
  ) {
    if (controller.isInitializing) {
      return _buildLoadingState();
    }

    if (controller.loadError != null) {
      return _buildLoadError(controller);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          children: [
            // Filter Sections
            _buildFilterSections(controller, context),
            SizedBox(height: SizeConstants.height(3)),
            // Search Button
            _buildSearchButton(controller),
            SizedBox(height: SizeConstants.height(3)),
            // Results Section
            Expanded(child: _buildResultsSection(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSections(
    search_controller.SearchController controller,
    BuildContext context,
  ) {
    return Column(
      children: [
        // Categories Section
        _buildCategorySection(controller, context),
        SizedBox(height: SizeConstants.height(2)),
        // Date Section
        _buildDateSection(controller, context),
        SizedBox(height: SizeConstants.height(2)),
        // Report Section
        _buildReportSection(controller),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadError(search_controller.SearchController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: SizeConstants.height(1.5)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(10)),
            child: Text(
              controller.loadError ?? 'Failed to load data',
              textAlign: TextAlign.center,
              style: TextStyles.smallText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(3.5),
              ),
            ),
          ),
          SizedBox(height: SizeConstants.height(2)),
          ElevatedButton(
            onPressed: controller.refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.secondaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    search_controller.SearchController controller,
    BuildContext context,
  ) {
    final hasCategories = controller.categories.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyles.bodyText(
            color: ColorTheme.mainColor,
            size: SizeConstants.font(3.5),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(1)),
        GestureDetector(
          onTap: () {
            if (hasCategories) {
              _showCategoryPicker(controller, context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No categories available yet. Add a category first.',
                  ),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(4),
              vertical: SizeConstants.height(1.5),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.selectedCategory.isEmpty
                      ? (hasCategories
                            ? 'Select the category.'
                            : 'No categories found')
                      : controller.selectedCategory,
                  style: TextStyles.smallText(
                    color: controller.selectedCategory.isEmpty
                        ? Colors.grey[600]
                        : ColorTheme.mainColor,
                    size: SizeConstants.font(3.5),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: ColorTheme.secondaryColor,
                  size: SizeConstants.font(4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(
    search_controller.SearchController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyles.bodyText(
            color: ColorTheme.mainColor,
            size: SizeConstants.font(3.5),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(1)),
        GestureDetector(
          onTap: () => _showDatePicker(controller, context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(4),
              vertical: SizeConstants.height(1.5),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.selectedDate.day} /${_getMonthName(controller.selectedDate.month)}/${controller.selectedDate.year}',
                  style: TextStyles.smallText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3.5),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: ColorTheme.secondaryColor,
                  size: SizeConstants.font(4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportSection(search_controller.SearchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report',
          style: TextStyles.bodyText(
            color: ColorTheme.mainColor,
            size: SizeConstants.font(3.5),
            weight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConstants.height(1)),
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                'Income',
                'Income',
                controller.selectedReportType,
                controller.selectReportType,
              ),
            ),
            SizedBox(width: SizeConstants.width(5)),
            Expanded(
              child: _buildRadioOption(
                'Expense',
                'Expense',
                controller.selectedReportType,
                controller.selectReportType,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(
    String label,
    String value,
    String selectedValue,
    Function(String) onChanged,
  ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Container(
            width: SizeConstants.width(5),
            height: SizeConstants.width(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? ColorTheme.secondaryColor : Colors.grey,
                width: 2,
              ),
              color: isSelected
                  ? ColorTheme.secondaryColor
                  : Colors.transparent,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: SizeConstants.font(3),
                  )
                : null,
          ),
          SizedBox(width: SizeConstants.width(2)),
          Text(
            label,
            style: TextStyles.smallText(
              color: ColorTheme.mainColor,
              size: SizeConstants.font(3.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(search_controller.SearchController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isSearching ? null : controller.performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.secondaryColor,
          padding: EdgeInsets.symmetric(vertical: SizeConstants.height(1.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: controller.isSearching
            ? SizedBox(
                width: SizeConstants.width(5),
                height: SizeConstants.width(5),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Search',
                style: TextStyles.buttonText(
                  color: Colors.white,
                  size: SizeConstants.font(4),
                  weight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildResultsSection(search_controller.SearchController controller) {
    if (!controller.hasSearched) {
      return const SizedBox.shrink();
    }

    if (controller.isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: ColorTheme.secondaryColor),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'Searching...',
              style: TextStyles.smallText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(3.5),
              ),
            ),
          ],
        ),
      );
    }

    if (controller.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey[400],
              size: SizeConstants.font(15),
            ),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'No results found',
              style: TextStyles.bodyText(
                color: Colors.grey[600],
                size: SizeConstants.font(4),
                weight: FontWeight.w600,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Text(
              'Try adjusting your search criteria',
              style: TextStyles.smallText(
                color: Colors.grey[500],
                size: SizeConstants.font(3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final result = controller.searchResults[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(search_controller.SearchResult result) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
      padding: EdgeInsets.all(SizeConstants.width(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: SizeConstants.width(10),
            height: SizeConstants.width(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getIconForCategory(result.category),
              color: ColorTheme.secondaryColor,
              size: SizeConstants.font(4),
            ),
          ),

          SizedBox(width: SizeConstants.width(3)),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: TextStyles.bodyText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3.5),
                    weight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConstants.height(0.3)),
                Text(
                  result.time,
                  style: TextStyles.smallText(
                    color: const Color(0xFF0068FF),
                    size: SizeConstants.font(2.8),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${result.isExpense ? '-' : ''}\₹${result.amount.toStringAsFixed(2)}',
            style: TextStyles.bodyText(
              color: const Color(0xFF0068FF),
              size: SizeConstants.font(3.5),
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'income':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  void _showCategoryPicker(
    search_controller.SearchController controller,
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: TextStyles.bodyText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(4.5),
                weight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConstants.height(2)),
            if (controller.categories.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConstants.height(5),
                ),
                child: Text(
                  'No categories available.',
                  style: TextStyles.smallText(
                    color: ColorTheme.mainColor,
                    size: SizeConstants.font(3.5),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return ListTile(
                      title: Text(
                        category,
                        style: TextStyles.smallText(
                          color: ColorTheme.mainColor,
                          size: SizeConstants.font(3.5),
                        ),
                      ),
                      onTap: () {
                        controller.selectCategory(category);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: SizeConstants.height(1)),
            TextButton(
              onPressed: () {
                controller.selectCategory('');
                Navigator.pop(context);
              },
              child: Text(
                'Clear Selection',
                style: TextStyles.smallText(
                  color: ColorTheme.secondaryColor,
                  size: SizeConstants.font(3.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(
    search_controller.SearchController controller,
    BuildContext context,
  ) {
    showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        controller.selectDate(selectedDate);
      }
    });
  }
}
