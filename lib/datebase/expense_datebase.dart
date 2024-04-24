import 'package:expense_tracker_app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatebase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

//  S E T U P

  // initialize datebase
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

//  G E T T E R

  List<Expense> get allExpense => _allExpenses;

//  O P E R A T I O N S

  // CRUD OPERATIONS

  // create  -> add a new expense
  Future<void> createNewExpense(Expense newExpense) async {
    // add to datebase
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    // re-read all expenses from datebase
    readExpenses();
  }

  // read    -> read expenses from datebase
  Future<void> readExpenses() async {
    // fetch all existing expenses in datebase
    List<Expense> fetchAllExpenses = await isar.expenses.where().findAll();

    // give it to our local expense List (_allExpenses)
    _allExpenses.clear();
    _allExpenses.addAll(fetchAllExpenses);

    // update UI
    notifyListeners();
  }

  // Update  -> edit an expense in database
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    // lets make sure that newExpense has same id as existing(old one) one in datebase
    updatedExpense.id = id;

    // update the expense
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    // re-read all expnses from datebase
    await readExpenses();
  }

  // delete  -> delete an expense from datebase
  Future<void> deleteExpense(int id) async {
    // delete expense from database
    await isar.writeTxn(() => isar.expenses.delete(id));

    // re-read from database
    await readExpenses();
  }

//  H E L P E R S

/*
  the key of year-month

  {
    2024-0:250$, JAN
    2024-1:200$, FEB
    2024-2:340$, MAR
    2024-3:740$, APR
    2024-4:120$, MAY
    2024-5:540$, JUN
  }
*/

  // calculate total expenses for each month and year
  Future<Map<String, double>> calculateMonthlyTotals() async {
    // ensure the expenses are read from the database
    await readExpenses();

    // create a map tp keep track of total expenses per month and year
    Map<String, double> monthlyTotals = {};

    // iterate over all expenses
    for (var expense in _allExpenses) {
      // extract the month from the data of the expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';
      // if the year-month is not yet in the map , initialize it to 0
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      // add the expense amount to the total for the month
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    // ensure expenses are read from database first
    await readExpenses();

    // get curren month and year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // filter the expenses to include only those for this year and this month
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

    // calculate total amount for the current month
    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  // get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .month; // default to current month is no expense are recored
    }

    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.month;
  }

  // get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .year; // default to current year is no expense are recored
    }

    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.year;
  }
}
