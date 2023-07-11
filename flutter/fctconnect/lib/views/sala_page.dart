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
import '../models/ReservationData.dart';

class SalaPage extends StatefulWidget {
  final String salaId;
  //final List<ReservationData> reservations;

  const SalaPage({required this.salaId});

  @override
  State<SalaPage> createState() => _SalaPageState();
}

class _SalaPageState extends State<SalaPage> {
  late SalaGetData _sala;
  late String _salaId;
  late Token _token;
  late List<ReservationData> _reservations;
  bool isSalaLoading = true;
  bool _isLoadingToken = true;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    _salaId = widget.salaId;
    //_reservations = widget.reservations;
    super.initState();
  }

  DateTime _selectedDay = DateTime.now(); // The currently selected day
  
  // This method gets the count of reservations for a specific hour and day.
  int getReservationCountForHour(String hour) {
    return _reservations.where((res) => res.hour == getSelectedHourAsInt(hour) && res.day == getSelectedDayAsInt()).length;
  }
  
  // This generates a list of all hours in a day.
  List<String> generateHours() {
    return List<String>.generate(24, (int index) {
      return index.toString().padLeft(2, '0') + ':00';
    });
  }

  // Calculates the difference in days between the selected day and today
  int getSelectedDayAsInt() {
    return _selectedDay.difference(DateTime.now()).inDays;
  }

  // Retrieves the selected hour as an integer
  int getSelectedHourAsInt(String hour) {
    return int.parse(hour.split(':')[0]);
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
              _loadReservations();
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sala.name,
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: kAccentColor0),
                ),
                SizedBox(height: 8),
                Text(
                  'Building: ${_sala.building}',
                  style: TextStyle(fontSize: 16, color: kAccentColor2),
                ),
                SizedBox(height: 8),
                Text(
                  'Capacity: ${_sala.capacity}',
                  style: TextStyle(fontSize: 16, color: kAccentColor2),
                ),
                SizedBox(height: 16),
                // Display selected day
                Text(
                  'Selected Day: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                  style: TextStyle(fontSize: 16, color: kAccentColor1),
                ),
                SizedBox(height: 16),
                // Date Picker Button
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDay,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 7)), // Can select up to a year into the future.
                    );
                    
                    if (date != null) {
                      setState(() {
                        _selectedDay = date;
                      });
                    }
                  },
                  child: Text('Select day'),
                ),
                SizedBox(height: 16),
                // Time Slots
                Column(
                  children: generateHours().map((hour) {
                    final count = getReservationCountForHour(hour);
                    
                    return ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Reservations for $hour'),
                              content: Text('There are $count reservations at this time.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('OK'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ReservationData reservation = ReservationData(
                                      user: _token.username, 
                                      room: _sala.name,  
                                      hour: getSelectedHourAsInt(hour),
                                      day: getSelectedDayAsInt(),
                                      );
                                    BaseClient().addReservation("/rooms", _token.username, _token.tokenID, _salaId, reservation);
                                    _refreshReservations();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Reserve Slot'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Hour: $hour, Reservations: $count'),
                    );
                  }).toList(),
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
                        context.go(Paths.buildings);
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

  void _loadReservations() async {
    List<ReservationData> reservations = await BaseClient()
          .getReservations("/rooms", _salaId, _token.tokenID, _token.username);
    if (mounted) {
      setState(() {
        _reservations = reservations;
        if (reservations.isNotEmpty) {
         // _lastDisplayedSalaTimestamp = salas.last.start;
        }
      });
    }
  }

  Future<void> _refreshReservations() async {
    //_lastDisplayedSalaTimestamp = DateTime.now().millisecondsSinceEpoch;
    List<ReservationData> latestReservations = await BaseClient()
      .getReservations("/rooms", _salaId, _token.tokenID, _token.username);
    setState(() {
      _reservations = latestReservations;
      if (latestReservations.isNotEmpty) {
     //   _lastDisplayedSalaTimestamp = latestSalas.last.start;
      }
    });
  }

  Future<SalaGetData> _loadSala() async {
    try {
      SalaGetData sala = await BaseClient()
          .getSala("/rooms", _token.tokenID, _token.username, _salaId);
      return sala;
    } catch (e) {
      return Future.error(e);
    }
  }

}