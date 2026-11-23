import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/repository/category/model/category_model.dart';
import 'package:monaymanagment/repository/transaction/model/transaction_model.dart'
    as transaction_repo;
import 'package:monaymanagment/presentation/categories/category_wise_expense_list_screen/controller/category_wise_list_controller.dart';
import 'package:monaymanagment/presentation/categories/category_wise_expense_list_screen/widgets/edit_sub_transaction_dialog.dart';
import 'package:monaymanagment/presentation/categories/category_screen/widgets/edit_category_dialog.dart';
import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryWiseExpenseListScreen extends StatelessWidget {
  final String category;
  final IconData? categoryIcon;
  const CategoryWiseExpenseListScreen({
    super.key,
    required this.category,
    this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    final categoryController = CategoryController();
    final resolvedIcon =
        categoryIcon ?? categoryController.getIconForCategory(category);

    // Get the singleton controller instance for this category
    final controller = CategoryWiseListController(
      category: category,
      categoryIcon: resolvedIcon,
    );

    // Load data immediately if needed
    if (!controller.isDataLoaded && !controller.isLoading) {
      controller.loadCategoryTransactions();
    }

    return Scaffold(
      backgroundColor: ColorTheme.secondaryColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.secondaryColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: SizeConstants.width(3.5),
          ),
        ),
        title: Text(
          '$category Transactions',
          style: GoogleFonts.poppins(
            textStyle: TextStyles.bodyText(
              color: Colors.white,
              size: SizeConstants.font(4.5),
              weight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _refreshTransactions(context, controller),
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: SizeConstants.width(4),
            ),
          ),
          IconButton(
            onPressed: () => _showEditCategoryDialog(context, category),
            icon: Icon(
              Icons.edit,
              color: Colors.white,
              size: SizeConstants.width(4),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return StreamBuilder<List<ExpenseItem>>(
            stream: controller.itemsStream,
            builder: (context, snapshot) {
              // Prefer stream data for list rendering; controller flags drive loading/error
              final streamedItems = snapshot.data;
              return _buildBody(controller, streamedItems);
            },
          );
        },
      ),
    );
  }

  Future<void> _refreshTransactions(
    BuildContext context,
    CategoryWiseListController controller,
  ) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshing $category transactions...'),
        duration: const Duration(milliseconds: 800),
      ),
    );

    await controller.loadCategoryTransactions(forceReload: true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Latest transactions loaded'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _showEditCategoryDialog(BuildContext context, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => CategoryController(),
        child: Consumer<CategoryController>(
          builder: (context, categoryController, child) {
            final categoryModel = categoryController.getCategoryByName(
              categoryName,
            );

            // Create a temporary category model if none exists
            final tempCategory =
                categoryModel ??
                CategoryModel(
                  id: '',
                  name: categoryName,
                  icon: '',
                  isActive: true,
                  userId: '',
                  createdAt: DateTime.now().toIso8601String(),
                  updatedAt: DateTime.now().toIso8601String(),
                );

            return EditCategoryDialog(
              category: tempCategory,
              existingCategoryNames: categoryController.apiCategories
                  .map((cat) => cat.name)
                  .toList(),
              onSave: (name, icon) async {
                if (categoryModel != null) {
                  final success = await categoryController.updateCategory(
                    categoryModel.id,
                    name,
                    icon,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (categoryController.errorMessage != null) {
                    final errorMessage = categoryController.errorMessage!;
                    // Check if error is due to name conflict
                    if (errorMessage.contains('already exists')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'A category with this name already exists in the database. Please choose a different name or try adding a number (e.g., "Gift 2").',
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 6),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  // Create new category if it doesn't exist
                  final success = await categoryController.createCategory(
                    name,
                    Icons.category,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (categoryController.errorMessage != null) {
                    final errorMessage = categoryController.errorMessage!;
                    // Check if error is due to name conflict
                    if (errorMessage.contains('already exists')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'A category with this name already exists in the database. Please choose a different name or try adding a number (e.g., "Gift 2").',
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 6),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              onDelete: () async {
                if (categoryModel != null) {
                  final success = await categoryController.deleteCategory(
                    categoryName,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Navigate back to category screen to refresh the list
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else if (categoryController.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(categoryController.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cannot delete a category that doesn\'t exist',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    CategoryWiseListController controller,
    List<ExpenseItem>? streamedItems,
  ) {
    // Show loading only if no data is loaded yet
    if (controller.isLoading && !controller.isDataLoaded) {
      return _buildShimmerLoading();
    }

    // Show error only if no data is loaded and there's an error
    if (controller.errorMessage != null && !controller.isDataLoaded) {
      return _buildErrorState(controller.errorMessage!, controller);
    }

    // Show the main content (even if loading in background)
    final currentItems = streamedItems ?? controller.items;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: RefreshIndicator(
        color: ColorTheme.secondaryColor,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await controller.loadCategoryTransactions(forceReload: true);
        },
        child: currentItems.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: SizeConstants.height(95),
                  child: _buildEmptyState(),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(SizeConstants.width(5)),
                cacheExtent: SizeConstants.height(50),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                addSemanticIndexes: false,
                separatorBuilder: (_, __) =>
                    SizedBox(height: SizeConstants.height(1.2)),
                itemCount: currentItems.length,
                itemBuilder: (context, index) {
                  final item = currentItems[index];
                  return _TransactionItem(
                    item: item,
                    category: category,
                    controller: controller,
                    index: index,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildErrorState(String error, CategoryWiseListController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   Icons.error_outline,
            //   size: SizeConstants.font(12),
            //   color: Colors.red,
            // ),
            // SizedBox(height: SizeConstants.height(2)),
            Text(
              'Error loading transactions',
              style: GoogleFonts.poppins(
                textStyle: TextStyles.bodyText(
                  color: Colors.grey,
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Text(
              error,
              style: GoogleFonts.poppins(
                textStyle: TextStyles.smallText(
                  color: Colors.grey,
                  size: SizeConstants.font(3.5),
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConstants.height(3)),
            ElevatedButton(
              onPressed: () => controller.loadCategoryTransactions(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.secondaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(6),
                  vertical: SizeConstants.height(1.5),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  textStyle: TextStyles.buttonText(
                    size: SizeConstants.font(3.8),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(
          //   Icons.receipt_long_outlined,
          //   size: SizeConstants.font(8),
          //   color: Colors.grey,
          // ),
          // SizedBox(height: SizeConstants.height(2)),
          Text(
            'No transactions found for this category',
            style: GoogleFonts.poppins(
              textStyle: TextStyles.bodyText(
                color: Colors.grey,
                size: SizeConstants.font(3.5),
                weight: FontWeight.w500,
              ),
            ),
          ),
          // SizedBox(height: SizeConstants.height(1)),
          // Text(
          //   'Start adding income or expenses to see them here',
          //   style: GoogleFonts.poppins(
          //     textStyle: TextStyles.smallText(
          //       color: Colors.grey,
          //       size: SizeConstants.font(3.5),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Separate widget for transaction items to improve performance
class _TransactionItem extends StatelessWidget {
  final dynamic item;
  final String category;
  final CategoryWiseListController controller;
  final int index;

  const _TransactionItem({
    required this.item,
    required this.category,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isSalary = category.toLowerCase() == 'salary';
    final expanded = controller.isExpanded(index);

    // Cache styles to avoid repeated GoogleFonts.resolve calls per sub-widget
    final titleStyle = GoogleFonts.poppins(
      textStyle: TextStyles.bodyText(
        size: SizeConstants.font(3.6),
        weight: FontWeight.w600,
      ),
    );
    final subtitleStyle = GoogleFonts.poppins(
      textStyle: TextStyles.smallText(
        size: SizeConstants.font(2.8),
        color: ColorTheme.secondaryColor,
      ),
    );
    final amountStyleIncome = GoogleFonts.poppins(
      textStyle: TextStyles.bodyText(
        color: Colors.green,
        size: SizeConstants.font(3.6),
        weight: FontWeight.w700,
      ),
    );
    final amountStyleExpense = GoogleFonts.poppins(
      textStyle: TextStyles.bodyText(
        color: ColorTheme.secondaryColor,
        size: SizeConstants.font(3.6),
        weight: FontWeight.w700,
      ),
    );

    return Dismissible(
      key: Key(
        'transaction_${item.title}_${item.amount}_${item.dateTime.millisecondsSinceEpoch}',
      ),
      direction: DismissDirection.horizontal,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: SizeConstants.width(5)),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: SizeConstants.font(5),
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: ColorTheme.secondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: SizeConstants.width(5)),
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: SizeConstants.font(5),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Delete action
          return await _showDeleteConfirmation(context);
        } else if (direction == DismissDirection.endToStart) {
          // Edit action
          _showEditDialog(context);
          return false; // Don't dismiss, just show edit dialog
        }
        return false;
      },
      onDismissed: (direction) async {
        // This will only be called if confirmDismiss returns true
        // The actual deletion is handled in _showDeleteConfirmation
        print('Transaction dismissed: $direction');
        // Remove the item from the controller's list to update UI
        controller.removeItem(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConstants.width(4),
          vertical: SizeConstants.height(1.2),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: SizeConstants.width(10),
                  height: SizeConstants.width(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: ColorTheme.secondaryColor,
                    size: SizeConstants.font(4),
                  ),
                ),
                SizedBox(width: SizeConstants.width(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.isIncome ? '' : ' '}${item.title}',
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SizeConstants.height(0.3)),
                      Text(
                        item.subCategory?.isNotEmpty == true
                            ? item.subCategory!
                            : _formatDate(item.dateTime),
                        style: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.amount >= 0 ? '+' : ''}₹${item.amount.abs().toStringAsFixed(2)}',
                  style: item.amount >= 0
                      ? amountStyleIncome
                      : amountStyleExpense,
                ),
                if (isSalary) ...[
                  SizedBox(width: SizeConstants.width(1)),
                  GestureDetector(
                    onTap: () => controller.toggleExpanded(index),
                    child: Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: ColorTheme.secondaryColor,
                    ),
                  ),
                ],
              ],
            ),
            if (isSalary && expanded) ...[
              SizedBox(height: SizeConstants.height(1.2)),
              if (item.subCategory?.isNotEmpty ?? false)
                _personRow(item.subCategory!, (item.amount * 0.11).abs()),
              if (item.subtitle.isNotEmpty)
                _personRow(item.subtitle, (item.amount * 0.10).abs()),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Transaction'),
            content: Text(
              'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await _deleteTransaction(context);
    }

    return confirmed;
  }

  void _showEditDialog(BuildContext context) {
    print('Edit dialog - Item title: ${item.title}, Amount: ${item.amount}');
    print('Available API transactions: ${controller.apiTransactions.length}');

    // Find the corresponding API transaction by matching sub-transactions
    transaction_repo.Transaction? apiTransaction;
    int? subTransactionIndex;
    String? subTransactionId;

    // Try to find the exact transaction and sub-transaction index
    for (var transaction in controller.apiTransactions) {
      for (int i = 0; i < transaction.subTransactions.length; i++) {
        final sub = transaction.subTransactions[i];

        // Match by name and amount
        if (sub.name == item.title && sub.amount == item.amount) {
          // Parse the sub-transaction date/time for verification
          final subDateTime = _parseDateTime(sub.date, sub.time);
          final dateTimeMatch =
              subDateTime.year == item.dateTime.year &&
              subDateTime.month == item.dateTime.month &&
              subDateTime.day == item.dateTime.day &&
              subDateTime.hour == item.dateTime.hour &&
              subDateTime.minute == item.dateTime.minute;

          if (dateTimeMatch) {
            // Perfect match - found it!
            apiTransaction = transaction;
            subTransactionIndex = i;
            subTransactionId = sub.id;
            break;
          } else if (apiTransaction == null) {
            // Partial match - save as fallback
            apiTransaction = transaction;
            subTransactionIndex = i;
            subTransactionId = sub.id;
          }
        }
      }
      if (apiTransaction != null &&
          subTransactionIndex != null &&
          subTransactionId != null) {
        break; // Found perfect match
      }
    }

    if (apiTransaction == null) {
      apiTransaction = controller.apiTransactions.first;
    }

    print('Found API transaction: ${apiTransaction.id}');
    print('Sub-transactions count: ${apiTransaction.subTransactions.length}');
    print('Found sub-transaction index: $subTransactionIndex');
    print('Found sub-transaction ID: $subTransactionId');

    // Enhanced debugging for sub-transaction matching
    print('=== SUB-TRANSACTION MATCHING DEBUG ===');
    print('Looking for sub-transaction with:');
    print('  Item title: "${item.title}"');
    print('  Item amount: ${item.amount}');
    print('Available sub-transactions:');

    for (int i = 0; i < apiTransaction.subTransactions.length; i++) {
      final sub = apiTransaction.subTransactions[i];
      print('  [$i] Name: "${sub.name}", Amount: ${sub.amount}, ID: ${sub.id}');

      final nameMatch = sub.name == item.title;
      final amountMatch = sub.amount == item.amount;
      print('    Name match: $nameMatch, Amount match: $amountMatch');
    }
    print('=====================================');

    if (subTransactionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate that the index is within bounds
    if (subTransactionIndex < 0 ||
        subTransactionIndex >= apiTransaction.subTransactions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid sub-transaction index. Please refresh and try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Trigger a refresh
      controller.refreshData();
      return;
    }

    print(
      'Edit dialog values - Name: ${item.title}, Amount: ${item.amount}, Date: ${item.dateTime}, Time: ${_formatTime(item.dateTime)}, Description: ${item.subCategory}',
    );

    showDialog(
      context: context,
      builder: (context) => EditSubTransactionDialog(
        name: item.title,
        amount: item.amount,
        date: item.dateTime,
        time: _formatTime(item.dateTime),
        description: item.subCategory ?? '',
        onSave: (name, amount, date, time, description) async {
          if (subTransactionIndex == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transaction index not found'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final success = await controller.updateSubTransaction(
            transactionId: apiTransaction!.id,
            subTransactionIndex: subTransactionIndex,
            name: name,
            amount: amount,
            date: date,
            time: time,
            description: description,
          );

          if (success && context.mounted) {
            // Close dialog first - safely check if we can pop
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sub-transaction updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Data is already refreshed in the controller
          } else if (controller.errorMessage != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onDelete: () async {
          if (subTransactionIndex == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction index not found'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          try {
            final success = await controller.deleteSubTransaction(
              transactionId: apiTransaction!.id,
              subTransactionIndex: subTransactionIndex,
            );

            // Wait for refresh to complete before showing message
            await Future.delayed(Duration(milliseconds: 400));

            if (context.mounted) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.title} deleted successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (controller.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting transaction: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Re-throw to let dialog know delete failed
            rethrow;
          }
        },
      ),
    );
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    print(
      'Delete transaction - Item title: ${item.title}, Amount: ${item.amount}',
    );
    print('Available API transactions: ${controller.apiTransactions.length}');

    // Find the corresponding API transaction by matching sub-transactions
    transaction_repo.Transaction? apiTransaction;
    int? subTransactionIndex;
    String? subTransactionId;

    // Try to find the exact transaction and sub-transaction index
    for (var transaction in controller.apiTransactions) {
      for (int i = 0; i < transaction.subTransactions.length; i++) {
        final sub = transaction.subTransactions[i];

        // Match by name and amount
        if (sub.name == item.title && sub.amount == item.amount) {
          // Parse the sub-transaction date/time for verification
          final subDateTime = _parseDateTime(sub.date, sub.time);
          final dateTimeMatch =
              subDateTime.year == item.dateTime.year &&
              subDateTime.month == item.dateTime.month &&
              subDateTime.day == item.dateTime.day &&
              subDateTime.hour == item.dateTime.hour &&
              subDateTime.minute == item.dateTime.minute;

          if (dateTimeMatch) {
            // Perfect match - found it!
            apiTransaction = transaction;
            subTransactionIndex = i;
            subTransactionId = sub.id;
            break;
          } else if (apiTransaction == null) {
            // Partial match - save as fallback
            apiTransaction = transaction;
            subTransactionIndex = i;
            subTransactionId = sub.id;
          }
        }
      }
      if (apiTransaction != null &&
          subTransactionIndex != null &&
          subTransactionId != null) {
        break; // Found perfect match
      }
    }

    if (apiTransaction == null) {
      apiTransaction = controller.apiTransactions.first;
    }

    print('Found API transaction: ${apiTransaction.id}');
    print('Sub-transactions count: ${apiTransaction.subTransactions.length}');
    print('Found sub-transaction index: $subTransactionIndex');
    print('Found sub-transaction ID: $subTransactionId');

    if (subTransactionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate that the index is within bounds
    if (subTransactionIndex < 0 ||
        subTransactionIndex >= apiTransaction.subTransactions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid sub-transaction index. Please refresh and try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Trigger a refresh
      controller.refreshData();
      return;
    }

    final success = await controller.deleteSubTransaction(
      transactionId: apiTransaction.id,
      subTransactionIndex: subTransactionIndex,
    );

    if (success) {
      // Force UI refresh and manual data refresh
      controller.forceRefresh();
      // Trigger a manual refresh to ensure latest data is loaded
      await controller.refreshData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.title} Sub-transaction deleted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (controller.errorMessage != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      // Parse date like "October 8, 2025"
      final dateParts = dateStr.split(' ');
      final monthStr = dateParts[0];
      final dayStr = dateParts[1].replaceAll(',', '');
      final yearStr = dateParts[2];

      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final month = months.indexOf(monthStr) + 1;
      final day = int.parse(dayStr);
      final year = int.parse(yearStr);

      // Parse time like "10:38 AM"
      final timeParts = timeStr.split(' ');
      final timeStrParts = timeParts[0].split(':');
      var hour = int.parse(timeStrParts[0]);
      final minute = int.parse(timeStrParts[1]);
      final period = timeParts.length > 1 ? timeParts[1] : 'AM';

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDate(DateTime d) {
    return '${_twoDigits(d.hour)}:${_twoDigits(d.minute)} - ${_month(d.month)} ${d.day}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _month(int m) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[m - 1];
  }

  Widget _personRow(String name, double amount) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: SizeConstants.height(0.6)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  textStyle: TextStyles.bodyText(
                    size: SizeConstants.font(3.2),
                    color: const Color(0xFF87CEEB),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  textStyle: TextStyles.bodyText(
                    size: SizeConstants.font(3.2),
                    color: const Color(0xFF87CEEB),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.blue.withOpacity(0.3)),
      ],
    );
  }
}

// Shimmer utilities (no external dependency)
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final double shimmerWidth = rect.width / 2;
            final double dx =
                (rect.width + shimmerWidth) * _controller.value - shimmerWidth;
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.1, 0.3, 0.4],
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              transform: GradientTranslation(dx, 0),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class GradientTranslation extends GradientTransform {
  final double dx;
  final double dy;
  const GradientTranslation(this.dx, this.dy);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.identity()..translate(dx, dy);
  }
}

Widget _buildShimmerLoading() {
  return Container(
    decoration: const BoxDecoration(
      color: Color(0xFFF0F8F0),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    ),
    child: ListView.separated(
      padding: EdgeInsets.all(SizeConstants.width(5)),
      itemCount: 8,
      separatorBuilder: (_, __) => SizedBox(height: SizeConstants.height(1.2)),
      itemBuilder: (context, index) {
        return _Shimmer(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(4),
              vertical: SizeConstants.height(1.2),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: SizeConstants.width(10),
                  height: SizeConstants.width(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                SizedBox(width: SizeConstants.width(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: SizeConstants.height(2.4),
                        width: double.infinity,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: SizeConstants.height(0.8)),
                      Container(
                        height: SizeConstants.height(1.8),
                        width: SizeConstants.width(30),
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SizeConstants.width(3)),
                Container(
                  height: SizeConstants.height(2.2),
                  width: SizeConstants.width(18),
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
