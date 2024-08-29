import 'package:d2_touch/modules/auth/entities/user.entity.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:user_support_mobile/models/approve_model.dart';
import 'package:user_support_mobile/modules/module-authentication/metadatasync/initial-metadata-sync.dart';
import 'package:user_support_mobile/pages/data_approval_detail.dart';
import 'package:user_support_mobile/pages/dataset_screen.dart';
import 'package:user_support_mobile/pages/home_page.dart';
import 'package:user_support_mobile/pages/splash_page.dart';

import '../pages/compose_page.dart';
import '../pages/compose_painter.dart';
import '../pages/inbox_page.dart';
import '../pages/facility_screen/local_hospital_screen.dart';
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
      routes: <RouteBase>[],
    ),
    GoRoute(path: '/sync', builder: (context, state) {
      return HomeMetadataSync(
      loggedInUser: state.extra as User,
    );
    }),
    GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
        routes: [
                GoRoute(
                  path: 'dataset',
                  builder: (BuildContext context, GoRouterState state) {
                    return const DatasetScreen();
                  },
                ),
                GoRoute(
                  path : 'local_hospital',
                  builder:  (BuildContext context, GoRouterState state){
                    return const LocalHospitalScreen();
                  }
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
                  path: 'login',
                  builder: (BuildContext context, GoRouterState state) {
                    return LoginPage();
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
                    }),
        ]),
  ],
);
