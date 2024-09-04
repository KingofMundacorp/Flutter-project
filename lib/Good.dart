import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/approve_model.dart';
import '../providers/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;

class UserApprovalDetailPage extends StatefulWidget {
  const UserApprovalDetailPage({Key? key, required this.userApproval})
      : super(key: key);
  final UserModel userApproval; // Changed to UserModel

  @override
  UserApprovalDetailPageState createState() => UserApprovalDetailPageState();
}

class UserApprovalDetailPageState extends State<UserApprovalDetailPage> {

List<Map<String, String>> _parseMessages(String htmlMessage) {
  final plainText = extractPlainText(htmlMessage); // Extract plain text from HTML
  final List<Map<String, String>> accounts = [];
  final RegExp regex = RegExp(
    r'Names:\s*(.+?)\s*Email:\s*(.+?)\s*Phone number\s*:\s*(.+?)\s*User role\s*->\s*(.+?)\s*User group\s*->\s*(.+?)\s*Entry access level\s*->\s*(.+?)\s*and Report access level\s*->\s*(.+?)(?=\d|$)', 
    multiLine: true
  );

  final matches = regex.allMatches(plainText);
  for (final match in matches) {
    accounts.add({
      'SN': (accounts.length + 1).toString(), // Serial number based on the length
      'Names': match.group(1) ?? '',
      'Email': match.group(2) ?? '',
      'Phone Number': match.group(3) ?? '',
      'User Role': match.group(4) ?? '',
      'User Group': match.group(5) ?? '',
      'Entry Access Level': match.group(6) ?? '',
      'Report Access Level': match.group(7) ?? '',
    });
  }

  return accounts;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageContent(
        userApproval: widget.userApproval,
        parseMessages: _parseMessages,
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  const PageContent({Key? key, required this.userApproval, required this.parseMessages}) : super(key: key);
  final UserModel userApproval;
  final List<Map<String, String>> Function(String) parseMessages;

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  File? file;
  String? selectedUser;
  bool isVisible = true;
  bool isButtonEnabled = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 25,
                ),
                onPressed: () async {
                  context.go('/home/user_account');
                },
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Container(
                  height: size.height,
                  width: size.width * 0.9,
                  child: ListView(
                    children: [
                      Html(
                        data: widget.userApproval.message!.subject!.split("-").last,
                        style: {
                          'body': Style(
                            color: Colors.black,
                            fontSize: FontSize(16),
                            fontWeight: FontWeight.w300,
                          ),
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Html(
                        data: widget.userApproval.message!.message!,
                        style: {
                          'body': Style(
                            color: Colors.black,
                            fontSize: FontSize(16),
                            fontWeight: FontWeight.w300,
                          ),
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        child: Row(
                          children: [
                            AbsorbPointer(
                              absorbing: false,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Color(0xFF235EA0),
                                  ),
                                ),
                                onPressed: () {
                                  final accounts = widget.parseMessages(widget.userApproval.message!.message!);
                                  _showApprovalTableDialog(accounts);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'Accept',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            AbsorbPointer(
                              absorbing: false,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                                ),
                                onPressed: () {
                                  showDataAlert(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'Reject',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _loading({bool isAccept = false}) async {
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      await context.read<MessageModel>().approvalUserRequest(
        widget.userApproval,
        message: isAccept ? null : _textEditingController.text.trim(),
      );

      bool loading = context.read<MessageModel>().isLoading;

      if (!loading) {
        EasyLoading.showSuccess('Success!');
        context.pushReplacement('/home/user_account');
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
      context.pushReplacement('/home/user_account');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _showApprovalTableDialog(List<Map<String, String>> accounts) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Review User Details'),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6, // Adjust height as needed
              maxWidth: MediaQuery.of(context).size.width * 0.9,   // Adjust width as needed
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Text('SN')),
                  DataColumn(label: Text('Names')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('User Role')),
                  DataColumn(label: Text('User Group')),
                  DataColumn(label: Text('Entry Access Level')),
                  DataColumn(label: Text('Report Access Level')),
                  DataColumn(label: Text('Action')),
                ],
                rows: accounts.map((account) {
                  return DataRow(cells: [
                    DataCell(Text(account['SN']!)),
                    DataCell(
                      Container(
                        width: 150, // Set width to your fixed length
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(account['Names']!),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 150, // Set width to your fixed length
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(account['Email']!),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 150, // Set width to your fixed length
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(account['Phone Number']!),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 150, // Set width to your fixed length
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(account['User Role']!),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 150, // Set width to your fixed length
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(account['User Group']!),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 150, // Set width to your fixed length
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(account['Entry Access Level']!),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 150, // Set width to your fixed length
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(account['Report Access Level']!),
                        ),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          
                        },
                        child: Text('Select'),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

  void showDataAlert(BuildContext context, {bool isAccept = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          content: Container(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (!isAccept)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _textEditingController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Provide a reason for rejection',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      isAccept
                          ? 'Are you sure you want to accept the request?'
                          : 'Are you sure you want to reject the request?',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(isAccept ? 'Accept' : 'Reject'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _loading(isAccept: isAccept);
              },
            ),
          ],
        );
      },
    );
  }
}

String extractPlainText(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  return document.body?.text ?? '';
}