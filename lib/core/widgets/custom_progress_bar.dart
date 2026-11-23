import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';

class CustomProgressBar extends StatelessWidget {
  final double progressPercentage;
  final double targetAmount;
  final double? barHeight;
  final Color? trackColor;
  final Color? fillColor;
  final Color? percentageTextColor;
  final Color? amountTextColor;
  final String? currencySymbol;
  final bool showAmount;

  const CustomProgressBar({
    super.key,
    required this.progressPercentage,
    required this.targetAmount,
    this.barHeight,
    this.trackColor,
    this.fillColor,
    this.percentageTextColor,
    this.amountTextColor,
    this.currencySymbol,
    this.showAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    final double height = barHeight ?? SizeConstants.height(5);
    final Color track = trackColor ?? const Color(0xFFEFF9F3); // mint light
    final Color fill = fillColor ?? const Color(0xFF082C2C); // dark teal
    final Color percentageColor = percentageTextColor ?? Colors.white;
    final Color amountColor = amountTextColor ?? fill;
    final String currency = currencySymbol ?? '₹';

    final double progress = (progressPercentage / 100).clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Bordered rounded track
          Container(
            height: height,
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: Colors.white.withOpacity(0.85),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: height,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(fill),
              ),
            ),
          ),
          // Overlay texts
          if (showAmount)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConstants.width(2.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progressPercentage.toInt()}%',
                      style: TextStyles.bodyText(
                        color: percentageColor,
                        size: SizeConstants.font(3.5),
                        weight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '$currency${targetAmount.toStringAsFixed(2)}',
                        style: TextStyles.bodyText(
                          color: amountColor,
                          size: SizeConstants.font(3.5),
                          weight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Percentage positioned on the left side
            Positioned(
              left: SizeConstants.width(2.5),
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '${progressPercentage.toInt()}%',
                  style: TextStyles.bodyText(
                    color: percentageColor,
                    size: SizeConstants.font(3.5),
                    weight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
