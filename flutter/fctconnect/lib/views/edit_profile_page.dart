import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:responsive_login_ui/models/profile_info.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';

import '../constants.dart';
import '../models/Token.dart';

import '../models/paths.dart';
import '../models/update_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingToken = true;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController homeTownController = TextEditingController();
  TextEditingController privacyController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController officeController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController purposeController = TextEditingController();

  late Token _token;
  final double coverHeight = 200;
  final double profileHeight = 144;
  late ScrollController _scrollController;
  late Future<ProfileInfo> _profileInfo;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    homeTownController.dispose();
    privacyController.dispose();
    emailController.dispose();
    aboutMeController.dispose();
    departmentController.dispose();
    officeController.dispose();
    courseController.dispose();
    yearController.dispose();
    purposeController.dispose();
    super.dispose();
  }

  void _onScroll() {}

  Future<ProfileInfo> _loadInfo() async {
    ProfileInfo info = await BaseClient().fetchInfo(
        "/profile", _token.tokenID, _token.username, _token.username);
    fullNameController.text = info.fullname;
    phoneNumberController.text = info.phone;
    homeTownController.text = info.city;
    privacyController.text = info.privacy;
    emailController.text = info.email;
    aboutMeController.text = info.about_me;
    departmentController.text = info.department;
    officeController.text = info.office;
    courseController.text = info.course;
    yearController.text = info.year;
    purposeController.text = info.purpose;
    return info;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
            _profileInfo = _loadInfo();
          });
        });
      });
    } else {
      return Container(
        child: Scaffold(
          body: Center(
            // Use Center here to center SingleChildScrollView
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              child: Column(
                // This Column centers its children vertically
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  if (_token.role == "ALUNO") buildInfoAlunoSection(),
                  if (_token.role == "PROFESSOR") buildInfoProfessorSection(),
                  if (_token.role == "EXTERNO") buildInfoExternoSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget buildInfoExternoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fullNameWidget(
              fullNameController: fullNameController,
            ),
            SizedBox(height: 16),
            emailWidget(emailController: emailController),
            SizedBox(height: 16),
            phoneNumberWidget(phoneNumberController: phoneNumberController),
            SizedBox(height: 16),
            cityWidget(homeTownController: homeTownController),
            SizedBox(height: 16),
            aboutMeWidget(aboutMeController: aboutMeController),
            SizedBox(height: 16),
            privacyWidget(),
            SizedBox(height: 16),
            visitWidget(purposeController: purposeController),
            SizedBox(height: 16),
            confirmButton(),
          ],
        ),
      ),
    );
  }

  Widget buildInfoProfessorSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fullNameWidget(fullNameController: fullNameController),
            SizedBox(height: 16),
            emailWidget(emailController: emailController),
            SizedBox(height: 16),
            phoneNumberWidget(phoneNumberController: phoneNumberController),
            SizedBox(height: 16),
            cityWidget(homeTownController: homeTownController),
            SizedBox(height: 16),
            aboutMeWidget(aboutMeController: aboutMeController),
            SizedBox(height: 16),
            privacyWidget(),
            SizedBox(height: 16),
            departmentWidget(),
            SizedBox(height: 16),
            officeWidget(officeController: officeController),
            SizedBox(height: 16),
            confirmButton(),
          ],
        ),
      ),
    );
  }

  Container privacyWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: Style.kBorderRadius,
        color: Style.kAccentColor2.withOpacity(0.3),
      ),
      child: ClipRRect(
        borderRadius: Style.kBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: privacyController.text.isEmpty
                    ? Text(
                        "Privacidade",
                      )
                    : Text(
                        privacyController.text,
                      ),
                leading: Icon(Icons.work),
                children: ['PUBLIC', 'PRIVATE'].map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                    ),
                    onTap: () {
                      setState(() {
                        privacyController.text = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container departmentWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: Style.kBorderRadius,
        color: Style.kAccentColor2.withOpacity(0.3),
      ),
      child: ClipRRect(
        borderRadius: Style.kBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: departmentController.text.isEmpty
                    ? Text(
                        "Departamento",
                      )
                    : Text(
                        departmentController.text,
                      ),
                leading: Icon(Icons.work),
                children: [
                  'Ciências e Engenharia do Ambiente',
                  'Ciência dos Materiais',
                  'Conservação e Restauro',
                  'Ciências Sociais Aplicadas',
                  'Ciências da Terra',
                  'Ciências da Vida',
                  'Engenharia Civil',
                  'Engenharia Eletrotécnica e de Computadores',
                  'Engenharia Mecânica e Industrial',
                  'Física',
                  'Informática',
                  'Matemática',
                  'Química'
                ].map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                      
                    ),
                    onTap: () {
                      setState(() {
                        departmentController.text = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoAlunoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fullNameWidget(fullNameController: fullNameController),
            SizedBox(height: 16),
            emailWidget(emailController: emailController),
            SizedBox(height: 16),
            phoneNumberWidget(phoneNumberController: phoneNumberController),
            SizedBox(height: 16),
            cityWidget(homeTownController: homeTownController),
            SizedBox(height: 16),
            aboutMeWidget(aboutMeController: aboutMeController),
            SizedBox(height: 16),
            privacyWidget(),
            SizedBox(height: 16),
            departmentWidget(),
            SizedBox(height: 16),
            courseWidget(),
            SizedBox(height: 16),
            yearWidget(),
            SizedBox(height: 16),
            confirmButton(),
          ],
        ),
      ),
    );
  }

  Container yearWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: Style.kBorderRadius,
        color: Style.kAccentColor2.withOpacity(0.3),
      ),
      child: ClipRRect(
        borderRadius: Style.kBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: yearController.text.isEmpty
                    ? Text(
                        "Ano",
                      )
                    : Text(
                        yearController.text,
                      ),
                leading: Icon(Icons.work),
                children: ['1º Ano', '2º Ano', '3º Ano', '4º Ano', '5º Ano']
                    .map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                 
                    ),
                    onTap: () {
                      setState(() {
                        yearController.text = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container courseWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: Style.kBorderRadius,
        color: Style.kAccentColor2.withOpacity(0.3),
      ),
      child: ClipRRect(
        borderRadius: Style.kBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: courseController.text.isEmpty
                    ? Text(
                        "Curso",
                      )
                    : Text(
                        courseController.text,
                      ),
                leading: Icon(Icons.work),
                children: [
                  'Biologia Celular e Molecular',
                  'Bioquímica',
                  'Conservação-Restauro',
                  'Engenharia do Ambiente',
                  'Engenharia Biomédica',
                  'Engenharia Civil',
                  'Engenharia Eletrotécnica e de Computadores',
                  'Engenharia Física',
                  'Engenharia Geológica',
                  'Engenharia e Gestão Industrial',
                  'Engenharia Informática',
                  'Engenharia de Materiais',
                  'Engenharia Mecânica',
                  'Engenharia de Micro e Nanotecnologias',
                  'Engenharia Química e Biológica',
                  'Matemática',
                  'Matemática Aplicada à Gestão do Risco',
                  'Tecnologia Agro-Industrial',
                  'Química Aplicada'
                ].map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                    
                    ),
                    onTap: () {
                      setState(() {
                        courseController.text = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton confirmButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          UpdateData data = UpdateData(
            username: _token.username,
            fullname: fullNameController.text,
            email: emailController.text,
            about_me: aboutMeController.text,
            phone: phoneNumberController.text,
            city: homeTownController.text,
            privacy: privacyController.text,
            department: departmentController.text,
            course: courseController.text,
            year: yearController.text,
            purpose: purposeController.text,
            office: officeController.text,
          );
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return FutureBuilder(
                future: BaseClient().updateUser(
                    "/update", data, _token.tokenID, _token.username),
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
                      return ErrorDialog(showErrorMessage, 'ok', context);
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
                              'Perfil atualizado com sucesso!',
                              style: TextStyle(color: Style.kAccentColor0),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.go(Paths.myProfile);
                              },
                              child: Text('ok'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  return Container();
                },
              );
            },
          );
        }
      },
      child: const Text('Guardar'),
    );
  }

  Widget buildButton({
    required String text,
    required int value,
  }) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
}

class visitWidget extends StatelessWidget {
  const visitWidget({
    super.key,
    required this.purposeController,
  });

  final TextEditingController purposeController;

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
              prefixIcon: Icon(Icons.school),
              hintText: 'Propósito da visita',
            ),
            controller: purposeController,
          ),
        ),
      ),
    );
  }
}

class officeWidget extends StatelessWidget {
  const officeWidget({
    super.key,
    required this.officeController,
  });

  final TextEditingController officeController;

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
            style: TextStyle(),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.local_post_office_outlined,
              ),
              hintText: 'Escritório',
            ),
            controller: officeController,
          ),
        ),
      ),
    );
  }
}

class aboutMeWidget extends StatelessWidget {
  const aboutMeWidget({
    super.key,
    required this.aboutMeController,
  });

  final TextEditingController aboutMeController;

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
            style: TextStyle(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: 'Sobre Mim',
            ),
            controller: aboutMeController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecione o seu Sobre Mim';
              } else
                return null;
            },
          ),
        ),
      ),
    );
  }
}

class cityWidget extends StatelessWidget {
  const cityWidget({
    super.key,
    required this.homeTownController,
  });

  final TextEditingController homeTownController;

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
            style: TextStyle(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_city),
              hintText: 'Cidade',
            ),
            controller: homeTownController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecione a sua cidade';
              } else {
                return null;
              }
            },
          ),
        ),
      ),
    );
  }
}

class phoneNumberWidget extends StatelessWidget {
  const phoneNumberWidget({
    super.key,
    required this.phoneNumberController,
  });

  final TextEditingController phoneNumberController;

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
            style: TextStyle(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone),
              hintText: 'Número de telemóvel',
            ),
            controller: phoneNumberController,
          ),
        ),
      ),
    );
  }
}

class emailWidget extends StatelessWidget {
  const emailWidget({
    super.key,
    required this.emailController,
  });

  final TextEditingController emailController;

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
            style: TextStyle(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email),
              hintText: 'Email',
            ),
            controller: emailController,
          ),
        ),
      ),
    );
  }
}

class fullNameWidget extends StatelessWidget {
  const fullNameWidget({
    super.key,
    required this.fullNameController,
  });

  final TextEditingController fullNameController;

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
              prefixIcon: Icon(Icons.person),
              hintText: 'Nome Completo',
            ),
            controller: fullNameController,
          ),
        ),
      ),
    );
  }
}
