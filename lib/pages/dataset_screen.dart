import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:user_support_mobile/models/message_conversation.dart';
import 'package:user_support_mobile/pages/data_approval_screen.dart';
import 'package:user_support_mobile/providers/provider.dart';
import 'package:user_support_mobile/widgets/message_card.dart';
import 'package:user_support_mobile/widgets/show_loading.dart';

class DatasetScreen extends StatefulWidget {
  const DatasetScreen({Key? key}) : super(key: key);

  @override
  State<DatasetScreen> createState() => _DatasetScreenState();
}

class _DatasetScreenState extends State<DatasetScreen> {
  List<MessageConversation> _searchResult = [];
  @override
  Widget build(BuildContext context) {
    context.read<MessageModel>().fetchDataApproval;

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: const Text('Form requests'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await context.read<MessageModel>().fetchDataApproval;
              },
            ),
          ]),
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