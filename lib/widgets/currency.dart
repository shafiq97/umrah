import 'package:currency_picker/currency_picker.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrencyText extends StatelessWidget {
  final double? amount;
  final TextStyle? style;
  final TextOverflow? overflow;
  final bool? isCompact;
  final CurrencyService currencyService = CurrencyService();

  CurrencyText(this.amount,
      {super.key, this.style, this.overflow, this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Selector<AppProvider, String?>(
      builder: (context, currencyCode, _) {
        Currency? currency = currencyService.findByCode(currencyCode);
        String symbol = currency?.symbol ?? '';
        String formattedAmount = '';

        // If amount is not null, format it using CurrencyHelper and prepend the symbol with a space
        if (amount != null) {
          formattedAmount = (isCompact ?? false)
              ? '${symbol} ${CurrencyHelper.formatCompact(amount!, name: currency?.code, symbol: symbol)}'
              : '${symbol} ${CurrencyHelper.format(amount!, name: currency?.code, symbol: symbol)}';
        } else {
          // If amount is null, just show the symbol followed by a space
          formattedAmount = '$symbol ';
        }

        return Text(
          formattedAmount,
          style: style,
          overflow: overflow,
        );
      },
      selector: (_, provider) => provider.currency,
    );
  }
}
