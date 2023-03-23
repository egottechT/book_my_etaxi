import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberInput extends StatelessWidget {
  final ValueChanged<String> onValueChange;

  const PhoneNumberInput({
    super.key,
    required this.onValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InternationalPhoneNumberInput(
        cursorColor: Colors.black,
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DROPDOWN,
          trailingSpace: false,
        ),
        errorMessage: "Enter a valid phone number",
        maxLength: 12,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        textStyle: _textStyle,
        selectorTextStyle: _textStyle,
        initialValue: PhoneNumber(isoCode: 'IN'),
        selectorButtonOnErrorPadding: 16,
        spaceBetweenSelectorAndTextField: 0,
        inputDecoration: const InputDecoration(
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          label: Text("Mobile Number"),
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onInputChanged: (PhoneNumber value) {
          onValueChange(value.phoneNumber.toString());
        },
        countries: const ["IN","US","GB","NL","MR","SL","CG","SO"],
      ),
    );
  }

  TextStyle get _textStyle => const TextStyle(
    color: Colors.black,
    fontSize: 18,
  );
}