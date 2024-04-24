import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// reture width of the Screen
double widthOfScreen(BuildContext context) => MediaQuery.of(context).size.width;
// reture height of the Screen
double heightOfScreen(BuildContext context) =>
    MediaQuery.of(context).size.height;

// convert String to double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double amount into dollars and cents

String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: "en_US", symbol: "\$", decimalDigits: 2);
  return format.format(amount);
}

// calculate the number of months since the first start month

int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

// get current month name

String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];
  return months[now.month - 1];
}
