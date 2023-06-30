import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/services/base_client.dart';

import '../constants.dart';
import '../models/Token.dart';
import '../models/sala_get_data.dart';
import '../models/paths.dart';
import '../services/load_token.dart';

class SalaPage extends StatefulWidget {
  final String salaId;

  const SalaPage({required this.salaId});

  @override
  _SalaPageState createState() => _SalaPageState();
}

class _SalaPageState extends State<SalaPage> {

  late SalaGetData _sala;

  late String _salaId;
  late Token _token;
  bool isSalaLoading = true;
  bool _isLoadingToken = true;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    _salaId = widget.salaId;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return Container(
        decoration: kGradientDecorationUp,
        child: TokenGetterWidget(onTokenLoaded: (Token token) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
          });
        }),
      );
    } else if (isSalaLoading) {
      return loadSala();
    } else {


      return Container(
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_sala.url != null) ...[
                  Image.network(
                    _sala.url!,
                    fit: BoxFit.cover,
                    height: 400, // Set the desired height for the banner image
                    width: double.infinity,
                  ),
                ] else ...[
                  //ir buscar a default
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sala.title,
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: kAccentColor0),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${_sala.description}',
                        style: TextStyle(fontSize: 16, color: kAccentColor2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Creator: ${_sala.creator}',
                        style: TextStyle(fontSize: 16, color: kAccentColor2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Capacity: ${_sala.capacity}',
                        style: TextStyle(fontSize: 16, color: kAccentColor2),
                      ),
                      SizedBox(height: 16),

                      Container(
                        height: 300,
                        width: 500,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                              target: LatLng(_sala.lat, _sala.lng), zoom: 16),
                          markers: _markers,
                        ),
                      ),

                      if (_sala.creator == _token.username) showQrcodeOrnot(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  showQrcodeOrnot() {
    return Column(
      children: [
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: kBorderRadius,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      child: ClipRRect(
                        borderRadius: kBorderRadius,
                        //child: Image.network(

                          //_sala.qrCodeUrl!,

                          //fit: BoxFit.cover,
                        //),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: SizedBox(
            height: 100.0, // Replace with your desired height
            // Adjust the fit property as needed
            //child: Image.network(

              //_sala.qrCodeUrl!,

            //),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget loadSala() {
    return FutureBuilder(
      future: _loadSala(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            String errorText = snapshot.error.toString();
            if (errorText.contains('404'))
              errorText = 'Sala não encontrada';
            else if (errorText.contains('401'))
              errorText = 'Não tem permissões para aceder a esta sala';
            else if (errorText.contains('500'))
              errorText = 'Erro interno do servidor';
            else
              errorText = 'Algo não correu bem';

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
                        context.go(Paths.salas);
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
                _sala = snapshot.data;
                isSalaLoading = false;
                Marker salaMarker = Marker(
                    markerId: MarkerId('Sala'),
                    position: LatLng(_sala.lat, _sala.lng));
                _markers.add(salaMarker);
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

  Future<SalaGetData> _loadSala() async {
    try {
      SalaGetData sala = await BaseClient()
          .getSala("/qrcode/get", _salaId, _token.tokenID, _token.username);
      return sala;
    } catch (e) {
      return Future.error(e);
    }
  }
}