import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:user_support_mobile/models/message_conversation.dart';
import 'package:user_support_mobile/pages/user_approval_screen.dart';
import 'package:user_support_mobile/providers/provider.dart';
import 'package:user_support_mobile/widgets/message_card.dart';
import 'package:user_support_mobile/widgets/show_loading.dart';
import 'package:html/parser.dart' as html_parser;


class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({Key? key}) : super(key: key);

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  List<MessageConversation> _searchResult = [];

  @override
  Widget build(BuildContext context) {
    context.read<MessageModel>().fetchUserApproval;

    String _parseHtmlString(String htmlString) {
      final document = html_parser.parse(htmlString);
      final String parsedString = html_parser.parse(document.body?.text ?? '').documentElement?.text ?? '';
      return parsedString;
    }

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: const Text('User Account'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await context.read<MessageModel>().fetchUserApproval;
              },
            ),
          ]),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MessageModel>().fetchUserApproval;
        },
        child: SafeArea(
          child: Center(
            child: Consumer<MessageModel>(
              builder: (context, value, child) {
                if (value.map.isEmpty && value.userApproval.isEmpty) {
                  return LoadingListPage();
                } else {
                  return SizedBox(
                    width: size.width * 0.99,
                    child: ListView(
                      children: <Widget>[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: _searchResult.isEmpty
                              ? value.userApproval.length
                              : _searchResult.length,
                          itemBuilder: (context, index) {
                            final messageData = value.userApproval[index];
                            return MessageBox(
                              userApproval: messageData,
                              isUserApproval: true,
                              lastMessage: DateTime.now().toString(),
                              subject: _parseHtmlString(
                                  messageData.message?.message ?? 'No Subject'),
                              displayName: _parseHtmlString(
                                  messageData.message?.subject
                                      ?.split("-")
                                      .last ?? 'No Display'),
                              messageId: messageData.id ?? 'No ID',
                              read: false,
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
    );
  }
}
