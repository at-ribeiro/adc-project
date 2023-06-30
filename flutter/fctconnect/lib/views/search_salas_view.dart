import 'package:flutter/material.dart';

class SearchSalaView extends StatefulWidget {
  @override
  _SearchSalaView createState() => _SearchSalaView();
}

class _SearchSalaView extends State<SearchSalaView> {
  List<String> salas = [];
  List<String> filteredSalas = [];

  TextEditingController salaController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  void addSala() {
    String newSala = salaController.text;
    if (newSala.isNotEmpty) {
      setState(() {
        salas.add(newSala);
        salaController.clear();
        filteredSalas = List.from(salas);
      });
    }
  }

  void filterSalas(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSalas = List.from(salas);
      } else {
        filteredSalas = salas
            .where((sala) => sala.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> personSalas = ['Sala 1', 'Sala 2', 'Sala 3'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Sala Registration'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: salaController,
              decoration: InputDecoration(
                labelText: 'Sala Name',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: addSala,
            child: Text('Register Sala'),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchSalaView(),
                  ),
                );
              },
              child: Text('Pesquisar outras salas')),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSalas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredSalas[index]),
                );
              },
            ),
          ),
          PersonSalasWidget(
            personName: 'John Doe',
            salas: personSalas,
          ),
        ],
      ),
    );
  }
}

class PersonSalasWidget extends StatelessWidget {
  final String personName;
  final List<String> salas;

  PersonSalasWidget({
    required this.personName,
    required this.salas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Salas for $personName:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: salas.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(salas[index]),
            );
          },
        ),
      ],
    );
  }
}
