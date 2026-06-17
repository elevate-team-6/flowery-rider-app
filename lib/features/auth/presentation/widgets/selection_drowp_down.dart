import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
      ),
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: Icon(Icons.keyboard_arrow_down_outlined,size: 30,color: AppColors.black30,),
    );
  }
}