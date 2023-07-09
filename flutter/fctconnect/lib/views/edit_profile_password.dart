import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/models/change_pwd_data.dart';

import 'package:responsive_login_ui/models/profile_info.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../models/Token.dart';

import '../models/paths.dart';
import '../models/update_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class EditProfilePassword extends StatefulWidget {
  const EditProfilePassword({Key? key}) : super(key: key);

  @override
  State<EditProfilePassword> createState() => _EditProfilePasswordState();
}

class _EditProfilePasswordState extends State<EditProfilePassword> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingToken = true;

  late Token _token;
  late ScrollController _scrollController;
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController passwordVController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    passwordVController.dispose();
  }

  void _onScroll() {}

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
          });
        });
      });
    } else {
      return Container(
        child: Scaffold(
          body: Container(
            // Use Center here to center SingleChildScrollView
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              child: Column(
                // This Column centers its children vertically
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [const SizedBox(height: 32), buildPasswordSection()],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget buildPasswordSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            oldPasswordWidget(oldPasswordController: oldPasswordController),
            SizedBox(height: 20),
            newPasswordWidget(
                newPasswordController: newPasswordController,
                passwordVController: passwordVController),
            SizedBox(height: 20),
            passwordVWidget(
                passwordVController: passwordVController,
                newPasswordController: newPasswordController),
            SizedBox(height: 20),
            confirmButton(),
          ],
        ),
      ),
    );
  }

  ElevatedButton confirmButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ChangePwdData data = ChangePwdData(
            oldPassword: oldPasswordController.text,
            newPassword: newPasswordController.text,
            passwordV: passwordVController.text,
          );
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return FutureBuilder(
                future: BaseClient().changePwd(
                  "/changepwd",
                  data,
                  _token.tokenID,
                  _token.username,
                ),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.kBorderRadius,
                      ),
                      backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'A carregar...',
                            style: TextStyle(color: Style.kAccentColor0),
                          ),
                          const SizedBox(height: 15),
                          CircularProgressIndicator(
                            color: Style.kAccentColor1,
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (snapshot.hasError) {
                      String showErrorMessage;
                      switch (snapshot.error) {
                        default:
                          showErrorMessage =
                              "Algo não está certo, tente outra vez!";
                          break;
                      }
                      return ErrorDialog(showErrorMessage, 'Ok', context);
                    } else {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: Style.kBorderRadius,
                        ),
                        backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Password atualizada com sucesso!',
                              style: TextStyle(color: Style.kAccentColor0),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await BaseClient().doLogout(
                                  "/logout",
                                  _token.username,
                                  _token.tokenID,
                                );
                                CacheDefault.cacheFactory.logout();
                                CacheDefault.cacheFactory.delete('isLoggedIn');
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove('ProfilePic');
                                context.go(Paths.login);
                              },
                              child: Text('Ok'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        }
      },
      child: Center(
        child: const Text(
          'Guardar',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class oldPasswordWidget extends StatelessWidget {
  const oldPasswordWidget({
    super.key,
    required this.oldPasswordController,
  });

  final TextEditingController oldPasswordController;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              prefixIcon:
                  Icon(Icons.key, color: Theme.of(context).iconTheme.color),
              hintText: 'Password',
              border: InputBorder.none,
            ),
            controller: oldPasswordController,
          ),
        ),
      ),
    );
  }
}

class newPasswordWidget extends StatelessWidget {
  const newPasswordWidget(
      {super.key,
      required this.newPasswordController,
      required this.passwordVController});

  final TextEditingController newPasswordController;
  final TextEditingController passwordVController;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                prefixIcon:
                    Icon(Icons.key, color: Theme.of(context).iconTheme.color),
                hintText: 'Nova Password',
                border: InputBorder.none,
              ),
              controller: newPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '    Selecione uma password';
                } else if (value.length < 6) {
                  return '    Password tem de ter pelo menos 6 caracteres';
                } else if (value.length > 30) {
                  return '    Password tem no máximo 30 caracteres';
                } else if (value != passwordVController.text) {
                  return '    Passwords não coincidem';
                } else {
                  return null;
                }
              }),
        ),
      ),
    );
  }
}

class passwordVWidget extends StatelessWidget {
  const passwordVWidget({
    super.key,
    required this.passwordVController,
    required this.newPasswordController,
  });

  final TextEditingController passwordVController;
  final TextEditingController newPasswordController;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                prefixIcon:
                    Icon(Icons.key, color: Theme.of(context).iconTheme.color),
                hintText: 'Confirmar Nova Password',
                border: InputBorder.none,
              ),
              controller: passwordVController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '    Selecione uma password';
                } else if (value.length < 6) {
                  return '    Password tem de ter pelo menos 6 caracteres';
                } else if (value.length > 30) {
                  return '    Password tem no máximo 30 caracteres';
                } else if (value != newPasswordController.text) {
                  return '    Passwords não coincidem';
                } else {
                  return null;
                }
              }),
        ),
      ),
    );
  }
}
