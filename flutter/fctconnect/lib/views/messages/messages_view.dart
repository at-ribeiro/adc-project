import 'package:flutter/material.dart';
import '../../services/costum_search_delegate.dart';

class MessagesView extends StatefulWidget {
  @override
  _MessagesViewState createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  List<String> messages = [
    'Hello there',
    'How are you?',
    'I\'m doing well, thanks!',
    'Glad to hear it',
    // Add more messages here...
  ];

  void addNewMessage(String newMessage) {
    setState(() {
      messages.add(newMessage);
    });
  }

  Future<void> _showNewMessageDialog() async {
    final String userName = await showSearch(
      context: context,
      delegate: CustomSearchDelegate("msg"),
    );
    
    if (userName != null && userName.isNotEmpty) {
      addNewMessage('Conversation with $userName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messaging App'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewMessageDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
