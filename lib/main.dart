import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/sww_screen.dart';
import 'package:footy_business/Services/languages/locale_constant.dart';
import 'package:overlay_support/overlay_support.dart';
import 'Services/auth_service.dart';
import 'Services/languages/applocalizationsdelegate.dart';
import 'constants.dart';

// applicationId com.footy_business.uz
// SHA1: 19:15:92:FA:6D:EE:79:89:88:63:7A:59:5C:45:75:83:30:26:74:33
// SHA-256: 33:88:C5:61:62:CC:38:A9:CC:FE:3A:37:0A:17:70:2C:4F:86:BF:47:4B:6A:75:DF:3C:88:AD:0D:8D:07:E5:5A
// Google Play SHA-1 DA:BC:40:C6:66:1B:20:0D:89:F5:7C:83:21:94:A1:E1:01:EA:73:DF
// Google Play SHA-256 6B:ED:1C:5A:09:6D:FC:C5:E1:F0:BD:40:C6:56:BE:DF:AB:67:2E:22:61:15:DD:73:50:B2:D6:AD:AD:90:8E:E1

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Footy Business',
        locale: _locale,
        theme: ThemeData(
            primaryColor: primaryColor, scaffoldBackgroundColor: whiteColor),
        home: AuthService().handleAuth(),
        supportedLocales: [
          Locale('en', ''),
          Locale('ru', ''),
          Locale('uz', ''),
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale?.languageCode == locale?.languageCode &&
                supportedLocale?.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales?.first;
        },
        routes: <String, WidgetBuilder>{
          // Default home route
          '/payment_done': (BuildContext context) => SomethingWentWrongScreen(
                error: 'Payment was successful',
              ),
        },
      ),
    );
  }
}
