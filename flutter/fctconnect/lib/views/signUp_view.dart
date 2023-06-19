import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_login_ui/models/register_user.dart';
import 'package:responsive_login_ui/services/session_manager.dart';

import '../models/paths.dart';
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
  TextEditingController roleController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordVerController = TextEditingController();
  TextEditingController privacyController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    SessionManager.storeSession('session', '/signup');
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    roleController.dispose();
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

    return Container(
      decoration: kGradientDecoration,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return _buildLargeScreen(size, simpleUIController, theme);
                } else {
                  return _buildSmallScreen(size, simpleUIController, theme);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: _buildMainBody(size, simpleUIController, theme),
        ),
      ],
    );
  }

  Widget _buildSmallScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return SingleChildScrollView(
      child: Center(
        child: _buildMainBody(size, simpleUIController, theme),
      ),
    );
  }

  Widget _buildMainBody(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Sign Up',
              style: textTheme.headline2!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Conecta-te aos teus colegas!',
              style: textTheme.headline5!.copyWith(
                color: kAccentColor0,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                            color: kAccentColor0,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: 'Username',
                            border: InputBorder.none,
                          ),
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione um username';
                            } else if (value.length < 4) {
                              return 'Username tem de ter pelo menos 4 caracteres';
                            } else if (value.length > 20) {
                              return 'Username tem um máximo de 20 caracteres';
                            }

                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
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
                            color: kAccentColor0,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: 'Nome Completo',
                            border: InputBorder.none,
                          ),
                          controller: fullNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o nome completo';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),

                  /// Email
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
                            color: kAccentColor0,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: 'Email',
                            border: InputBorder.none,
                          ),
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione um email';
                            } else if (!value.contains('@')) {
                              return 'Selecione um email válido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: kAccentColor0.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Theme(
                          data: ThemeData(
                            canvasColor: kAccentColor0,
                            popupMenuTheme: PopupMenuThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            child: DropdownButtonHideUnderline(
                              child: ExpansionTile(
                                title: roleController.text.isEmpty
                                    ? Text(
                                        "Role",
                                        style: TextStyle(color: kAccentColor0),
                                      )
                                    : Text(roleController.text,
                                        style: TextStyle(color: kAccentColor0)),
                                leading: Icon(Icons.work, color: kAccentColor0),
                                children: ['Aluno', 'Professor', 'Externo']
                                    .map<Widget>((String value) {
                                  return ListTile(
                                    title: Text(
                                      value,
                                      style: TextStyle(color: kAccentColor0),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        roleController.text = value;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: kAccentColor0.withOpacity(0.2),
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
                                return 'Selecione uma password';
                              } else if (value.length < 6) {
                                return 'Password tem de ter pelo menos 6 caracteres';
                              } else if (value.length > 30) {
                                return 'Password tem no máximo 30 caracteres';
                              }

                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: kAccentColor0.withOpacity(0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: TextFormField(
                            controller: passwordVerController,
                            obscureText: simpleUIController.isObscure.value,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_open,
                              ),
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
                              hintText: 'Verificação da Password',
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecione uma password';
                              } else if (passwordVerController.text !=
                                  passwordController.text) {
                                return 'As passwords não coincidem';
                              }

                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Ao criar uma conta está a concordar com a nossa Política de Privacidade e Termos de Uso',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: size.height * 0.02),
                  signUpButton(theme),
                  SizedBox(height: size.height * 0.03),
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
                        text: 'Já tens uma conta?',
                        children: [
                          TextSpan(
                            text: " Log In",
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
    );
  }

  Widget signUpButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            var _body = {
              "username": nameController.text,
              "fullname": fullNameController.text,
              "password": passwordController.text,
              "passwordV": passwordVerController.text,
              "email": emailController.text,
              "role": roleController.text.toUpperCase(),
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
                          context.go(Paths.login);

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
