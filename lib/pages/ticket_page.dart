import 'package:flutter/material.dart' hide NavigationDrawer;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'compose_painter.dart';

import '../models/message_conversation.dart';
import '../pages/compose_page.dart';
import '../providers/provider.dart';
import '../widgets/drawer_nav.dart';
import '../widgets/message_card.dart';
import '../widgets/show_loading.dart';

class TicketPage extends StatefulWidget {
  static const routeName = '/ticket-page';
  const TicketPage({Key? key}) : super(key: key);

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  List<MessageConversation> _searchResult = [];
  @override
  Widget build(BuildContext context) {
    context.read<MessageModel>().fetchTicketMessages;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   title: const Text('Inbox'),
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          // context.read<MessageModel>().initialValue();
          await context.read<MessageModel>().fetchTicketMessages;
        },
        child: SafeArea(
          child: Center(
            child: Consumer<MessageModel>(
              builder: (context, value, child) {
                if (value.map.isEmpty && !value.error) {
                  return LoadingListPage();
                } else {
                  return value.error
                      ? Text(
                          'Oops Somthing is wrong ${value.errorMessage}',
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(
                          width: size.width * 0.95,
                          child: ListView(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                height: 20,
                              ),
                              searchBarWidget(context, value),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, top: 8.0),
                                child: Text(
                                  'Ticket',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: _searchResult.isEmpty
                                    ? value.ticketMessage.length
                                    : _searchResult.length,
                                itemBuilder: (context, index) {
                                  final messageData = _searchResult.isEmpty
                                      ? value.ticketMessage[index]
                                      : _searchResult[index];
                                  return Slidable(
  // Replacing 'actionPane' with 'startActionPane' and 'endActionPane'
  startActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: <Widget>[
      SlidableAction(
        onPressed: (context) {
          // Handle approve action
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: Icons.approval,
        label: 'Approve',
      ),
    ],
  ),
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: <Widget>[
      SlidableAction(
        onPressed: (context) {
          // Handle reject action
        },
        backgroundColor: Colors.black45,
        foregroundColor: Colors.white,
        icon: Icons.block,
        label: 'Reject',
      ),
      SlidableAction(
        onPressed: (context) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to delete?'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('deleted message'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {},
                          ),
                        ),
                      );
                      value.deleteMessage(value.ticketMessage[index].id);
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),
    ],
  ),
  child: MessageBox(
    lastMessage: messageData.lastMessage,
    subject: messageData.subject,
    displayName: messageData.lastSender != null
        ? messageData.lastSender!.displayName
        : 'System',
    read: value.ticketMessage[index].read,
    messageId: messageData.id,
  ),
);

                                },
                              ),
                            ],
                          ),
                        );
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, ComposePainter.routeName),
        child: const Icon(Icons.add),
      ),
      drawer: const NavigationDrawer(),
    );
  }

  Container searchBarWidget(BuildContext context, MessageModel value) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Colors.white,
          border: Border.all(color: Colors.black26)),
      child: Row(
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            child: IconButton(
              splashColor: Colors.grey,
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Expanded(
            child: TextField(
              cursorColor: Colors.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  hintText: "Search..."),
              onChanged: (query) {
                query = query.toLowerCase();

                if (query.trim().isNotEmpty) {
                  setState(() {
                    _searchResult = value.ticketMessage.where((element) {
                      final messageTitle = element.displayName.toLowerCase();
                      return messageTitle.contains(query);
                    }).toList();
                  });
                } else {
                  _searchResult = [];
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
