import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:user_support_mobile/models/approve_model.dart';
import 'package:user_support_mobile/pages/data_approval_detail.dart';
import 'package:user_support_mobile/pages/dataset_screen.dart';
import 'package:user_support_mobile/pages/home_page.dart';
import 'package:user_support_mobile/pages/splash_page.dart';

import '../pages/compose_page.dart';
import '../pages/compose_painter.dart';
import '../pages/inbox_page.dart';
import '../pages/login_page.dart';
import '../pages/system_page.dart';
import '../pages/ticket_page.dart';
import '../pages/validation_page.dart';
import '../pages/data_approval_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
      routes: <RouteBase>[
        GoRoute(
            path: 'home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'dataset',
                builder: (BuildContext context, GoRouterState state) {
                  return const DatasetScreen();
                },
              ),
              GoRoute(
                path: 'compose',
                builder: (BuildContext context, GoRouterState state) {
                  return const ComposePage();
                },
              ),
              GoRoute(
                path: 'inbox/:isAuth',
                builder: (BuildContext context, GoRouterState state) {
                  final bool isAuth = state.extra! as bool;
                  return const InboxPage();
                },
              ),
              GoRoute(
                path: 'system',
                builder: (BuildContext context, GoRouterState state) {
                  return const SystemPage();
                },
              ),
              GoRoute(
                path: 'validation',
                builder: (BuildContext context, GoRouterState state) {
                  return const ValidationPage();
                },
              ),
              GoRoute(
                path: 'ticket',
                builder: (BuildContext context, GoRouterState state) {
                  return const TicketPage();
                },
              ),
              GoRoute(
                name: 'login',
                path: 'login/:isAuth',
                builder: (BuildContext context, GoRouterState state) {
                  print('isAuth: ${state.pathParameters}');
                  return LoginPage(
                      isAuth: state.pathParameters['isAuth'] == "true");
                },
              ),
              GoRoute(
                path: 'composePainter',
                builder: (BuildContext context, GoRouterState state) {
                  return const ComposePainter();
                },
              ),
              GoRoute(
                path: 'dataApproval',
                builder: (BuildContext context, GoRouterState state) {
                  return const DataApprovalScreen();
                },
              ),
              GoRoute(
                  path: 'request_details',
                  builder: (context, state) {
                    final dataApproval = state.extra as ApproveModel;
                    return DataApprovalDetailPage(
                      dataApproval: dataApproval,
                    );
                  })
            ]),
      ],
    ),
  ],
);
