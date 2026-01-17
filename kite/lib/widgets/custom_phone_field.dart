import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kite/providers/custom_phone_provider.dart';
import 'package:provider/provider.dart';

class CustomPhoneField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final List<String> countryCodes;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextStyle? countryCodeStyle;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CustomPhoneField({
    super.key,
    this.hintText = 'Enter Mobile Number',
    this.labelText,
    this.countryCodes = const ['+1', '+92', '+44', '+91', '+61'],
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.borderRadius = 16.0,
    this.contentPadding,
    this.hintStyle,
    this.textStyle,
    this.countryCodeStyle,
    this.maxLength = 10,
    this.enabled = true,
    this.onChanged,
  });

  void _showCountryCodePicker(
    BuildContext context,
    PhoneFieldProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Country Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...countryCodes.map(
              (code) => ListTile(
                leading: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                title: Text(_getCountryName(code)),
                trailing: provider.countryCode == code
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  provider.setCountryCode(code);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCountryName(String code) {
    switch (code) {
      case '+1':
        return 'United States';
      case '+92':
        return 'Pakistan';
      case '+44':
        return 'United Kingdom';
      case '+91':
        return 'India';
      case '+61':
        return 'Australia';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhoneFieldProvider>(
      builder: (context, provider, child) {
        final borderColor = this.borderColor ?? Colors.grey.shade300;

        final fillColor = this.fillColor ?? Colors.white;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelText != null) ...[
              Text(
                labelText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                color: enabled ? fillColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: enabled
                        ? () => _showCountryCodePicker(context, provider)
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                    child: Container(
                      padding:
                          contentPadding ??
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: borderColor, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.countryCode,
                            style:
                                countryCodeStyle ??
                                const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),

                  // Phone number input
                  Expanded(
                    child: Focus(
                      onFocusChange: (focused) {
                        provider.setFocusState(focused);
                      },
                      child: TextField(
                        controller: provider.controller,
                        enabled: enabled,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          if (maxLength != null)
                            LengthLimitingTextInputFormatter(maxLength),
                        ],
                        onChanged: onChanged,
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle:
                              hintStyle ??
                              TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                          border: InputBorder.none,
                          contentPadding:
                              contentPadding ??
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                          counterText: '',
                        ),
                        style:
                            textStyle ??
                            const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
