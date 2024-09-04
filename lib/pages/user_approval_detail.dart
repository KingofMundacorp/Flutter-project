import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../widgets/Utilities.dart';
import 'user_approval_screen.dart';
import '../models/approve_model.dart';
import '../providers/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;

class UserApprovalDetailPage extends StatefulWidget {
  const UserApprovalDetailPage({Key? key, required this.userApproval})
      : super(key: key);
  final UserModel userApproval;

  @override
  UserApprovalDetailPageState createState() => UserApprovalDetailPageState();
}

class UserApprovalDetailPageState extends State<UserApprovalDetailPage> {
  String extractPlainText(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    return document.body?.text ?? '';
  }

  List<Map<String, String>> _parseMessages(String htmlMessage) {
    final plainText = extractPlainText(htmlMessage);
    final List<Map<String, String>> accounts = [];
    final RegExp regex = RegExp(
        r'Names:\s*(.+?)\s*Email:\s*(.+?)\s*Phone number\s*:\s*(.+?)\s*User role\s*->\s*(.+?)\s*User group\s*->\s*(.+?)\s*Entry access level\s*->\s*(.+?)\s*and Report access level\s*->\s*(.+?)(?=\d|$)',
        multiLine: true);

    final matches = regex.allMatches(plainText);
    for (final match in matches) {
      accounts.add({
        'SN': (accounts.length + 1).toString(),
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
  const PageContent(
      {Key? key, required this.userApproval, required this.parseMessages})
      : super(key: key);
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
  bool _isDropdownShown = false; // Tracks whether the dropdown is shown
  Map<String, dynamic> _selectedAccount = {}; // Holds the selected account details
  Color _selectButtonColor = Color(0xFF235EA0); // Initial color of the select button
  Map<String, bool> _rejectedAccounts = {};
  Map<String, bool> _confirmedAccounts = {};

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
                        data: widget.userApproval.message!.subject!
                            .split("-")
                            .last,
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
                              absorbing: _isDropdownShown, // Disable button if dropdown is shown
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    _selectButtonColor,
                                  ),
                                ),
                                onPressed: () {
                                  final accounts = widget.parseMessages(
                                      widget.userApproval.message!.message!);
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
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.red),
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
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
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
                    // Ensure that 'payload' is correctly cast to List<PayloadUser>?
                    List<PayloadUser>? payload = account['payload'] as List<PayloadUser>?;

                    // Determine the color based on the status field within the payload
                    Color rowColor = Utils.determineRowColor(payload);

                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        return rowColor; // Use the determined color
                      }),
                      cells: [
                        DataCell(Text(account['SN']!)),
                        DataCell(
                          Container(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(account['Names']!),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(account['Email']!),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(account['Phone Number']!),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(account['User Role']!),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(account['User Group']!),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(account['Entry Access Level']!),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(account['Report Access Level']!),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isDropdownShown = true;
                                selectedUser = account['Email']!;
                                _selectedAccount = account;
                                _selectButtonColor = Colors.grey;
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Change to the color of your choice
                            ),
                            child: Text(
                              'Select',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      setState(() {
        if (_selectedAccount.isNotEmpty) {
          _proposeUsername(_selectedAccount['Email']!);
        }
      });
    });
  }

  void _proposeUsername(String email) {
    final usernameSuggestion = email.split('@')[0];

    setState(() {
      _textEditingController.text = usernameSuggestion;
      isButtonEnabled = false;
    });

    _showUserApprovalBottomSheet(usernameSuggestion);
  }

  void _showUserApprovalBottomSheet(String usernameSuggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Checkbox(
                        value: isButtonEnabled,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isButtonEnabled = newValue ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: 'Enter username',
                          ),
                          onChanged: (String text) {
                            setState(() {
                              isButtonEnabled = false; // Disable Confirm button initially
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle username duplication check
                          if (_textEditingController.text.isNotEmpty) {
                            setState(() {
                              isButtonEnabled = true; // Enable Confirm button after duplication check
                            });
                          }
                        },
                        child: Text('Check Duplicate'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                      showConfirmApprovalAlert(context);
                    }
                        : null, // Button is disabled if not confirmed
                    child: Text('Confirm'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDataAlert(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Reject'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showDataAlert(BuildContext context) async {
    TextEditingController reasonController = TextEditingController();
    bool isReasonEntered = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Please enter a reason'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          isReasonEntered = value.trim().isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter the reason for rejection',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog without rejecting
                  },
                ),
                TextButton(
                  onPressed: isReasonEntered
                      ? () {
                    Navigator.of(context).pop(); // Close the dialog and proceed with rejection
                    setState(() {
                      _textEditingController.text = reasonController.text; // Set rejection reason
                      _rejectedAccounts[_selectedAccount['id']] = true; // Mark the account as rejected
                      _confirmedAccounts[_selectedAccount['id']] = false; // Ensure it's not marked as confirmed
                    });
                    _loading(isAccept: false); // Pass the reason to the loading function
                  }
                      : null, // Disable the button if no reason is entered
                  child: Text('Reject'),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showConfirmApprovalAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Approval'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to confirm approval of this request?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without confirming
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog and proceed with confirmation
                setState(() {
                _confirmedAccounts[_selectedAccount['id']] = true; // Mark the account as confirmed
                _rejectedAccounts[_selectedAccount['id']] = false; // Ensure it's not marked as rejected
                });
                _loading(isAccept: true); // Pass the action to the loading function
                },
              // Call the method to handle the approval
            ),
          ],
        );
      },
    );
  }

  // Function to extract plain text from HTML content
  String extractPlainText(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    return document.body?.text ?? '';
  }
}