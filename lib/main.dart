// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
// import 'package:my_flutter_mapwash/pages/addressLocation.dart';
// import 'package:my_flutter_mapwash/pages/affiat.dart';
// import 'package:my_flutter_mapwash/pages/delete.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
// import 'package:my_flutter_mapwash/pages/map_screen.dart';
// import 'package:my_flutter_mapwash/pages/promotion.dart';
// import 'package:my_flutter_mapwash/pages/show_promotion.dart';
// import 'package:my_flutter_mapwash/pages/totalOder2.dart';
// import 'package:my_flutter_mapwash/pages/totalOrder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_flutter_mapwash/features/washing/washing_flow_screen.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme:
            GoogleFonts.kanitTextTheme(), // กำหนดฟอนต์ Lato ให้กับ textTheme
      ),
      // home: StatusOrder(
      //   orderId: '666615574-WL',
      // ),
      // home: select_Promotion(),
      // home: ShareFriendScreen(),
      // home: LoginPage(),
      home: MainLayout(),
      // home: MyHomePage(),
      // home: TotalOrder(),
      // home: AddressLocation(),
      // home: TotalOrder222(), MyApp222 Promotion CheckoutPage
      // home: WashingFlowScreen(),
    );
  }
}
