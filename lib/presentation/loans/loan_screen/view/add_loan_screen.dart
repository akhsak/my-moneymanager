import 'package:flutter/material.dart';
import 'package:monaymanagment/repository/loan/model/loan_model.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/controller/loan_controller.dart';
import 'package:monaymanagment/presentation/loans/loan_screen/controller/loan_form_controller.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';

class AddLoanScreen extends StatelessWidget {
  final Loan? existingLoan;
  final bool isEditing;

  const AddLoanScreen({
    super.key,
    this.existingLoan,
    this.isEditing = false,
  });

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
          // Initialize form if editing
          if (isEditing && existingLoan != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (formController.nameController.text.isEmpty) {
                formController.initializeForEdit(existingLoan!);
              }
            });
          } else if (!isEditing) {
            // Initialize form for adding new loan
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!formController.isAddingNewLoan && formController.nameController.text.isEmpty) {
                formController.initializeForAddLoan();
              }
            });
          }
          
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
                      padding: EdgeInsets.all(SizeConstants.width(5)),
                      child: Column(
                        children: [
                          // Form Card
                          _buildFormCard(context, formController, loanController),
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
                      isEditing ? 'Edit Loan' : 'Add Loan',
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
      padding: EdgeInsets.all(SizeConstants.width(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConstants.width(6)),
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
        children: [
          // Loan Name Field - Show dropdown for new loans, text field for editing
          _buildFieldLabel('Loan Name'),
          SizedBox(height: SizeConstants.height(1)),
          if (isEditing)
            _buildTextField(
              controller: formController.nameController,
              hintText: 'Home Loan',
            )
          else
            _buildLoanNameDropdown(context, formController, loanController),
          
          // Show text field when adding new loan
          if (!isEditing && formController.isAddingNewLoan) ...[
            SizedBox(height: SizeConstants.height(2)),
            _buildTextField(
              controller: formController.nameController,
              hintText: 'Enter new loan name',
            ),
          ],
          
          SizedBox(height: SizeConstants.height(3)),
          
          // Principal Amount Field
          _buildFieldLabel('Principal (₹)'),
          SizedBox(height: SizeConstants.height(1)),
          _buildTextField(
            controller: formController.principalController,
            hintText: '500000',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: SizeConstants.height(3)),
          
          // Deadline Field
          _buildFieldLabel('Deadline'),
          SizedBox(height: SizeConstants.height(1)),
          _buildDateField(context, formController),
          SizedBox(height: SizeConstants.height(3)),
          
          // Note Field
          _buildFieldLabel('Note'),
          SizedBox(height: SizeConstants.height(1)),
          _buildTextField(
            controller: formController.noteController,
            hintText: 'Optional',
            maxLines: 3,
          ),
          SizedBox(height: SizeConstants.height(4)),
          
          // Error Message
          if (formController.errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeConstants.width(3)),
              margin: EdgeInsets.only(bottom: SizeConstants.height(2)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                formController.errorMessage!,
                style: TextStyles.smallText(
                  color: Colors.red,
                  size: SizeConstants.font(3.2),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Save Button
          Center(
            child: SizedBox(
              width: SizeConstants.width(50),
              height: SizeConstants.height(6),
              child: ElevatedButton(
                onPressed: formController.isLoading ? null : () => _saveLoan(context, formController, loanController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                  ),
                ),
                child: formController.isLoading
                    ? SizedBox(
                        width: SizeConstants.width(4),
                        height: SizeConstants.width(4),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Loan' : 'Save Loan',
                        style: TextStyles.buttonText(
                          color: Colors.white,
                          size: SizeConstants.font(4),
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
        size: SizeConstants.font(3),
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
        horizontal: SizeConstants.width(2),
        vertical: SizeConstants.height(1),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(SizeConstants.width(2)),
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

  Widget _buildLoanNameDropdown(BuildContext context, LoanFormController formController, LoanController loanController) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConstants.width(2),
        vertical: SizeConstants.height(1),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(SizeConstants.width(2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: formController.isAddingNewLoan ? 'add_new' : (formController.selectedLoan?.id ?? null),
          hint: Text(
            'Select existing loan or add new',
            style: TextStyles.smallText(
              color: Colors.grey[500],
              size: SizeConstants.font(3),
            ),
          ),
          style: TextStyles.smallText(
            color: ColorTheme.mainColor,
            size: SizeConstants.font(3),
          ),
          isExpanded: true,
          items: [
            // Existing loans
            ...loanController.loans.map((loan) => DropdownMenuItem<String>(
              value: loan.id,
              child: Text(loan.name),
            )),
            // Add new option
            DropdownMenuItem<String>(
              value: 'add_new',
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    color: ColorTheme.secondaryColor,
                    size: SizeConstants.width(4),
                  ),
                  SizedBox(width: SizeConstants.width(2)),
                  Text(
                    'Add New Loan',
                    style: TextStyles.smallText(
                      color: ColorTheme.secondaryColor,
                      size: SizeConstants.font(3),
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (String? value) {
            if (value == 'add_new') {
              formController.setAddingNewLoan(true);
            } else if (value != null) {
              final selectedLoan = loanController.loans.firstWhere(
                (loan) => loan.id == value,
                orElse: () => loanController.loans.first,
              );
              formController.setSelectedLoanForEdit(selectedLoan);
            }
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
              formController.selectedDate != null
                  ? '${formController.selectedDate!.day.toString().padLeft(2, '0')}/${formController.selectedDate!.month.toString().padLeft(2, '0')}/${formController.selectedDate!.year}'
                  : 'dd/mm/yyyy',
              style: TextStyles.smallText(
                color: formController.selectedDate != null ? ColorTheme.mainColor : Colors.grey[500],
                size: SizeConstants.font(3),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: ColorTheme.secondaryColor,
              size: SizeConstants.width(5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, LoanFormController formController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: formController.selectedDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );
    
    if (picked != null && picked != formController.selectedDate) {
      formController.setSelectedDate(picked);
    }
  }

  Future<void> _saveLoan(BuildContext context, LoanFormController formController, LoanController loanController) async {
    formController.clearError();
    
    bool success = false;
    if (isEditing && existingLoan != null) {
      // Editing existing loan
      success = await formController.updateLoan(existingLoan!.id);
    } else if (formController.isAddingNewLoan) {
      // Creating new loan
      success = await formController.createLoan();
    } else if (formController.selectedLoan != null) {
      // Updating selected existing loan
      success = await formController.updateLoan(formController.selectedLoan!.id);
    } else {
      // Creating new loan (fallback)
      success = await formController.createLoan();
    }

    if (success) {
      // Refresh the loan list
      await loanController.refresh();
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Loan updated successfully!' : 'Loan added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
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
