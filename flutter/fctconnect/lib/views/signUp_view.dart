import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import 'package:responsive_login_ui/widgets/theme_switch.dart';

import '../Themes/theme_manager.dart';
import '../models/paths.dart';

import '../constants.dart';
import '../controller/simple_ui_controller.dart';

import '../services/base_client.dart';

const List<String> privacy = ["private", "public"];

const String baseUrl = 'fct-connect-estudasses.oa.r.appspot.com/rest';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  bool isExpandedRole = false;
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
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
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
    ThemeManager themeManager = context.watch<ThemeManager>();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ThemeSwitch(themeManager: themeManager),
            ),
          ),
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
            child: Text('Conecta-te aos teus colegas!',
                style: textTheme.headline5!),
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
                      borderRadius: Style.kBorderRadius,
                      color: Style.kAccentColor2.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: Style.kBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,
                                color: Theme.of(context).iconTheme.color),
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
                      borderRadius: Style.kBorderRadius,
                      color: Style.kAccentColor2.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: Style.kBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,
                                color: Theme.of(context).iconTheme.color),
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
                      borderRadius: Style.kBorderRadius,
                      color: Style.kAccentColor2.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: Style.kBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,
                                color: Theme.of(context).iconTheme.color),
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
                      borderRadius: Style.kBorderRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: Style.kBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Theme(
                          data: ThemeData(
                            popupMenuTheme: PopupMenuThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: Style.kBorderRadius,
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: Style.kBorderRadius,
                              color: Style.kAccentColor2.withOpacity(0.3),
                            ),
                            child: ClipRRect(
                              borderRadius: Style.kBorderRadius,
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  child: DropdownButtonHideUnderline(
                                    child: ExpansionTile(
                              
                                      initiallyExpanded: isExpandedRole,
                                      title: roleController.text.isEmpty
                                          ? Text(
                                              "Role",
                                            style: TextStyle(color: Theme.of(context).appBarTheme.iconTheme?.color),)
                                          : Text(
                                              roleController.text,
                                            ),
                                      leading: Icon(Icons.work,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                      children: [
                                        'Aluno',
                                        'Professor',
                                        'Externo'
                                      ].map<Widget>((String value) {
                                        return ListTile(
                                          title: Text(
                                            value,
                                            style: textTheme.bodyText1,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              roleController.text = value;
                                              isExpandedRole = false;
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
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        borderRadius: Style.kBorderRadius,
                        color: Style.kAccentColor2.withOpacity(0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: Style.kBorderRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: simpleUIController.isObscure.value,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_open,
                                  color: Theme.of(context).iconTheme.color),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  simpleUIController.isObscure.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).iconTheme.color,
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
                        borderRadius: Style.kBorderRadius,
                        color: Style.kAccentColor2.withOpacity(0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: Style.kBorderRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: TextFormField(
                            controller: passwordVerController,
                            obscureText: simpleUIController.isObscure.value,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock_open,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  simpleUIController.isObscure.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).iconTheme.color,
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
                      roleController.clear();
                      passwordController.clear();
                      _formKey.currentState?.reset();
                      simpleUIController.isObscure.value = true;
                      context.go("/login");
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Já tens uma conta?',
                        style: textTheme.bodyText1!,
                        children: [
                          TextSpan(
                            text: " Log In",
                            style: TextStyle(color: Style.kAccentColor1),
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
              "state": "INACTIVE",
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
                    } else {
                      String errorText;
                      if (snapshot.hasError) {
                        switch (snapshot.error) {
                          case '409':
                            errorText = "Username ou email já existem!";
                            break;
                          default:
                            errorText = "Algo não correu bem!";
                            break;
                        }

                        return ErrorDialog(
                            errorText, 'Voltar a tentar', context);
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pop();
                          context.go(
                              '${Paths.verifyAccount}/${nameController.text}');

                          nameController.clear();
                          emailController.clear();
                          roleController.clear();
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
