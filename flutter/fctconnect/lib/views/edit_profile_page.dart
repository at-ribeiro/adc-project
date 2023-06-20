import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:responsive_login_ui/models/profile_info.dart';

import '../constants.dart';
import '../models/Token.dart';

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
      return Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          controller: _scrollController,
          children: <Widget>[
            const SizedBox(height: 40),
            if (_token.role == "ALUNO") buildInfoAlunoSection(),
            if (_token.role == "PROFESSOR") buildInfoProfessorSection(),
            if (_token.role == "EXTERNO") buildInfoExternoSection(),
            const SizedBox(height: 32),
          ],
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
            TextFormField(
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
                  return 'Selecione o seu nome completo';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail),
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: emailController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleciona o seu email';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: 'Número de telemóvel',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: phoneNumberController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Seleciona o seu número de telemóvel';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_city),
                hintText: 'Cidade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: homeTownController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Seleciona a sua cidade';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'Sobre Mim',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: aboutMeController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Selecione o seu Sobre Mim';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: privacyController.text.isEmpty
                    ? Text(
                        "Privacidade",
                        style: TextStyle(color: kAccentColor0),
                      )
                    : Text(privacyController.text,
                        style: TextStyle(color: kAccentColor0)),
                leading: Icon(Icons.work, color: kAccentColor0),
                children: ['PUBLIC', 'PRIVATE'].map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                      style: TextStyle(color: kAccentColor0),
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
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.school),
                hintText: 'Pro´pósito da visita',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: purposeController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Selecione o seu motivo de visita';
                } else {
                  return null;
                }
              },
            ),
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
            TextFormField(
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
                  return 'Selecione o seu nome completo';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail),
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: emailController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleciona o seu email';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: 'Número de telemóvel',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: phoneNumberController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Seleciona o seu número de telemóvel';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_city),
                hintText: 'Cidade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: homeTownController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Seleciona a sua cidade';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'Sobre Mim',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: aboutMeController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Selecione o seu Sobre Mim';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: privacyController.text.isEmpty
                    ? Text(
                        "Privacidade",
                        style: TextStyle(color: kAccentColor0),
                      )
                    : Text(privacyController.text,
                        style: TextStyle(color: kAccentColor0)),
                leading: Icon(Icons.work, color: kAccentColor0),
                children: ['PUBLIC', 'PRIVATE'].map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                      style: TextStyle(color: kAccentColor0),
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
            SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: departmentController.text.isEmpty
                    ? Text(
                        "Departamento",
                        style: TextStyle(color: kAccentColor0),
                      )
                    : Text(departmentController.text,
                        style: TextStyle(color: kAccentColor0)),
                leading: Icon(Icons.work, color: kAccentColor0),
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
                      style: TextStyle(color: kAccentColor0),
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
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.local_post_office),
                hintText: 'Escritório',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: officeController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Selecione o seu escritório';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            confirmButton(),
          ],
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
            TextFormField(
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
                  return 'Selecione o seu nome completo';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail),
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: emailController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleciona o seu email';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: 'Número de telemóvel',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: phoneNumberController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Seleciona o seu número de telemóvel';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_city),
                hintText: 'Cidade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: homeTownController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Seleciona a sua cidade';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'Sobre Mim',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              controller: aboutMeController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return 'Selecione o seu Sobre Mim';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: privacyController.text.isEmpty
                    ? Text(
                        "Privacidade",
                        style: TextStyle(color: kAccentColor0),
                      )
                    : Text(privacyController.text,
                        style: TextStyle(color: kAccentColor0)),
                leading: Icon(Icons.work, color: kAccentColor0),
                children: ['PUBLIC', 'PRIVATE'].map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                      style: TextStyle(color: kAccentColor0),
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
            SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: departmentController.text.isEmpty
                    ? Text(
                        "Departamento",
                        style: TextStyle(color: kAccentColor0),
                      )
                    : Text(departmentController.text,
                        style: TextStyle(color: kAccentColor0)),
                leading: Icon(Icons.work, color: kAccentColor0),
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
                      style: TextStyle(color: kAccentColor0),
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
            SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: courseController.text.isEmpty
                    ? Text(
                        "Curso",
                        style: TextStyle(color: kAccentColor0),
                      )
                    : Text(courseController.text,
                        style: TextStyle(color: kAccentColor0)),
                leading: Icon(Icons.work, color: kAccentColor0),
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
                      style: TextStyle(color: kAccentColor0),
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
            SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: ExpansionTile(
                title: yearController.text.isEmpty
                    ? Text(
                        "Ano",
                        style: TextStyle(color: kAccentColor0),
                      )
                    : Text(yearController.text,
                        style: TextStyle(color: kAccentColor0)),
                leading: Icon(Icons.work, color: kAccentColor0),
                children: ['1º Ano', '2º Ano', '3º Ano', '4º Ano', '5º Ano']
                    .map<Widget>((String value) {
                  return ListTile(
                    title: Text(
                      value,
                      style: TextStyle(color: kAccentColor0),
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
            SizedBox(height: 16),
            confirmButton(),
          ],
        ),
      ),
    );
  }

  ElevatedButton confirmButton() {
    return ElevatedButton(
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
                      AlertDialog(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 10),
                            Text('A sua informação foi mudada com sucesso!'),
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
      child: const Text('Confirmar'),
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
