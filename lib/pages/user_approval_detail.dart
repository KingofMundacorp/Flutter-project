import 'dart:io';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user_support_mobile/constants/d2-repository.dart';
import 'package:flutter/material.dart';

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
  const UserApprovalDetailPage({Key? key, required this.userApproval, required this.userPayload})
      : super(key: key);
  final UserModel? userApproval;
  final List<Userpayload>? userPayload;



  @override
  UserApprovalDetailPageState createState() => UserApprovalDetailPageState();
}

class UserApprovalDetailPageState extends State<UserApprovalDetailPage> {
  List<dynamic> _parseMessages() {
    return _addAccountData(widget.userApproval);
  }

  List<dynamic> _addAccountData(UserModel? userModel) {
    final List<dynamic> account = [];
    if (userModel?.userPayload != null) {
      for (var payload in userModel!.userPayload!) {
        account.add({
          'SN': (account.length + 1).toString(),
          'Names': '${payload.firstName ?? ''} ${payload.surname ?? ''}',
          'Email': payload.email ?? '',
          'Phone Number': payload.phoneNumber ?? '',
          'Entry Access Level': _getDataEntryAccessLevel(payload),
          'Report Access Level': _getReportAccessLevel(payload),
        });
      }
    }
    return account;
  }

  String _getDataEntryAccessLevel(Userpayload payload) {
    final organisationUnitNames = payload.organisationUnits
        ?.map((unit) => unit.name)
        .toList() ?? [];

    final childrenNames = payload.organisationUnits
        ?.expand((unit) => unit.children?.map((child) => child.name) ?? <String>[])
        .toList() ?? [];

    return [...organisationUnitNames, ...childrenNames].join(', ');
  }

  String _getReportAccessLevel(Userpayload payload) {
    final dataViewOrganisationUnitNames = payload.dataViewOrganisationUnits
        ?.map((unit) => unit.name)
        .toList() ?? [];

    final childrenNames = payload.dataViewOrganisationUnits
        ?.expand((unit) => unit.children?.map((child) => child.name) ?? <String>[])
        .toList() ?? [];

    return [...dataViewOrganisationUnitNames, ...childrenNames].join(', ');

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
  const PageContent({Key? key, this.userApproval, this.userPayload, this.parseMessages}) : super(key: key);
  final UserModel? userApproval;
  final Userpayload? userPayload;
  final List<dynamic> Function()? parseMessages;


  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  File? file;
  UserModel? userApproval;
  Userpayload? userPayload;
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
                        data: widget.userApproval!.message!.subject!.split("-").last,
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
                        data: widget.userApproval!.message!.message!,

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
                                  final accounts = widget.parseMessages!();

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

  void _loading(bool isAccept) async {
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      await context.read<MessageModel>().approvalUserRequest(
        widget.userApproval!,

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


  void _showApprovalTableDialog(List<dynamic> accounts) {
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
                      DataColumn(label: Text('Entry Access Level')),
                      DataColumn(label: Text('Report Access Level')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: accounts.map((account) {
                      return DataRow(cells: [
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
                              dynamic nameParts = account['Names']!.split(' ');
                              dynamic firstName = nameParts[0];
                              dynamic lastName = nameParts.length > 1 ? nameParts[1] : '';
                              _showDropdown(context, firstName, lastName);
                            },
                            child: Text('Select'),
                          ),
                        ),
                      ]);
                    }).toList(),
                  )
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDropdown(BuildContext context, dynamic firstName, dynamic lastName) {
    TextEditingController usernameController = TextEditingController();
    dynamic proposedUsername = _generateProposedUsername(firstName, lastName);
    usernameController.text = proposedUsername;

    void _checkDuplicate(dynamic username) async {
      try {
        final response = await d2repository.httpClient.get(
            'users?filter=userCredentials.username:eq:${proposedUsername}&fields=id'
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['users'].isEmpty) {

            _showMessage(context, "No duplicate username found.");
          } else {

            proposedUsername = _suggestAlternativeUsername(proposedUsername, firstName, username);
            usernameController.text = proposedUsername;
            _checkDuplicate(proposedUsername);
          }
        } else {

          _showMessage(context, "Error checking duplicate username.");
        }
      } catch (e) {

        _showMessage(context, "An error occurred: ${e.toString()}");
      }
    }

    _checkDuplicate(proposedUsername);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Username'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _checkDuplicate(usernameController.text);
                    },
                    child: Text('Check Duplicate'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDataAlert(context);
                        },
                        child: Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _confirmUsername(context, usernameController.text);
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  String _generateProposedUsername(dynamic firstName, dynamic lastName) {
    return firstName[0].toLowerCase() + lastName.toLowerCase();

  }

  String _suggestAlternativeUsername(dynamic baseUsername, dynamic firstName, dynamic existingUsernames) {
    String suggestion = baseUsername;

    for (int i = 1; i <= firstName.length; i++) {
      suggestion = baseUsername + firstName.substring(0, i).toLowerCase();
      if (!existingUsernames.containsKey(suggestion)) {
        return suggestion;
      }
    }

    int number = 1;
    while (existingUsernames.containsKey(suggestion)) {
      suggestion = baseUsername + number.toString();
      number++;
    }

    return suggestion;
  }

  void _confirmUsername(BuildContext context, dynamic username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to create a user with username $username?'),
          actions: [
            TextButton(
              onPressed: () {
                userPayload?.username = username;
                userPayload?.password = "Hmis@2024";
                print('User created with username: ${userPayload?.username}');
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _createUser(username);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _createUser(String username, {bool isAccept = true}) {
    print('User created with username: ${userPayload?.username}');
    _loading(isAccept);
  }


  void _showMessage(BuildContext context, String messageon) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageon)));
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
                context.go('/home/user_account');
                _loading(isAccept);
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


