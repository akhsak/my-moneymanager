import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/controller/loan_controller.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/controller/loan_form_controller.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';

class PayLoanScreen extends StatelessWidget {
  const PayLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoanFormController()),
        ChangeNotifierProvider.value(value: Provider.of<LoanController>(context, listen: false)),
      ],
      child: Consumer2<LoanFormController, LoanController>(
        builder: (context, formController, loanController, _) {
          // Initialize form for payment only once
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (formController.amountController.text.isEmpty && 
                formController.paymentNoteController.text.isEmpty &&
                formController.selectedLoan == null) {
              formController.initializeForPayment();
            }
          });
          
          return Scaffold(
            backgroundColor: ColorTheme.secondaryColor,
            body: Column(
              children: [
                // Header Section
                _buildHeader(context),
                // Main Content with curved shape
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8F0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(SizeConstants.width(8)),
                        topRight: Radius.circular(SizeConstants.width(8)),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(SizeConstants.width(4)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Form Card
                          _buildFormCard(context, formController, loanController),
                          SizedBox(height: SizeConstants.height(2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.secondaryColor,
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
                      'Pay Loan',
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyText(
                        color: Colors.white,
                        size: SizeConstants.font(5),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, LoanFormController formController, LoanController loanController) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      padding: EdgeInsets.all(SizeConstants.width(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Select Loan Field
          _buildFieldLabel('Select Loan'),
          SizedBox(height: SizeConstants.height(1)),
          _buildLoanDropdown(context, formController, loanController),
          SizedBox(height: SizeConstants.height(2)),
          
          // Amount Field
          _buildFieldLabel('Amount (₹)'),
          SizedBox(height: SizeConstants.height(1)),
          _buildAmountTextField(
            controller: formController.amountController,
            hintText: 'Enter amount',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: SizeConstants.height(2)),
          
          // Date Field
          _buildFieldLabel('Date'),
          SizedBox(height: SizeConstants.height(1)),
          _buildDateField(context, formController),
          SizedBox(height: SizeConstants.height(2)),
          
          // Note Field
          _buildFieldLabel('Note'),
          SizedBox(height: SizeConstants.height(1)),
          _buildTextField(
            controller: formController.paymentNoteController,
            hintText: 'Optional',
            maxLines: 2,
          ),
          SizedBox(height: SizeConstants.height(3)),
          
          // Error Message
          if (formController.errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeConstants.width(2.5)),
              margin: EdgeInsets.only(bottom: SizeConstants.height(1.5)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                formController.errorMessage!,
                style: TextStyles.smallText(
                  color: Colors.red,
                  size: SizeConstants.font(3),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Add Payment Button
          Center(
            child: SizedBox(
              width: double.infinity,
              height: SizeConstants.height(5.5),
              child: ElevatedButton(
                onPressed: formController.isLoading ? null : () => _addPayment(context, formController, loanController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConstants.width(3)),
                  ),
                ),
                child: formController.isLoading
                    ? SizedBox(
                        width: SizeConstants.width(3),
                        height: SizeConstants.width(3),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Add Payment',
                        style: TextStyles.buttonText(
                          color: Colors.white,
                          size: SizeConstants.font(3.2),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyles.smallText(
        color: ColorTheme.mainColor,
        size: SizeConstants.font(3.5),
        weight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.width(4),
        vertical: SizeConstants.height(1),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyles.smallText(
          color: ColorTheme.mainColor,
          size: SizeConstants.font(3),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyles.smallText(
            color: Colors.grey[500],
            size: SizeConstants.font(3),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.width(4),
        vertical: SizeConstants.height(1),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
        border: Border.all(
          color: ColorTheme.secondaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            '₹',
            style: TextStyles.bodyText(
              color: ColorTheme.mainColor,
              size: SizeConstants.font(3.5),
              weight: FontWeight.bold,
            ),
          ),
          SizedBox(width: SizeConstants.width(1)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyles.bodyText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(3.5),
                weight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyles.smallText(
                  color: Colors.grey[500],
                  size: SizeConstants.font(3),
                ),
              ),
              inputFormatters: [
                // Allow only numbers and decimal point
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDropdown(BuildContext context, LoanFormController formController, LoanController loanController) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.width(4),
        vertical: SizeConstants.height(0.5),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(SizeConstants.width(3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: formController.selectedLoan,
          hint: Text(
            'Choose...',
            style: TextStyles.smallText(
              color: Colors.grey[500],
              size: SizeConstants.font(3),
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: ColorTheme.secondaryColor,
            size: SizeConstants.width(5),
          ),
          items: loanController.loans.map((loan) {
            return DropdownMenuItem<dynamic>(
              value: loan,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loan.name,
                    style: TextStyles.smallText(
                      color: ColorTheme.mainColor,
                      size: SizeConstants.font(3),
                      weight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Balance: ₹${loan.balanceToPay.toStringAsFixed(0)}',
                    style: TextStyles.smallText(
                      color: Colors.grey[600],
                      size: SizeConstants.font(2.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (dynamic value) {
            formController.setSelectedLoan(value);
          },
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, LoanFormController formController) {
    return GestureDetector(
      onTap: () => _selectDate(context, formController),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConstants.width(4),
          vertical: SizeConstants.height(1),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(SizeConstants.width(3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${formController.paymentDate.day.toString().padLeft(2, '0')}/${formController.paymentDate.month.toString().padLeft(2, '0')}/${formController.paymentDate.year}',
              style: TextStyles.smallText(
                color: ColorTheme.mainColor,
                size: SizeConstants.font(3),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: ColorTheme.secondaryColor,
              size: SizeConstants.width(3.5),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _selectDate(BuildContext context, LoanFormController formController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: formController.paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != formController.paymentDate) {
      formController.setPaymentDate(picked);
    }
  }

  Future<void> _addPayment(BuildContext context, LoanFormController formController, LoanController loanController) async {
    formController.clearError();
    
    final success = await formController.addPayment();

    if (success) {
      // Refresh the loan list
      await loanController.refresh();
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Error is already set in the controller
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formController.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
