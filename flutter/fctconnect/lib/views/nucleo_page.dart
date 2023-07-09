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
    TextTheme textTheme = Theme.of(context).textTheme;
    if (_isLoadingToken) {
      return Container(
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
        child: Scaffold(
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // List of widgets common for both layouts
              var commonWidgets = [
                SizedBox(height: 8),
                Text(
                  ' ${_nucleo.description}',
                  style: textTheme.headline5,
                ),
                SizedBox(height: 8),
                Text(
                  'Núcleo ${_nucleo.type}',
                  style: textTheme.headline5,
                ),
                SizedBox(height: 50),
                Row(
                  children: [
                    if (_nucleo.instagram != null &&
                        _nucleo.instagram!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => _launchURL(_nucleo.instagram!),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Icon(FontAwesomeIcons.instagram, size: 50.0),
                          ),
                        ),
                      ),
                    if (_nucleo.facebook != null &&
                        _nucleo.facebook!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => _launchURL(_nucleo.facebook!),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Icon(FontAwesomeIcons.facebook, size: 49.0),
                          ),
                        ),
                      ),
                    if (_nucleo.website != null && _nucleo.website!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => _launchURL(_nucleo.website!),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Icon(UniconsLine.globe, size: 50.0),
                          ),
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
                              style: textTheme.headline2?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                        style: textTheme.headline2?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
              decoration: Style.kGradientDecorationUp,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: Style.kBorderRadius,
                ),
                backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorText,
                      style: TextStyle(color: Style.kAccentColor0),
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
