// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Themes/theme_manager.dart';
import '../constants.dart';
import '../controller/simple_ui_controller.dart';
import '../data/cache_factory_provider.dart';

import '../models/paths.dart';
import '../services/base_client.dart';
import '../widgets/error_dialog.dart';
import '../widgets/theme_switch.dart';

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
  bool _showErrorDetails = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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

    return Center(
      child: Container(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
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
      ),
    );
  }

  /// For large screens
  Widget _buildLargeScreen(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Center(
      child: Row(

        mainAxisAlignment: MainAxisAlignment.center,

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
      ),
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
    ThemeManager themeManager = context.watch<ThemeManager>();

    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
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
                      style: textTheme.headline5!.copyWith(),
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
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: Style.kBorderRadius,
                              color: Style.kAccentColor2.withOpacity(0.3),
                            ),
                            child: ClipRRect(
                              borderRadius: Style.kBorderRadius,
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person,
                                        color:
                                            Theme.of(context).iconTheme.color),
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
                                borderRadius: Style.kBorderRadius,
                                color: Style.kAccentColor2.withOpacity(0.3),
                              ),
                              child: ClipRRect(
                                borderRadius: Style.kBorderRadius,
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: TextFormField(
                                    controller: passwordController,
                                    obscureText:
                                        simpleUIController.isObscure.value,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock_open,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          simpleUIController.isObscure.value
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color:
                                              Theme.of(context).iconTheme.color,
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
                                        return 'Insira a password?';
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
                                style: textTheme.bodyText1!,
                                children: [
                                  TextSpan(
                                    text: " Sign up",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).iconTheme.color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          GestureDetector(
                            onTap: () {
                              context.go(Paths.forgotPwd);
                              nameController.clear();
                              emailController.clear();
                              passwordController.clear();
                              _formKey.currentState?.reset();
                              simpleUIController.isObscure.value = true;
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'Esqueceste-te da password?',
                                style: textTheme.bodyText1!,
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
        ],
      ),
    );
  }

  // Login Button
  Future<dynamic> _performLogin() async {
    var body = {
      "username": nameController.text,
      "password": passwordController.text,
    };

    var response = await BaseClient().postLogin("/login/", body);

    String tokenId = response.tokenID;
    String username = response.username;
    String role = response.role;
    String cD = response.creationDate.toString();
    String eD = response.expirationDate.toString();

    CacheDefault.cacheFactory.login(tokenId, username, cD, eD, role);
    CacheDefault.cacheFactory.set('isLoggedIn', 'true');

    SharedPreferences pref = await SharedPreferences.getInstance();

    String picUrl =
        await BaseClient().getProfilePic('/profilePic', tokenId, username);

    await pref.setString('ProfilePic', picUrl);

    context.go(Paths.homePage);

    return response;
  }

  Widget doLogin() {
    return FutureBuilder<void>(
      future: _performLogin(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: Style.kBorderRadius,
            ),
            backgroundColor: Style.kAccentColor2.withOpacity(0.3),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Style.kAccentColor1,
                ),
                SizedBox(width: 10),
                Text('Loading...',
                    style: TextStyle(color: Style.kAccentColor0)),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            String errorText = snapshot.error.toString();
            if (errorText.contains('404') || errorText.contains('403')) {
              errorText = 'Username ou password errados!';
            } else if (errorText.contains('401')) {
              errorText = 'A sua conta não está ativada!';
            } else if (errorText.contains('SocketException')) {
              errorText = 'Sem ligação à internet!';
            } else {
              errorText = 'Algo não correu bem!';
            }
            return ErrorDialog(errorText, 'Tentar novamente', context);
          } else {
            context.go(Paths.homePage);
            return Container();
          }
        } else {
          return Container();
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
        child: Text('Login', style: TextStyle(color: Style.kAccentColor0)),
      ),
    );
  }
}
