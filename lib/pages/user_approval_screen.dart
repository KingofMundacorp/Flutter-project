import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message_conversation.dart';
import '../widgets/message_card.dart';
import '../widgets/show_loading.dart';
import 'package:user_support_mobile/providers/provider.dart';
import 'package:html/parser.dart' as html_parser;

class UserApprovalScreen extends StatefulWidget {
  const UserApprovalScreen({Key? key}) : super(key: key);

  @override
  _UserApprovalScreenState createState() => _UserApprovalScreenState();
}

class _UserApprovalScreenState extends State<UserApprovalScreen> {
  List<MessageConversation> _searchResult = [];


  String _parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    final String parsedString = html_parser.parse(document.body?.text ?? '').documentElement?.text ?? '';
    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    context.read<MessageModel>().fetchUserApproval;

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('User account'),
      ),
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
                          physics: const ClampingScrollPhysics(),
                          itemCount: _searchResult.isEmpty
                              ? value.userApproval.length
                              : _searchResult.length,
                          itemBuilder: (context, index) {
                            final messageData = value.userApproval[index];
                            return Row(
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.9, // Adjust as needed
                                        ),
                                        child: MessageBox(
                                          userApproval: messageData,
                                          isUserApproval: true,
                                          lastMessage: DateTime.now().toString(),
                                          subject: _parseHtmlString(messageData.message?.message ?? 'No Subject'),
                                          displayName: _parseHtmlString(messageData.message?.subject?.split("-").last ?? 'No Display'),
                                          messageId: messageData.id ?? 'No ID',
                                          read: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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