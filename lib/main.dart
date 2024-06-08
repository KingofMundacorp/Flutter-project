import 'package:d2_touch/d2_touch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../helpers/text_theme.dart';
import 'main.reflectable.dart';

void main() async {
  initializeReflectable();
  D2Touch.initialize();
  
  // for development purposes
  var loginRes = await D2Touch.logIn(
    url: 'https://tland.dhis2.udsm.ac.tz',
    username: 'pt',
    password: 'Dhis.2022'
  );

  print(loginRes);


  var isAuth = await D2Touch.isAuthenticated();

  runApp(
    MyApp(
      isAuth: isAuth,
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool authenticated;
  const MyApp({Key? key, required this.authenticated}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'User support app',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey, // add this
      theme: ThemeData(
        colorScheme: const ColorScheme(
            background: Colors.blueAccent,
            onBackground: Colors.white,
            primary: Colors.blueAccent,
            onPrimary: Colors.white,
            secondary: Colors.teal,
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.teal,
            error: Colors.red,
            onError: Colors.white,
            brightness: Brightness.light),
        // fontFamily: 'Montserrat'
      ),
      initialRoute:
          widget.authenticated ? HomePage.routeName : HomeLogin.routeName,
      onGenerateRoute: RoutesGenerator.generateRoute,
      initialBinding: AppBindings(),
    );
  }
}
