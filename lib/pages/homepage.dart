import 'package:flutter/material.dart';

import 'package:user_support_mobile/models/message.dart';
import 'package:user_support_mobile/services/services.dart';
import 'package:user_support_mobile/widgets/drawer_nav.dart';
import 'package:user_support_mobile/widgets/message_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Message> fetchMessage;
  @override
  void initState() {
    super.initState();
    fetchMessage = fetchAllMessage();
  }

  Widget thumbnail() => Container(
        color: Colors.black12,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging'),
        backgroundColor: Color(0xFF1D5288),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FutureBuilder<Message>(
          future: fetchMessage,
          builder: (context, snapshot) {
            return ListView.builder(
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.hasData) {
                    return const Center(
                      child: MessageCardWidget(
                          thumbnail: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              'J',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          userName: 'Javier Kamara II',
                          subject: 'Removal of New Data',
                          messageContent:
                              'This is a concern about new data to be assigned to my new center',
                          publishDate: '20 may',
                          readDuration: '2 min ago'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          },
        ),
      ),
      drawer: const NavigationDrawer(title: 'Javier Kamara'),
    );
  }
}
