import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/views/loading_screen.dart';
import 'package:responsive_login_ui/views/signUp_view.dart';

import '../constants.dart';
import '../controller/simple_ui_controller.dart';
import '../data/cache_factory_provider.dart';
import '../main.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import 'my_home_page.dart';
import 'loading_screen.dart';

class LoginView extends StatefulWidget {
  final String? session;

  const LoginView({Key? key, this.session}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    SessionManager.storeSession('session', '/');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SimpleUIController simpleUIController =
        Get.find<SimpleUIController>();

    var size = MediaQuery.of(context).size;

    return Container(
      decoration: kGradientDecoration,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildLargeScreen(size, simpleUIController);
              } else {
                return _buildSmallScreen(size, simpleUIController);
              }
            },
          ),
        ),
      ),
    );
  }

  /// For large screens
  Widget _buildLargeScreen(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Row(
      children: [
        SizedBox(width: size.width * 0.06),
        Expanded(
          flex: 5,
          child: _buildMainBody(
            size,
            simpleUIController,
          ),
        ),
      ],
    );
  }

  /// For Small screens
  Widget _buildSmallScreen(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Center(
      child: _buildMainBody(
        size,
        simpleUIController,
      ),
    );
  }

  /// Main Body
  Widget _buildMainBody(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
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
                  'Login',
                  style: textTheme.headline2!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kAccentColor0,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Bem vindo de volta!',
                  style: textTheme.headline5!.copyWith(
                  
                    color: kAccentColor0,
                  ),  
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
                      /// username or Gmail
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: kAccentColor0.withOpacity(0.3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: TextFormField(
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                hintText: 'Username',
                                border: InputBorder.none,
                              ),
                              controller: nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      // ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),

                      /// password
                      Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: kAccentColor0.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
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
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),

                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),

                      SizedBox(
                        height: size.height * 0.02,
                      ),

                      /// Login Button
                      loginButton(),
                      SizedBox(
                        height: size.height * 0.03,
                      ),

                      /// Navigate To Login Screen
                      GestureDetector(
                        onTap: () {
                          context.go(Paths.signUp);
                          nameController.clear();
                          emailController.clear();
                          passwordController.clear();
                          _formKey.currentState?.reset();
                          simpleUIController.isObscure.value = true;
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Não tens uma conta?',
                            children: [
                              TextSpan(
                                text: " Sign up",
                                style: TextStyle(color: Colors.blue),
                              ),
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
        ),
      ),
    );
  }

  // Login Button
  Future<dynamic> _performLogin() async {
    var _body = {
      "username": nameController.text,
      "password": passwordController.text,
    };

    var response = await BaseClient().postLogin("/login/", _body);

    String tokenId = response.tokenID;
    String username = response.username;
    String role = response.role;
    String cD = response.creationDate.toString();
    String eD = response.expirationDate.toString();

    CacheDefault.cacheFactory.login(tokenId, username, cD, eD, role);
    CacheDefault.cacheFactory.set('isLoggedIn', 'true');

    print(response);

    context.go(Paths.homePage);

    return response;
  }

  Widget doLogin() {
    return FutureBuilder<void>(
      future: _performLogin(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('Something went wrong'),
                    Text(snapshot.error.toString()),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    context.go("/login");
                  },
                ),
              ],
            );
          } else {
            context.go("/homepage");
            return Container();
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          // Validate returns true if the form is valid, or false otherwise.
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return doLogin();
              });
          // Call the login funct
        },
        child: const Text('Login', style: TextStyle(color:kAccentColor0)),
      ),
    );
  }
}
