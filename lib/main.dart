import 'package:expense_tracker_app/datebase/expense_datebase.dart';
import 'package:expense_tracker_app/helpers/helpers.dart';
import 'package:expense_tracker_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize our datebase
  await ExpenseDatebase.initialize();
  runApp(ChangeNotifierProvider(
    create: (context) => ExpenseDatebase(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(widthOfScreen(context), heightOfScreen(context)),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(useMaterial3: true),
          home: const HomePage(),
        );
      },
    );
  }
}
