import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/repository/target/model/target_model.dart';
import 'package:monaymanagment/repository/target/service/target_service.dart';


class AllTargetsScreen extends StatelessWidget {
  const AllTargetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
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
          'All Targets',
          style: TextStyles.bodyText(
            color: Colors.white,
            size: SizeConstants.font(4.5),
            weight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: FutureBuilder<TargetListResponse>(
          future: TargetService().getTargets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }
            
            if (!snapshot.hasData || snapshot.data!.targets.isEmpty) {
              return _buildEmptyState();
            }
            
            return _buildTargetsList(snapshot.data!.targets);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColorTheme.secondaryColor,
            strokeWidth: 3,
          ),
          SizedBox(height: SizeConstants.height(2)),
          Text(
            'Loading targets...',
            style: TextStyles.bodyText(
              color: ColorTheme.mainColor,
              size: SizeConstants.font(3.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: SizeConstants.width(15),
              color: Colors.red[400],
            ),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'Failed to load targets',
              style: TextStyles.bodyText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(4),
                weight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Text(
              error,
              style: TextStyles.smallText(
                color: Colors.grey[600],
                size: SizeConstants.font(3),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConstants.height(3)),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  // Trigger rebuild by popping and pushing again
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllTargetsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConstants.width(3)),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyles.buttonText(
                    size: SizeConstants.font(3.5),
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
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: SizeConstants.width(20),
              color: Colors.grey[400],
            ),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'No targets set',
              style: TextStyles.bodyText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(4),
                weight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Text(
              'Create your first target to start tracking your financial goals',
              style: TextStyles.smallText(
                color: Colors.grey[600],
                size: SizeConstants.font(3.2),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConstants.height(3)),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConstants.width(3)),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyles.buttonText(
                    size: SizeConstants.font(3.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetsList(List<Target> targets) {
    return Padding(
      padding: EdgeInsets.all(SizeConstants.width(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Targets (${targets.length})',
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor,
                  size: SizeConstants.font(4.5),
                  weight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(3),
                  vertical: SizeConstants.height(0.5),
                ),
                decoration: BoxDecoration(
                  color: ColorTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
                child: Text(
                  '${targets.length} targets',
                  style: TextStyles.smallText(
                    color: ColorTheme.secondaryColor,
                    size: SizeConstants.font(3),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConstants.height(3)),
          
          // Targets Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: SizeConstants.width(2),
                mainAxisSpacing: SizeConstants.height(0.5),
                childAspectRatio: 1.0,
              ),
              itemCount: targets.length,
              itemBuilder: (context, index) {
                final target = targets[index];
                return _buildTargetCard(target);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard(Target target) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConstants.height(0.5)),
      padding: EdgeInsets.all(SizeConstants.width(2.5)),
      decoration: BoxDecoration(
        color: ColorTheme.targetBlue,
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Progress Indicator
          Container(
            width: SizeConstants.width(16),
            height: SizeConstants.width(16),
            child: Stack(
              children: [
                // Background Circle
                Container(
                  width: SizeConstants.width(16),
                  height: SizeConstants.width(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorTheme.mainColor2,
                      width: SizeConstants.width(0.8),
                    ),
                  ),
                ),
                // Progress Circle
                SizedBox(
                  width: SizeConstants.width(16),
                  height: SizeConstants.width(16),
                  child: CircularProgressIndicator(
                    value: target.progressPercentage / 100,
                    strokeWidth: SizeConstants.width(0.8),
                    backgroundColor: ColorTheme.mainColor2,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorTheme.targetBlue),
                  ),
                ),
                // Percentage Text
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${target.progressPercentage.toInt()}%',
                      style: TextStyles.bodyText(
                        color: ColorTheme.mainColor2,
                        size: SizeConstants.font(3.5),
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: SizeConstants.height(1)),
          
          // Category Name
          Text(
            target.category,
            style: TextStyles.bodyText(
              color: Colors.white,
              size: SizeConstants.font(3),
              weight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: SizeConstants.height(0.3)),
          
          // Amount
          Text(
            '₹${target.amount.toStringAsFixed(0)}',
            style: TextStyles.smallText(
              color: Colors.white.withOpacity(0.8),
              size: SizeConstants.font(2.5),
            ),
          ),
          
          SizedBox(height: SizeConstants.height(0.2)),
          
          // Progress Text
          Text(
            '₹${target.savedAmount.toStringAsFixed(0)} saved',
            style: TextStyles.smallText(
              color: Colors.white.withOpacity(0.7),
              size: SizeConstants.font(2),
            ),
          ),
        ],
      ),
    );
  }
}
