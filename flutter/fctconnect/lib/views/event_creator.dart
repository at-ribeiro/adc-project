import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import '../models/Token.dart';
import '../models/event_data.dart';

class EventCreator extends StatefulWidget {
  final Token token;

  const EventCreator({Key? key, required this.token}) : super(key: key);

  @override
  State<EventCreator> createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator> {
  late Token _token;
  Uint8List? _imageData;
  late String _fileName;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startingDateController = TextEditingController();
  final TextEditingController _endingDateController = TextEditingController();

  late DateTime _startingDate;
  late DateTime _endingDate;

  late ScrollController _scrollController;

  @override
  void initState() {
    _token = widget.token;
    _scrollController = ScrollController();
    _startingDate = DateTime.now();
    _endingDate = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startingDateController.dispose();
    _endingDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = Uint8List.fromList(fileData);
        _fileName = pickedFile.path.split('/').last;
      });
    }
  }

  bool _isImageLoading = false;

  Widget _buildImagePreview() {
    if (_imageData != null) {
      return Container(
          width: 500, // Adjust the width as needed
          height: 500, // Adjust the height as needed
          child: Image.memory(_imageData!, fit: BoxFit.contain),
          );
    } else if (_isImageLoading) {
      return CircularProgressIndicator();
    } else {
      return SizedBox.shrink();
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = Uint8List.fromList(fileData);
        _fileName = pickedFile.path.split('/').last;
      });
    }
  }

  Future<void> _showDatePicker(
      BuildContext context, TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text = selectedDate.toString();
        if (controller == _startingDateController) {
          _startingDate = selectedDate;
        } else if (controller == _endingDateController) {
          _endingDate = selectedDate;
        }
      });
    }
  }

  bool _validateDates() {
    if (_startingDate == null || _endingDate == null) {
      return false;
    }
    return _startingDate.isBefore(_endingDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Registration'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              TextField(
                controller: _startingDateController,
                decoration: InputDecoration(
                  labelText: 'Starting Date',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        _showDatePicker(context, _startingDateController),
                    icon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              TextField(
                controller: _endingDateController,
                decoration: InputDecoration(
                  labelText: 'Ending Date',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        _showDatePicker(context, _endingDateController),
                    icon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              ElevatedButton(
                onPressed: () {
                  _pickImage();
                },
                child: const Text('Selecion uma foto para o icon do Evento'),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () {
                    _takePicture();
                  },
                  child: const Text('Take Photo'),
                ),
              _buildImagePreview(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_validateDates()) {
                    // Dates are valid, proceed with event creation
                    EventData event = EventData(
                      creator: _token.username,
                      title: _titleController.text,
                      imageData: _imageData,
                      fileName: _fileName,
                      description: _descriptionController.text,
                      start: _startingDate.millisecondsSinceEpoch,
                      end: _endingDate.millisecondsSinceEpoch,
                    );
                    var response = BaseClient().createEvent("/events", _token.tokenID, event);

                    // TODO: Handle event creationf
                  } else {
                    // Dates are invalid, show an error message
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Invalid Dates'),
                        content: Text(
                            'Please ensure the starting date is before the ending date.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
