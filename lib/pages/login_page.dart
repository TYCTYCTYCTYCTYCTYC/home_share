import 'package:flutter/material.dart';
import 'package:home_share/home.dart';
import 'package:home_share/dashboard.dart';
import 'package:home_share/utils/constants.dart';
import 'package:home_share/pages/register_page.dart';
import 'package:home_share/pages/create_or_join.dart';
import 'package:home_share/reusable/reusable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final currentUser = response.user;
      final userId = currentUser?.id;

      final responseHome = await supabase
          .from('user_home')
          .select('home_id')
          .eq('user_id', userId)
          .execute();

      if (responseHome.data.isNotEmpty) {
        final homeId = responseHome.data[0]['home_id'];

        // Navigate to the home page with the corresponding home ID if user already have a Home
        Navigator.of(context)
            .pushAndRemoveUntil(Home.route(), (route) => false);
      } else {
        // Navigate to the CreateOrJoin page if user not in any Home yet
        Navigator.of(context)
            .pushAndRemoveUntil(CreateOrJoin.route(), (route) => false);
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFF103465),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                //const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom);
                20,
                MediaQuery.of(context).size.height * 0.1,
                20,
                10),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/icon.png',
                  height: 200,
                ),
                SizedBox(height: 40),
                reusableTextField(
                    "Email", Icons.person_outline, false, _emailController,
                    (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  return ' ';
                }),
                SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Password", Icons.lock_outline, true, _passwordController,
                    (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  if (val.length < 6) {
                    return '6 characters minimum';
                  }
                  return ' ';
                }),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: const Text(
                      'SIGN IN',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return Colors.white;
                      }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(RegisterPage.route());
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
