import 'dart:convert';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import 'package:responsive_login_ui/widgets/theme_switch.dart';

import '../Themes/theme_manager.dart';
import '../models/paths.dart';

import '../constants.dart';
import '../controller/simple_ui_controller.dart';

import '../services/base_client.dart';

class ForgotPwdCodeView extends StatefulWidget {
  final String query;

  const ForgotPwdCodeView({Key? key , required this.query}) : super(key: key);

  @override
  State<ForgotPwdCodeView> createState() => _ForgotPwdCodeViewState();
}

class _ForgotPwdCodeViewState extends State<ForgotPwdCodeView> {
  bool isExpandedRole = false;
  TextEditingController codeController = TextEditingController();
  TextEditingController pwdController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    codeController.dispose();
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
              'Recupera a tua conta!',
              style: textTheme.headline2!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text('Introduz o código que te foi enviado por email e a nova password.',
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
                            prefixIcon: Icon(Icons.code,
                                color: Theme.of(context).iconTheme.color),
                            hintText: 'Código',
                            border: InputBorder.none,
                          ),
                          controller: codeController,
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
                            prefixIcon: Icon(Icons.password,
                                color: Theme.of(context).iconTheme.color),
                            hintText: 'Nova Password',
                            border: InputBorder.none,
                          ),
                          controller: pwdController,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  SizedBox(height: size.height * 0.01),
                  verifyButton(theme),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget verifyButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return FutureBuilder(
                  future: BaseClient()
                      .forgotPWDCode("/forgotpwd", widget.query , codeController.text, hashPWD(pwdController.text)),
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
                          case '404':
                            errorText = "Utilizador ou email não encontrado!";
                            break;
                          case '400':
                            errorText = "Informação inválida!";
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
                          context.go(Paths.login);

                          codeController.clear();
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
        child: const Text('Confirmar'),
      ),
    );
  }

  String hashPWD(String text) {
    var bytes = utf8.encode(text);

    var hash = sha512.convert(bytes);

    return hash.toString();
  }
}
