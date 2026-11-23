import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';
import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';
import 'package:monaymanagment/presentation/categories/category_wise_expense_list_screen/view/category_wise_expense_list_screen.dart';
import 'package:monaymanagment/presentation/categories/category_screen/widgets/add_category_dialog.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    // Get the singleton controller instance
    final controller = CategoryController();

    // Only load data if not already loaded
    final shouldReload =
        controller.needsModeReload ||
        (!controller.isDataLoaded && !controller.isLoading);
    if (shouldReload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadCategories(forceReload: controller.needsModeReload);
      });
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Categories',
            showBackButton: false,
            showNotification: true,
            showProfileAvatar: true,
            customActions: [
              // IconButton(
              //   icon: const Icon(Icons.refresh),
              //   color: Colors.white,
              //   tooltip: 'Refresh categories',
              //   onPressed: () => controller.refreshData(),
              // ),
              SizedBox(width: SizeConstants.width(2)),
            ],
            // profileImageUrl: controller.userProfileImage,
            // backgroundColor: ColorTheme.secondaryColor,
            // leading: IconButton(
            //       onPressed: () => Navigator.pop(context),
            //       constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            //       padding: EdgeInsets.zero,
            //       icon: Icon(
            //         Icons.arrow_back_ios,
            //         color: Colors.white,
            //         size: SizeConstants.width(3.5),
            //       ),
            //     ),
            // centerTitle: true,
            // title: Text(
            //         'Categories',
            //         textAlign: TextAlign.center,
            //         style: TextStyles.bodyText(
            //           color: Colors.white,
            //           size: SizeConstants.font(4.5),
            //           weight: FontWeight.bold,
            //         ),
            //       ),
            // actions: [
            //   NotificationIconButton(
            //     iconColor: Colors.white,
            //     iconSize: SizeConstants.font(6),
            //     showBadge: true,
            //     badgeCount: 5,
            //   ),
            //   SizedBox(width: SizeConstants.width(2)),
            // ],
          ),
          backgroundColor: ColorTheme.secondaryColor,
          body: SafeArea(child: _buildBody(controller)),
          //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          //floatingActionButton: _buildFloatingActionButtons(context, controller),
        );
      },
    );
  }

  Widget _buildBody(CategoryController controller) {
    // Show loading only if no data is loaded yet
    if (controller.isLoading && !controller.isDataLoaded) {
      return _buildLoadingState();
    }

    // Show error only if no data is loaded and there's an error
    if (controller.errorMessage != null && !controller.isDataLoaded) {
      return _buildErrorState(controller.errorMessage!, controller);
    }

    // Show the main content (even if loading in background)
    return Column(
      children: [
        // Balance Overview Section
        _buildBalanceOverview(controller),
        // Category Grid
        Expanded(child: _buildCategoryGrid(controller)),
      ],
    );
  }

  Widget _buildBalanceOverview(CategoryController controller) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          children: [
            // Balance and Expense Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: SizeConstants.width(6),
                            height: SizeConstants.width(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: ColorTheme.secondaryColor,
                              size: SizeConstants.font(3),
                            ),
                          ),
                          SizedBox(width: SizeConstants.width(2)),
                          Text(
                            'Total Balance',
                            style: TextStyles.smallText(
                              color: Colors.white,
                              size: SizeConstants.font(3.2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConstants.height(0.5)),
                      controller.isLoadingTransactions
                          ? Container(
                              width: SizeConstants.width(25),
                              height: SizeConstants.height(2.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                          : Text(
                              '₹${controller.totalBalance.toStringAsFixed(2)}',
                              style: TextStyles.bodyText(
                                color: Colors.white,
                                size: SizeConstants.font(4.5),
                                weight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: SizeConstants.height(6),
                  color: Colors.white,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total Expense',
                            style: TextStyles.smallText(
                              color: Colors.white,
                              size: SizeConstants.font(3.2),
                            ),
                          ),
                          SizedBox(width: SizeConstants.width(2)),
                          Container(
                            width: SizeConstants.width(6),
                            height: SizeConstants.width(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.trending_down,
                              color: ColorTheme.secondaryColor,
                              size: SizeConstants.font(3),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConstants.height(0.5)),
                      controller.isLoadingTransactions
                          ? Container(
                              width: SizeConstants.width(25),
                              height: SizeConstants.height(2.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                          : Text(
                              '₹${controller.totalExpense.toStringAsFixed(2)}',
                              style: TextStyles.bodyText(
                                color: const Color(0xFF87CEEB),
                                size: SizeConstants.font(4.5),
                                weight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConstants.height(3)),

            // Progress Bar Section
            // _buildProgressBar(controller),
            SizedBox(height: SizeConstants.height(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(CategoryController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: controller.isLoadingCategories && !controller.isDataLoaded
          ? _buildCategoryLoadingGrid()
          : Padding(
              padding: EdgeInsets.all(SizeConstants.width(5)),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1,
                ),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                addSemanticIndexes: false,
                cacheExtent: 500,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return _buildCategoryItem(
                    context,
                    category,
                    controller,
                    index,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCategoryLoadingGrid() {
    return Padding(
      padding: EdgeInsets.all(SizeConstants.width(5)),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
        ),
        itemCount: 9, // Show 9 skeleton items
        itemBuilder: (context, index) {
          return _Shimmer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: SizeConstants.font(6),
                    height: SizeConstants.font(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: SizeConstants.height(1)),
                  Container(
                    width: SizeConstants.width(15),
                    height: SizeConstants.height(1.5),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Category category,
    CategoryController controller,
    int index,
  ) {
    final isSelected = controller.isSelected(index);
    final isMoreButton = category.label == 'More';

    return GestureDetector(
      onTap: () {
        if (isMoreButton) {
          // Show Add Category Dialog
          showDialog(
            context: context,
            builder: (context) => AddCategoryDialog(
              onSave: (name, icon) async {
                final success = await controller.createCategory(name, icon);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category added successfully!'),
                      backgroundColor: Colors.green,
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
              },
            ),
          );
        } else {
          controller.selectCategory(index);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryWiseExpenseListScreen(
                category: category.label,
                categoryIcon: category.icon,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? ColorTheme.secondaryColor
              : ColorTheme
                    .mainColor2, // Light blue background like in the image
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: SizeConstants.width(12),
                height: SizeConstants.width(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    color: isSelected
                        ? ColorTheme.secondaryColor
                        : ColorTheme
                              .secondaryColor, // Dark blue icon color like in the image
                    size: SizeConstants.font(6),
                  ),
                ),
              ),
              SizedBox(height: SizeConstants.height(1)),
              Text(
                category.label,
                style: TextStyles.smallText(
                  color: isSelected
                      ? ColorTheme.mainColor2
                      : ColorTheme.mainColor, // White text like in the image
                  size: SizeConstants.font(3),
                  weight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Loading Balance Overview
        Container(
          decoration: BoxDecoration(
            color: ColorTheme.secondaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(SizeConstants.width(5)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: SizeConstants.width(6),
                                height: SizeConstants.width(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              SizedBox(width: SizeConstants.width(2)),
                              Container(
                                width: SizeConstants.width(20),
                                height: SizeConstants.height(2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConstants.height(1)),
                          Container(
                            width: SizeConstants.width(25),
                            height: SizeConstants.height(2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: SizeConstants.height(6),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: SizeConstants.width(20),
                                height: SizeConstants.height(2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              SizedBox(width: SizeConstants.width(2)),
                              Container(
                                width: SizeConstants.width(6),
                                height: SizeConstants.width(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConstants.height(1)),
                          Container(
                            width: SizeConstants.width(25),
                            height: SizeConstants.height(2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConstants.height(3)),
              ],
            ),
          ),
        ),

        // Loading Category Grid
        Expanded(
          child: Container(
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
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorTheme.secondaryColor,
                    ),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: SizeConstants.height(2)),
                  Text(
                    'Loading data...',
                    style: TextStyles.bodyText(
                      color: ColorTheme.secondaryColor,
                      size: SizeConstants.font(4),
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, CategoryController controller) {
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
            Icon(
              Icons.error_outline,
              size: SizeConstants.font(12),
              color: Colors.red,
            ),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'Error loading data',
              style: TextStyles.bodyText(
                color: Colors.red,
                size: SizeConstants.font(4.5),
                weight: FontWeight.w600,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Text(
              error,
              style: TextStyles.smallText(
                color: Colors.grey,
                size: SizeConstants.font(3.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConstants.height(3)),
            ElevatedButton(
              onPressed: () => controller.loadCategories(),
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
                style: TextStyles.buttonText(
                  size: SizeConstants.font(3.8),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildFloatingActionButtons(BuildContext context, CategoryController controller) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: SizeConstants.width(4)),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         // Add Income Button
  //         Expanded(
  //           child: Container(
  //             height: SizeConstants.height(6),
  //             margin: EdgeInsets.only(right: SizeConstants.width(2)),
  //             child: ElevatedButton(
  //               onPressed: controller.isLoading ? null : () async {
  //                 final result = await Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => ExpenseAddingScreen(
  //                       categories: const ['Add More'],
  //                       isIncome: true,
  //                     ),
  //                   ),
  //                 );
  //                 if (result == true) {
  //                   controller.refreshData();
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: ColorTheme.secondaryColor,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(SizeConstants.width(8)),
  //                 ),
  //                 elevation: 4,
  //               ),
  //               child: controller.isLoading
  //                   ? SizedBox(
  //                       width: SizeConstants.width(4),
  //                       height: SizeConstants.width(4),
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                       ),
  //                     )
  //                   : Text(
  //                       'Add Income',
  //                       style: TextStyles.buttonText(
  //                         size: SizeConstants.font(3.6),
  //                         color: Colors.white,
  //                         weight: FontWeight.w600,
  //                       ),
  //                     ),
  //             ),
  //           ),
  //         ),

  //         // Add Expenses Button
  //         Expanded(
  //           child: Container(
  //             height: SizeConstants.height(6),
  //             margin: EdgeInsets.only(left: SizeConstants.width(2)),
  //             child: ElevatedButton(
  //               onPressed: controller.isLoading ? null : () async {
  //                 final result = await Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => ExpenseAddingScreen(
  //                       categories: const ['Food','Transport','Medicine','Groceries','Salary','Gifts','Savings','Entertainment','More'],
  //                       isIncome: false,
  //                     ),
  //                   ),
  //                 );
  //                 if (result == true) {
  //                   controller.refreshData();
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: ColorTheme.secondaryColor,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(SizeConstants.width(8)),
  //                 ),
  //                 elevation: 4,
  //               ),
  //               child: controller.isLoading
  //                   ? SizedBox(
  //                       width: SizeConstants.width(4),
  //                       height: SizeConstants.width(4),
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                       ),
  //                     )
  //                   : Text(
  //                       'Add Expenses',
  //                       style: TextStyles.buttonText(
  //                         size: SizeConstants.font(3.6),
  //                         color: Colors.white,
  //                         weight: FontWeight.w600,
  //                       ),
  //                     ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
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
