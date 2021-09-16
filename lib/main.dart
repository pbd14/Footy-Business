import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/sww_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'Services/auth_service.dart';
import 'constants.dart';

// applicationId com.example.footy_business
// SHA1: 19:15:92:FA:6D:EE:79:89:88:63:7A:59:5C:45:75:83:30:26:74:33
// SHA-256: 33:88:C5:61:62:CC:38:A9:CC:FE:3A:37:0A:17:70:2C:4F:86:BF:47:4B:6A:75:DF:3C:88:AD:0D:8D:07:E5:5A

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  // void initState() {
  //   super.initState();
  //   this.initDynamicLinks();
  // }

  // void initDynamicLinks() async {
  //   FirebaseDynamicLinks.instance.onLink(
  //       onSuccess: (PendingDynamicLinkData dynamicLink) async {
  //     final Uri deepLink = dynamicLink?.link;

  //     if (deepLink != null) {
  //       // String id = Uri.base.queryParameters['id'];
  //       // String companyId = Uri.base.queryParameters['companyId'];
  //       // String balance = Uri.base.queryParameters['balance'];
  //       // String status = Uri.base.queryParameters['octo_status'];
  //       // if (status == 'succeeded') {
  //       //   FirebaseFirestore.instance.collection('transactions').doc(id).update({
  //       //     'status': 'finished',
  //       //   });
  //       //   FirebaseFirestore.instance
  //       //       .collection('companies')
  //       //       .doc(companyId)
  //       //       .update({'balance': balance}).catchError(() {
  //       //     FirebaseFirestore.instance
  //       //         .collection('transactions')
  //       //         .doc(id)
  //       //         .update({
  //       //       'status': 'updateFailed',
  //       //     });
  //       //   });
  //       // }
  //       Navigator.pushNamed(context, deepLink.path);
  //     }
  //   }, onError: (OnLinkErrorException e) async {
  //     print('onLinkError');
  //     print(e.message);
  //   });

  //   final PendingDynamicLinkData data =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //   final Uri deepLink = data?.link;

  //   if (deepLink != null) {
  //     // String id = Uri.base.queryParameters['id'];
  //     // String companyId = Uri.base.queryParameters['companyId'];
  //     // String balance = Uri.base.queryParameters['balance'];
  //     // String status = Uri.base.queryParameters['octo_status'];
  //     // if (status == 'succeeded') {
  //     //   FirebaseFirestore.instance.collection('transactions').doc(id).update({
  //     //     'status': 'finished',
  //     //   });
  //     //   FirebaseFirestore.instance
  //     //       .collection('companies')
  //     //       .doc(companyId)
  //     //       .update({'balance': balance}).catchError(() {
  //     //     FirebaseFirestore.instance.collection('transactions').doc(id).update({
  //     //       'status': 'updateFailed',
  //     //     });
  //     //   });
  //     // }
  //     Navigator.pushNamed(context, deepLink.path);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Footy',
        theme: ThemeData(
            primaryColor: primaryColor, scaffoldBackgroundColor: whiteColor),
        home: AuthService().handleAuth(),
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
