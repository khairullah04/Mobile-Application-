import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unisell/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'CreateAccount.dart';
import 'CreatePost.dart';
import 'Wishlist.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      routes: {
        '/createpost': (context) => const CreatePost(),
        '/wishlist': (context) => const Wishlist(),
      },

      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool hide = false;

  @override
  void initState() {
    super.initState();

    _scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 30.0)
        .animate(_scaleController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const Login(),
            ),
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/utm.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [
                Colors.grey.withOpacity(.8),
                Colors.grey.withOpacity(.6),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                    children: const [
                      TextSpan(
                        text: 'Uni',
                        style: TextStyle(
                            color: Color.fromARGB(255, 132, 10, 2)),
                      ),
                      TextSpan(
                        text: 'Sell',
                        style: TextStyle(
                            color: Color.fromARGB(255, 232, 160, 0)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    children: const [
                      TextSpan(text: 'Your', style: TextStyle(color: Colors.red)),
                      TextSpan(text: ' Go-To ', style: TextStyle(color: Colors.yellow)),
                      TextSpan(text: 'Market', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔐 LOGIN BUTTON
                InkWell(
                  onTap: () {
                    setState(() => hide = true);
                    _scaleController.forward();
                  },
                  child: AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: hide
                              ? Container()
                              : const Text("Login",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccount(),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}