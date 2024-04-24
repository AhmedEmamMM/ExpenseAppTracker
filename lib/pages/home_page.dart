import 'package:expense_tracker_app/bar%20graph/bar_graph.dart';
import 'package:expense_tracker_app/components/expense_list_tile.dart';
import 'package:expense_tracker_app/datebase/expense_datebase.dart';
import 'package:expense_tracker_app/helpers/helpers.dart';
import 'package:expense_tracker_app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  // future to load  graph date , monthly total

  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateMonthlyTotal;

  @override
  void initState() {
    // read database on initlal startup
    Provider.of<ExpenseDatebase>(context, listen: false).readExpenses();

    // load futures
    refreshDate();

    super.initState();
  }

  // refresh the graph data
  void refreshDate() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatebase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateMonthlyTotal =
        Provider.of<ExpenseDatebase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  void clearCotrollers() {
    nameController.clear();
    amountController.clear();
  }

  void disposeCotrollers() {
    nameController.dispose();
    amountController.dispose();
  }

  // open new Expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user input (text field) -> expense name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Expense name"),
            ),

            // user input (text field) -> expense amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Expense amount"),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),

          // save button
          _createNewExpenseButton(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    disposeCotrollers();
  }

  // open Edit Expense box
  void openEditBox(Expense expense) {
    // pre-fill existing values into textfields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user input (text field) -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),

            // user input (text field) -> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),

          // save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  // open Delete Expense box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        actions: [
          // cancel button
          _cancelButton(),

          // delete button
          _deleteButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatebase>(builder: (context, value, child) {
      // get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      // calculate the number of month since the first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      // only display the expneses for the current month
      List<Expense> currentMonthExpense = value.allExpense.where((expense) {
        return expense.date.year == currentYear &&
            expense.date.month == currentMonth;
      }).toList();

      // return scaffold UI
      return Scaffold(
          backgroundColor: Colors.grey.shade300,
          appBar: AppBar(
            title: FutureBuilder(
              future: _calculateMonthlyTotal,
              builder: (context, snapshot) {
                // data is loaded
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // amount total
                      Text('\$ ${snapshot.data!.toStringAsFixed(2)}'),

                      // display current month
                      Text(getCurrentMonthName()),
                    ],
                  );
                }
                // loading...
                else {
                  return const Text("Loading...");
                }
              },
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Column(
                children: [
                  // barGraph UI
                  SizedBox(
                    height: 250,
                    child: FutureBuilder(
                      future: _monthlyTotalsFuture,
                      builder: (context, snapshot) {
                        // data is loaded
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, double> monthlyTotals =
                              snapshot.data ?? {};

                          // create the list of monthy summary
                          List<double> monthlySummary =
                              List.generate(monthCount, (index) {
                            // calculate year-month considering startmonth and index

                            int year =
                                startYear + (startMonth + index - 1) ~/ 12;
                            int month = (startMonth + index - 1) % 12 + 1;

                            // create the key in the format 'year-month'

                            String yearMonthKey = '$year-$month';

                            // returun the total for year-month or 0.0 if not exist
                            return monthlyTotals[yearMonthKey] ?? 0.0;
                          });
                          return MyBarGraph(
                              monthlySummary: monthlySummary,
                              startMonth: startMonth);
                        }
                        // loading...
                        else {
                          return const Text("Loading...");
                        }
                      },
                    ),
                  ),

                  // list of expense
                  Expanded(
                      child: ListView.builder(
                    itemCount: currentMonthExpense.length,
                    itemBuilder: (context, index) {
                      // reverse the index to show latest item first
                      int reversedIndex =
                          currentMonthExpense.length - 1 - index;

                      // get individual expense
                      Expense individualExpense =
                          currentMonthExpense[reversedIndex];
                      // return listtile
                      return ExpenseListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onSettingPressed: (context) =>
                            openEditBox(individualExpense),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense),
                      );
                    },
                  )),
                ],
              ),
            ),
          ));
    });
  }

  // cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // pop the box
        Navigator.pop(context);
        // clear controllers
        clearCotrollers();
      },
      child: const Text('Cancel'),
    );
  }

  // SAVE button  -> create a new Expense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        // only save when there is something in textfield to save

        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          // pop the box
          Navigator.pop(context);

          // create new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          // save it to datebase
          await context.read<ExpenseDatebase>().createNewExpense(newExpense);

          // refresh the gragph
          refreshDate();

          // clear controllers
          clearCotrollers();
        }
      },
      child: const Text('save'),
    );
  }

  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // save as long as at least one of the textfields has been change
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);

          // create a new updated expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          // old expensi id
          int existingID = expense.id;

          // refresh the gragph
          refreshDate();

          // save to datebase
          await context
              .read<ExpenseDatebase>()
              .updateExpense(existingID, updatedExpense);
        }
      },
      child: const Text("Save"),
    );
  }

  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // pop box
        Navigator.pop(context);

        // delete expense from database
        await context.read<ExpenseDatebase>().deleteExpense(id);

        // refresh the gragph
        refreshDate();
      },
      child: const Text("Delete"),
    );
  }
}
