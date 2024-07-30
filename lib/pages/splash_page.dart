import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:user_support_mobile/constants/d2-repository.dart';

import '../providers/provider.dart';

class SplashScreen extends StatefulWidget {
  final bool? isAuth;

  const SplashScreen({Key? key, this.isAuth}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    isAuthenticated();
  }

  isAuthenticated() async {
    bool isAuth = await d2repository.authModule.isAuthenticated();

    if (isAuth) {
      Timer(const Duration(seconds: 3), () {
        context.go('/home');
      });
    } else {
      context.go('/home/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<MessageModel>().fetchPrivateMessages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dhis2logo.png',
              color: const Color(0xFF1D5288),
              height: 120,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
