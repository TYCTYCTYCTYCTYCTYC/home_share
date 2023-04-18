import 'package:flutter/material.dart';
import 'package:home_share/pages/login_page.dart';
import 'package:home_share/pages/create_or_join.dart';
import 'package:home_share/utils/constants.dart';
import 'package:home_share/reusable/reusable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;

    //error handling: when some fields is empty
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      context.showErrorSnackBar(message: "Please fill in all fields");
      return;
    }

    //check entered email + check if emeial already exists in db
    if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
        .hasMatch(email)) {
      context.showErrorSnackBar(message: "Please enter a valid email address");
      return;
    }

    //check entered password
    if (password.length < 6) {
      context.showErrorSnackBar(
          message: "Password must be at least 6 characters");
      return;
    }

    //check entered username (cannot have space)
    if (!RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(username)) {
      context.showErrorSnackBar(
          message:
              "Username must be 3-24 characters long with alphanumeric or underscore");
      return;
    }

    try {
      await supabase.auth.signUp(
          email: email, password: password, data: {'username': username});
      Navigator.of(context)
          .pushAndRemoveUntil(CreateOrJoin.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
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
                20, MediaQuery.of(context).size.height * 0.1, 20, 10),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/icon.png',
                  height: 200,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Username", Icons.person_outline, false,
                    _usernameController, (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                  if (!isValid) {
                    return '3-24 long with alphanumeric or underscore';
                  }
                  return ' ';
                }),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Email", Icons.email_outlined, false, _emailController,
                    (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  return ' ';
                }),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Password", Icons.lock_outlined, true, _passwordController,
                    (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  if (val.length < 6) {
                    return '6 characters minimum';
                  }
                  return ' ';
                }),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: const Text(
                      'SIGN UP',
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

                //if user has account, bring them to login page
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(LoginPage.route());
                  },
                  child: const Text(
                    'I already have an account',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ))),
    );
  }
}
