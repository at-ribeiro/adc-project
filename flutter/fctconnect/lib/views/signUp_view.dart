import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_login_ui/models/register_user.dart';
import 'package:responsive_login_ui/services/session_manager.dart';

import '../views/login_view.dart';
import '../constants.dart';
import '../controller/simple_ui_controller.dart';
import '../models/register_user.dart';
import '../services/base_client.dart';

const List<String> privacy = ["private", "public"];

const String baseUrl = 'fct-connect-2023.oa.r.appspot.com/rest';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordVerController = TextEditingController();
  TextEditingController privacyController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    SessionManager.storeSession('session' ,'/signup');
    super.initState();
    
  }

  @override
  void dispose() {
    nameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordVerController.dispose();
    privacyController.dispose();
    super.dispose();
  }

  SimpleUIController simpleUIController = Get.put(SimpleUIController());

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildLargeScreen(size, simpleUIController, theme);
              } else {
                return _buildSmallScreen(size, simpleUIController, theme);
              }
            },
          )),
    );
  }

  /// For large screens
  Widget _buildLargeScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return Row(
      children: [
       
        SizedBox(width: size.width * 0.06),
        Expanded(
          flex: 5,
          child: _buildMainBody(size, simpleUIController, theme),
        ),
      ],
    );
  }

  /// For Small screens
  Widget _buildSmallScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return SingleChildScrollView(
      child: Center(
        child: _buildMainBody(size, simpleUIController, theme),
      ),
    );
  }

  /// Main Body
  Widget _buildMainBody(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: size.width > 600
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          
          SizedBox(
            height: size.height * 0.03,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Sign Up',
              style: kLoginTitleStyle(size),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Conecta-te aos teus colegas!',
              style: kLoginSubtitleStyle(size),
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  /// username
                  TextFormField(
                    style: kTextFormFieldStyle(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),

                    controller: nameController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      } else if (value.length < 4) {
                        return 'at least enter 4 characters';
                      } else if (value.length > 13) {
                        return 'maximum character is 13';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  TextFormField(
                    style: kTextFormFieldStyle(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),

                    controller: fullNameController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      } else {
                        return null;
                      }
                    },
                  ),

                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  /// Email
                  TextFormField(
                    style: kTextFormFieldStyle(),
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_rounded),
                      hintText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an e-mail';
                      } else if (!value.contains('@')) {
                        return 'please enter valid e-mail';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  /// password
                  Obx(
                    () => TextFormField(
                      style: kTextFormFieldStyle(),
                      controller: passwordController,
                      obscureText: simpleUIController.isObscure.value,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_open),
                        suffixIcon: IconButton(
                          icon: Icon(
                            simpleUIController.isObscure.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            simpleUIController.isObscureActive();
                          },
                        ),
                        hintText: 'Password',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        } else if (value.length < 6) {
                          return 'at least enter 6 characters';
                        } else if (value.length > 13) {
                          return 'maximum character is 13';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  Obx(
                    () => TextFormField(
                      style: kTextFormFieldStyle(),
                      controller: passwordVerController,
                      obscureText: simpleUIController.isObscure.value,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_open),
                        suffixIcon: IconButton(
                          icon: Icon(
                            simpleUIController.isObscure.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            simpleUIController.isObscureActive();
                          },
                        ),
                        hintText: 'Password Verification',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        } else if (passwordVerController.text !=
                            passwordController.text) {
                          return 'Passwords must match';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Text(
                    'Creating an account means you\'re okay with our Terms of Services and our Privacy Policy',
                    style: kLoginTermsAndPrivacyStyle(size),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  /// SignUp Button
                  signUpButton(theme),
                  SizedBox(
                    height: size.height * 0.03,
                  ),

                  /// Navigate To Login Screen
                  GestureDetector(
                    onTap: () {
                      
                      nameController.clear();
                      emailController.clear();
                      passwordController.clear();
                      _formKey.currentState?.reset();

                      simpleUIController.isObscure.value = true;

                      context.go("/login");
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account?',
                        style: kHaveAnAccountStyle(size),
                        children: [
                          TextSpan(
                              text: " Login",
                              style: kLoginOrSignUpTextStyle(size)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SignUp Button
  Widget signUpButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromARGB(198, 0, 54, 250)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            var _body = {
              "username": nameController.text,
              "fullname": fullNameController.text,
              "password": passwordController.text,
              "passwordV": passwordVerController.text,
              "email": emailController.text,
              "role": "USER",
              "state": "ACTIVE",
              "privacy": "PRIVATE",
            };

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return FutureBuilder(
                  future: BaseClient().post("/register/", _body),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return AlertDialog(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 10),
                            Text('Loading...'),
                          ],
                        ),
                      );
                    } else {
                      String showErrorMessage;
                      if (snapshot.hasError) {
                        switch (snapshot.error) {
                          case '409':
                            showErrorMessage = "username ou email já existem!";
                            break;
                          default:
                            showErrorMessage =
                                "Algo não está certo, tente outra vez!";
                            break;
                        }

                        return AlertDialog(
                          title: Text('Error'),
                          content: Text(showErrorMessage),
                          actions: <Widget>[
                            ElevatedButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (ctx) => const LoginView()),
                          );

                          nameController.clear();
                          emailController.clear();
                          passwordController.clear();
                          _formKey.currentState?.reset();
                        });
                      }
                    }
                    return Container();
                  },
                );
              },
            );
          }
        },
        child: const Text('Sign up'),
      ),
    );
  }
}
