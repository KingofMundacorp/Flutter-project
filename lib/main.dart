import 'package:d2_touch/d2_touch.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:user_support_mobile/app_binding.dart';
import 'package:user_support_mobile/constants/d2-repository.dart';
import 'package:user_support_mobile/modules/module-authentication/login/login-page.dart';
import 'package:user_support_mobile/pages/home_page.dart';
import 'package:user_support_mobile/routes_generator.dart';

import '../helpers/text_theme.dart';
import 'main.reflectable.dart';

void main() async {
  initializeReflectable();
  WidgetsFlutterBinding.ensureInitialized();
  
  // for development purposes
  var loginRes = await d2repository.authModule.logIn(
    url: 'https://tland.dhis2.udsm.ac.tz',
    username: 'pt',
    password: 'Dhis.2022'
  );

  print(loginRes);


  var isAuth = await d2repository.authModule.isAuthenticated();

  runApp(
    MyApp(
      authenticated: isAuth,
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
