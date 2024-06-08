import 'dart:core';

import 'package:d2_touch/d2_touch.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:user_support_mobile/pages/inbox_page.dart';
import 'package:user_support_mobile/pages/login_page.dart';
import 'package:user_support_mobile/app_binding.dart';
import 'package:user_support_mobile/constants/d2-repository.dart';
import 'package:user_support_mobile/modules/module-authentication/login/login-page.dart';
import 'package:user_support_mobile/pages/home_page.dart';
import 'package:user_support_mobile/pages/splash_page.dart';
import 'package:user_support_mobile/providers/provider.dart';
import 'package:user_support_mobile/routes/routes.dart';
import 'package:user_support_mobile/routes_generator.dart';

import '../helpers/text_theme.dart';
import 'main.reflectable.dart';

void main() async {
  initializeReflectable();
  WidgetsFlutterBinding.ensureInitialized();
  d2repository = await D2Touch.init();

  // for development purposes
  await d2repository.authModule.logIn(
    url: 'http://41.59.227.69/tland-upgrade',
    username: 'wgoodluck',
    password: 'Hmis@2024'
  );

  bool isAuth = await d2repository.authModule.isAuthenticated();

  runApp(
    MyApp(
      isAuth: isAuth,
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isAuth;
  const MyApp({Key? key, required this.isAuth}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
        return ChangeNotifierProvider<MessageModel>(
      create: (_) => MessageModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'User Support App',
        theme: ThemeData(
          textTheme: textTheme,
          primaryColor: const Color(0xFF1D5288),
        ),
        home: SplashScreen(isAuth: widget.isAuth),
        routes: routes,
        builder: EasyLoading.init(),
      )
    );
  }
}
