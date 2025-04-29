
import 'package:flutter/material.dart';
import 'package:meter_app/config/constants/colors.dart';

class AuthFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final bool isError;
  final String? errorMessage;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool isIconVisible;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  bool isPassword;

  AuthFormField({
    super.key,
    this.labelText,
    required this.hintText,
    this.isError = false,
    this.errorMessage,
    this.validator,
    this.onChanged,
    this.isIconVisible = false,
    required this.controller,
    required this.keyboardType,
    required this.isPassword,
  });

  @override
  _AuthFormFieldState createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    _obscureText = widget.isPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            filled: true,
            fillColor: AppColors.greyFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: widget.isError ? Colors.red : Colors.grey,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: widget.isError ? Colors.red : Colors.blue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: AppColors.errorGeneralColor,
                width: 1.5,
              ),
            ),
            suffixIcon: Visibility(
              visible: widget.isIconVisible,
              child: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: widget.isError ? AppColors.errorGeneralColor : AppColors.greyTextColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                    widget.isPassword = _obscureText;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.0),
    /*    if (widget.isError && widget.errorMessage != null)
          Text(
            widget.errorMessage!,
            style: const TextStyle(
              color: AppColors.errorGeneralColor,
              fontSize: 10.0,
            ),
          )
        else
          const Text(
            'Utiliza un mínimo de 8 caracteres.',
            style: TextStyle(
              color: AppColors.greyTextColor,
              fontSize: 10.0,
              fontWeight: FontWeight.w500
            ),
          ),*/
      ],
    );
  }
}
