import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/models/nucleos_get.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unicons/unicons.dart';
import '../constants.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/load_token.dart';

class NucleoPage extends StatefulWidget {
  final String nucleoId;

  const NucleoPage({required this.nucleoId});

  @override
  _NucleoPageState createState() => _NucleoPageState();
}

class _NucleoPageState extends State<NucleoPage> {
  late NucleosGet _nucleo;
  late String _nucleoId;
  late Token _token;
  bool isNucleoLoading = true;
  bool _isLoadingToken = true;

  @override
  void initState() {
    _nucleoId = widget.nucleoId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return Container(
        decoration: kGradientDecorationUp,
        child: TokenGetterWidget(onTokenLoaded: (Token token) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
          });
        }),
      );
    } else if (isNucleoLoading) {
      return loadNucleo();
    } else {
      return Container(
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // List of widgets common for both layouts
              var commonWidgets = [
                SizedBox(height: 8),
                Text(
                  'Descrição: ${_nucleo.description}',
                  style: TextStyle(fontSize: 30, color: kAccentColor2),
                ),
                SizedBox(height: 8),
                Text(
                  'Núcleo ${_nucleo.type}',
                  style: TextStyle(fontSize: 30, color: kAccentColor2),
                ),
                SizedBox(height: 50),
                Row(
                  children: [
                    if (_nucleo.instagram != null &&
                        _nucleo.instagram!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () => _launchURL(_nucleo.instagram!),
                          icon: Icon(FontAwesomeIcons.instagram,
                              color: kAccentColor0, size: 50.0),
                        ),
                      ),
                    if (_nucleo.facebook != null &&
                        _nucleo.facebook!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () => _launchURL(_nucleo.facebook!),
                          icon: Icon(FontAwesomeIcons.facebook,
                              color: kAccentColor0, size: 49.0),
                        ),
                      ),
                    if (_nucleo.website != null && _nucleo.website!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () => _launchURL(_nucleo.website!),
                          icon: Icon(UniconsLine.globe,
                              color: kAccentColor0, size: 50.0),
                        ),
                      ),
                  ],
                ),
              ];

              if (constraints.maxWidth > 600) {
                // Use Row for larger screen sizes
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_nucleo.url != null && _nucleo.url!.isNotEmpty)
                        Expanded(
                          child: Image.network(
                            _nucleo.url!,
                            height: 250,
                            width: 250,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nucleo.name,
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: kAccentColor0),
                            ),
                            ...commonWidgets,
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Use Column for smaller screen sizes
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_nucleo.url != null && _nucleo.url!.isNotEmpty)
                        Image.network(
                          _nucleo.url!,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(height: 16),
                      Text(
                        _nucleo.name,
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: kAccentColor0),
                      ),
                      ...commonWidgets,
                    ],
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget loadNucleo() {
    return FutureBuilder(
      future: _loadNucleo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            String errorText = snapshot.error.toString();
            return Container(
              decoration: kGradientDecorationUp,
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: kBorderRadius,
                ),
                backgroundColor: kAccentColor0.withOpacity(0.3),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorText,
                      style: const TextStyle(color: kAccentColor0),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        context.go(Paths
                            .nucleos); // Replace with the path for nucleos list
                      },
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                _nucleo = snapshot.data;
                isNucleoLoading = false;
              });
            });
            return Container();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<NucleosGet> _loadNucleo() async {
    try {
      NucleosGet nucleo = await BaseClient().getNucleo("/nucleos", _nucleoId,
          _token.tokenID, _token.username); // Replace with actual endpoint URL
      return nucleo;
    } catch (e) {
      return Future.error(e);
    }
  }
}
