import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safetouch/screens/idea_quest_view.dart';
import '../firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetouch/consts/colors.dart';
import 'package:safetouch/screens/screens.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/encrypted_storage_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      name: 'signin',
      path: '/',
      builder: (context, state) => SigninView(),
    ),
    GoRoute(
        name: 'signup',
        path: '/signup',
        builder: (context, state) {
          int data = state.extra as int;
          return SignupView(user: data);
        }),
    GoRoute(
        name: 'edit_account',
        path: '/editAccount',
        builder: (context, state) => EditAccountView()),
    GoRoute(
      name: 'main',
      path: '/main',
      builder: (context, state) => MainView(),
    ),
    GoRoute(
        name: 'add_store',
        path: '/addStore',
        builder: (context, state) => AddStoreView(),
        routes: [
          GoRoute(
              name: 'add_store_2',
              path: 'stage2',
              builder: (context, state) {
                StoreDetails data = state.extra as StoreDetails;
                return AddStoreView2(details: data);
              }),
          GoRoute(
              name: 'add_store_3',
              path: 'stage3',
              builder: (context, state) {
                StoreDetails data = state.extra as StoreDetails;
                return AddStoreView3(details: data);
              }),
        ]),
    GoRoute(
      name: 'add_event',
      path: '/addEvent',
      builder: (context, state) => AddEventView(),
    ),
    GoRoute(
        name: 'request_book',
        path: '/requestBook',
        builder: (context, state) {
          String data = state.extra as String;
          return BookRequestView(path: data);
        }),
    GoRoute(
        name: 'table_store_avail',
        path: '/tableStoreAvail',
        builder: (context, state) => TablingStoreAvailabilityView(),
        routes: [
          GoRoute(
            name: 'table_answer_view',
            path: 'tableAnswerView',
            builder: (context, state) {
              String data = state.extra as String;
              return TablingStoreAvailabilityAnswerView(vacancyId: data);
            },
          )
        ]),
    GoRoute(
      name: 'table_cust_avail',
      path: '/tableCustAvail',
      builder: (context, state) => TablingCustomerAvailabilityView(),
    ),
    GoRoute(
        name: 'reserv_store_avail',
        path: '/reservStoreAvail',
        builder: (context, state) => ReservationStoreAvailabilityView(),
        routes: [
          GoRoute(
            name: 'reserv_answer_view',
            path: 'reservAnswerView',
            builder: (context, state) {
              String data = state.extra as String;
              return ReservationStoreAvailabilityAnswerView(bookId: data);
            },
          )
        ]),
    GoRoute(
      name: 'reserv_cust_avail',
      path: '/reservCustAvail',
      builder: (context, state) => ReservationCustAvailabilityView(),
    ),
    GoRoute(
      name: 'noti_setting_view',
      path: '/notiSettingView',
      builder: (context, state) => NotificationSettingView(),
    ),
    GoRoute(
      name: 'app_review_view',
      path: '/appReviewView',
      builder: (context, state) => IdeaQuestView(),
    ),
  ],
);

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'go router',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.mainMaterialColor,
        scaffoldBackgroundColor: Colors.white,
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _initializeDeviceStorage();
      if (Theme.of(context).platform == TargetPlatform.android) {
        Provider.of<Platform>(context, listen: false).osDiv = '1';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        Provider.of<Platform>(context, listen: false).osDiv = '2';
      }
      _initDynamicLink();
    });
  }

  void _initDynamicLink() {
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .then((value) => FirebaseDynamicLinks.instance.onLink
                .listen((pendingDynamicLinkData) {
              if (Provider.of<Session>(context, listen: false)
                  .sessionData
                  .userToken
                  .isNotEmpty) {
                if (Provider.of<Platform>(context, listen: false).userDiv ==
                    '2') {
                  if (navigatorKey.currentState != null) {
                    final path =
                        Uri.decodeFull(pendingDynamicLinkData.link.path);
                    navigatorKey.currentState!.push(MaterialPageRoute(
                        builder: (context) =>
                            BookRequestView(path: path.substring(1))));
                  }
                } else {
                  navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (context) => MainView()));
                }
              } else {
                navigatorKey.currentState!.push(
                    MaterialPageRoute(builder: (context) => SigninView()));
              }
            }));
  }

  Future<void> _initializeDeviceStorage() async {
    await EncryptedStorageService().initStorage();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      await EncryptedStorageService().deleteAllData();
      prefs.setBool('first_run', false);
    }
  }
}
