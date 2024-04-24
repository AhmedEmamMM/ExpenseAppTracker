import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onSettingPressed;
  final void Function(BuildContext)? onDeletePressed;
  const ExpenseListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onSettingPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // setting options
            SlidableAction(
              onPressed: onSettingPressed,
              icon: Icons.edit,
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            // delete options
            SlidableAction(
              onPressed: onDeletePressed,
              icon: Icons.delete_forever,
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(title),
            trailing: Text(trailing),
          ),
        ),
      ),
    );
  }
}
