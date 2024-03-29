import 'package:flutter/material.dart';
import 'driver.dart';
import 'mainscreen.dart';
import 'package:my_pickup/loginscreen.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(SplashScreen());
String _email, _password;
String url = "http://pickupandlaundry.com/my_pickup/chan/php/login.php";

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.orange),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo2.png',
                scale: 2,
              ),
              SizedBox(
                height: 20,
              ),
              new ProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => new _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
   super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value > 0.99) {
            //print('Sucess Login');
            loadpref(this.context);
          }
        });
      });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
      width: 200,
      color: Colors.black,
      child: LinearProgressIndicator(
        value: animation.value,
        backgroundColor: Colors.teal,
        valueColor:
            new AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    ));
  }
}
void loadpref(BuildContext ctx) async {
  print('Inside loadpref()');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _email = (prefs.getString('email')??'');
  _password = (prefs.getString('pass')??'');
  print("Splash:Preference");
  print(_email);
  print(_password);
  if (_isEmailValid(_email??"no email")) {
    //try to login if got email;
    _onLogin(_email, _password, ctx);
  } else {
    //login as unregistered user
    Driver driver = new Driver(
        name: "not register",
        email: "user@noregister",
        phone: "not register",
        );
    Navigator.push(
        ctx, MaterialPageRoute(builder: (context) => MainScreen(driver: driver)));
  }
}


bool _isEmailValid(String email) {
  return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

void _onLogin(String email, String pass, BuildContext ctx) {
  http.post(urlLogin, body: {
    "email": _email,
    "password": _password,
  }).then((res) {
    print(res.statusCode);
    var string = res.body;
    List dres = string.split(",");
    print("SPLASH:loading");
    print(dres);
    if (dres[0] == "success") {
      Driver driver = new Driver(
          name: dres[1],
          email: dres[2],
          phone: dres[3],
      );
      Navigator.push(
          ctx, MaterialPageRoute(builder: (context) => MainScreen(driver: driver)));
    } else {
      //allow login as unregistered user
      Driver driver = new Driver(
          name: "not register",
          email: "user@noregister",
          phone: "not register",
          );
      Navigator.push(
          ctx, MaterialPageRoute(builder: (context) => MainScreen(driver: driver)));
    }
  }).catchError((err) {
    print(err);
  });

Map<int, Color> color = {
  50: Color.fromRGBO(255, 185, 43, .1),
  100: Color.fromRGBO(255, 185, 43, .2),
  200: Color.fromRGBO(255, 185, 43, .3),
  300: Color.fromRGBO(255, 185, 43, .4),
  400: Color.fromRGBO(255, 185, 43, .5),
  500: Color.fromRGBO(255, 185, 43, .6),
  600: Color.fromRGBO(255, 185, 43, .7),
  700: Color.fromRGBO(255, 185, 43, .8),
  800: Color.fromRGBO(255, 185, 43, .9),
  900: Color.fromRGBO(159, 30, 99, 1),
};
}