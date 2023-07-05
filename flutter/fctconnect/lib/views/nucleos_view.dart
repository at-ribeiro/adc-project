import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/models/nucleos_get.dart';
import '../constants.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../widgets/circular_indicator.dart';
import '../widgets/error_dialog.dart';

class NucleosView extends StatefulWidget {
  @override
  _NucleosViewState createState() => _NucleosViewState();
}

class _NucleosViewState extends State<NucleosView> {
  bool _isLoadingToken = true;
  List<NucleosGet> _nucleos = [];
  late Token _token;

  String? _currentNucleoType;
  bool _isLoadingNucleos = false;

  Future<List<NucleosGet>> _loadNucleos(String nucleoType) async {
    List<NucleosGet> news = await BaseClient()
        .getNucleos('/nucleos', _token.tokenID, _token.username, nucleoType);
    return news;
  }

  void _onNucleoTypeButtonPressed(String nucleoType) {
    setState(() {
      _currentNucleoType = nucleoType;
      _isLoadingNucleos = true;
    });
    _loadNucleos(nucleoType).then((loadedNucleos) {
      setState(() {
        _nucleos = loadedNucleos;
        _isLoadingNucleos = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(
        onTokenLoaded: (Token token) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
          });
        },
      );
    } else {
      return Container(
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _currentNucleoType == 'Academico'
                              ? kPrimaryColor
                              : kAccentColor1),
                    ),
                    onPressed: () => _onNucleoTypeButtonPressed('Academico'),
                    child: Text(
                      'Academico',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentNucleoType == 'Academico'
                              ? kAccentColor0
                              : kPrimaryColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _currentNucleoType == 'Cultural'
                              ? kPrimaryColor
                              : kAccentColor1),
                    ),
                    onPressed: () => _onNucleoTypeButtonPressed('Cultural'),
                    child: Text(
                      'Cultural',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentNucleoType == 'Cultural'
                              ? kAccentColor0
                              : kPrimaryColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _currentNucleoType == 'Recreativo'
                              ? kPrimaryColor
                              : kAccentColor1),
                    ),
                    onPressed: () => _onNucleoTypeButtonPressed('Recreativo'),
                    child: Text('Recreativo' ,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentNucleoType == 'Recreativo'
                              ? kAccentColor0
                              : kPrimaryColor),),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _currentNucleoType == 'Associação-Parceira'
                              ? kPrimaryColor
                              : kAccentColor1),
                    ),
                    onPressed: () =>
                        _onNucleoTypeButtonPressed('Associação-Parceira'),
                    child: Text('Associação-Parceira' ,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentNucleoType == 'Associação-Parceira'
                              ? kAccentColor0
                              : kPrimaryColor),),
                  ),
                ],
              ),
              Expanded(
                child: _isLoadingNucleos
                    ? Center(child: CircularProgressIndicatorCustom())
                    : _currentNucleoType == null
                        ? Center(child: Text("Select a category"))
                        : buildNucleoTab(context,
                            nucleoType: _currentNucleoType!),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget buildNucleoTab(BuildContext context, {required String nucleoType}) {
    var filteredNucleos =
        _nucleos.where((nucleo) => nucleo.type == nucleoType).toList();
    var screenWidth = MediaQuery.of(context).size.width;

    int columns;
    if (screenWidth < 600) {
      columns = 2; // phones
    } else if (screenWidth < 900) {
      columns = 3; // tablets
    } else {
      columns = 4; // larger screens
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filteredNucleos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              context.go(Paths.nucleos + "/${filteredNucleos[index].name}");
            },
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: kBorderRadius,
                border: Border.all(
                  width: 1.5,
                  color: kAccentColor0.withOpacity(0.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kAccentColor2.withOpacity(0.1),
                      borderRadius: kBorderRadius,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: kBorderRadius,
                              child: AspectRatio(
                                aspectRatio: 1.2,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Image.network(
                                    filteredNucleos[index].url,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Center(
                              child: Text(
                                filteredNucleos[index].name,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: kAccentColor0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
