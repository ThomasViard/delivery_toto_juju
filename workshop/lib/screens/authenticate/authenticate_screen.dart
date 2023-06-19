import '../../common/constant.dart';
import '../../common/loading.dart';
import '../../services/authentication.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthenticateScreen extends StatefulWidget {
  const AuthenticateScreen({Key? key}) : super(key: key);

  @override
  AuthenticateScreenState createState() => AuthenticateScreenState();
}

class AuthenticateScreenState extends State<AuthenticateScreen> {
  final auth = AuthenticationService();
  final formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showSignIn = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void toggleView() {
    setState(() {
      formKey.currentState!.reset();
      error = '';
      emailController.text = '';
      passwordController.text = '';
      confirmPasswordController.text = '';
      showSignIn = !showSignIn;
    });
  }

  TextFormField confMpd() {
    return TextFormField(
      controller: confirmPasswordController,
      decoration: textInputDecoration.copyWith(hintText: 'confirm password'),
      obscureText: true,
      validator: (value) {
        if (confirmPasswordController.text != passwordController.text) {
          return "Submit the same password";
        } else {
          return null;
        }
      },
    );
  }

  void popUp(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CloseButton(
                    color: Colors.grey,
                    onPressed: () => Navigator.pop(context, true)),
              ],
            ),
            content: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Check your mailbox\n',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.justify,
                  '''
You received an email in order
to reinitialize your password''',
                ),
              ],
            ),
          );
        });
  }

  Future reinitializeModal() => showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        context: context,
        builder: (context) => Container(
            padding:
                const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text(
                    'Reinitialize password\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  const Text(
                    """
    Enter the e-mail associated to your account.
    You will receive a reinitialization link on it.\n\n""",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: textInputDecoration.copyWith(hintText: 'email'),
                    validator: (value) {
                      return value!.isEmpty ? "Enter an email" : null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        var email = emailController.value.text;
                        dynamic result = await auth.checkIfEmailInUse(email);
                        if (result == true) {
                          await auth.resetPasswordFromEmail(email);
                          if (!mounted) return;
                          popUp(context);
                        } else {
                          setState(() {
                            error = 'invalid';
                          });
                        }
                      }
                    },
                    child: const Text(
                      'Reinitialize',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )));

  Text reinitializePassword() =>
      Text.rich(TextSpan(text: 'Forgot password ? ', children: <TextSpan>[
        TextSpan(
            text: 'Reinitialize',
            style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                reinitializeModal();
              })
      ]));

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.blueGrey,
              title: Text(showSignIn ? 'Sign in' : 'Register'),
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  label: Text(showSignIn ? 'Register' : "Sign in",
                      style: const TextStyle(color: Colors.white)),
                  onPressed: () => toggleView(),
                ),
              ],
            ),
            body: PageView(children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 30.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'email'),
                        validator: (value) {
                          return value!.isEmpty ? "Enter an email" : null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: passwordController,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'password'),
                        obscureText: true,
                        validator: (value) {
                          return value!.length < 6
                              ? "minimum 6 charactères"
                              : null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      if (!showSignIn) confMpd(),
                      if (showSignIn) reinitializePassword(),
                      ElevatedButton(
                        child: Text(
                          showSignIn ? "Sign in" : "Register",
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            var confPassword =
                                confirmPasswordController.value.text;
                            var password = passwordController.value.text;
                            var email = emailController.value.text;
                            dynamic result;
                            if (showSignIn) {
                              result = await auth.signInWithEmailAndPassword(
                                  email, password);
                            } else {
                              if (confPassword == password) {
                                result =
                                    await auth.registerWithEmailAndPassword(
                                        email, password);
                              } else {
                                setState(() {
                                  loading = false;
                                  error = 'invalid';
                                });
                              }
                            }
                            if (result == null) {
                              setState(() {
                                loading = false;
                                error =
                                    "Supply a valid email or check your password";
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
  }
}
