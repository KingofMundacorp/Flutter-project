import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message_conversation.dart';
import '../providers/provider.dart';
import '../widgets/message_card.dart';
import '../widgets/show_loading.dart';

class DataApprovalScreen extends StatefulWidget {
  const DataApprovalScreen({Key? key}) : super(key: key);

  @override
  _DataApprovalScreenState createState() => _DataApprovalScreenState();
}

class _DataApprovalScreenState extends State<DataApprovalScreen> {
  List<MessageConversation> _searchResult = [];
  @override
  Widget build(BuildContext context) {
    context.read<MessageModel>().fetchDataApproval;

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Form requests'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MessageModel>().fetchDataApproval;
        },
        child: SafeArea(
          child: Center(
            child: Consumer<MessageModel>(
              builder: (context, value, child) {
                if (value.map.isEmpty && value.dataApproval.isEmpty) {
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
                              ? value.dataApproval.length
                              : _searchResult.length,
                          itemBuilder: (context, index) {
                            final messageData = value.dataApproval[index];
                            return MessageBox(
                                dataApproval: messageData,
                                isDataApproval: true,
                                lastMessage: DateTime.now().toString(),
                                subject: messageData.message!.message!,
                                displayName: messageData.message!.subject!
                                    .split("-")
                                    .last,
                                read: false,
                                messageId: messageData.id!);
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
