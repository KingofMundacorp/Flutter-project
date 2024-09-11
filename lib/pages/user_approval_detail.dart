import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/approve_model.dart';
import '../providers/provider.dart';
import '../widgets/Utilities.dart';
import 'user_approval_screen.dart';
import 'package:user_support_mobile/constants/d2-repository.dart';

class UserApprovalDetailPage extends StatefulWidget {
  const UserApprovalDetailPage({Key? key, required this.userApproval, required this.userPayload})
      : super(key: key);
  final UserModel userApproval;
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
          'payloadStatus': payload.status ?? '',
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
        userPayload: widget.userPayload,
        parseMessages: _parseMessages,
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  const PageContent({Key? key, required this.userApproval, this.userPayload, this.parseMessages}) : super(key: key);
  final UserModel userApproval;
  final List<Userpayload>? userPayload;
  final List<dynamic> Function()? parseMessages;

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  File? file;
  late UserModel userApproval;
  List<Userpayload>? userPayload;
  String? selectedUser;
  bool isVisible = true;
  bool isButtonEnabled = false;
  final TextEditingController _textEditingController = TextEditingController();
  bool _isDropdownShown = false;
  Color _selectButtonColor = Color(0xFF235EA0);
  bool _showDuplicatesButton = false;
  List<dynamic> _potentialDuplicates = [];
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    userApproval = widget.userApproval;
    userPayload = widget.userPayload;
  }

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
                        data: widget.userApproval.message?.subject?.split("-").last ?? '',
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
                        data: widget.userApproval.message?.message?.replaceAll('\n', '<br>') ?? '',
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
                              absorbing: _isDropdownShown,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    _selectButtonColor,
                                  ),
                                ),
                                onPressed: () {
                                  if(widget.userApproval.type == null){
                                    final accounts = widget.parseMessages?.call() ?? [];
                                    _showApprovalTableDialog(accounts);}
                                  else if (widget.userApproval.type == "deactivate" || widget.userApproval.type == "activate"){
                                    context.read<MessageModel>().approvalActRequest(widget.userApproval);
                                  }
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
                                  if (userApproval.userPayload != null && userApproval.userPayload!.isNotEmpty) {
                                    _rejectAllPayloads(context, userApproval.userPayload!);
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'Reject ALL',
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

  Future<void> _rejectAllPayloads(BuildContext context, List<Userpayload> payloads) async{
    for (var payload in payloads) {
      showDataAlert(context, payload, true);
    }
  }

  Future<void> _loading(bool isAccept, Userpayload selectedPayload) async {
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    String? name = '${selectedPayload.firstName} ${selectedPayload.surname}';

    try {
      await context.read<MessageModel>().approvalUserRequest(
        widget.userApproval,
        name,
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


  Future<void> _showApprovalTableDialog(List<dynamic> accounts) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Review User Details'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final payloadStatus = account['payloadStatus'];
                  Color? rowColor;

                  if (payloadStatus == 'CREATED') {
                    rowColor = Colors.green.withOpacity(0.2);
                  } else if (payloadStatus == 'REJECTED') {
                    rowColor = Colors.red.withOpacity(0.2);
                  } else {
                    rowColor = Colors.transparent;
                  }

                  return Container(
                    color: rowColor,
                    child: ExpansionTile(
                      title: Text(
                        '${account['SN'] ?? ''} : ${account['Names'] ?? ''}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Email: ${account['Email'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text('Phone Number: ${account['Phone Number'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text('Entry Access Level: ${account['Entry Access Level'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text('Report Access Level: ${account['Report Access Level'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                  'Action:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: payloadStatus == 'CREATED'
                                    ? Text(
                                  'Created',
                                  style: TextStyle(color: const Color.fromARGB(255, 3, 56, 4)),
                                )
                                    : payloadStatus == 'REJECTED'
                                    ? Text(
                                  'Rejected',
                                  style: TextStyle(color: const Color.fromARGB(255, 91, 13, 7)),
                                )
                                    : ElevatedButton(
                                  onPressed: () {
                                    final nameParts = (account['Names'] ?? '').split(' ');
                                    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
                                    final lastName = nameParts.length > 1 ? nameParts[1] : '';
                                    _showDropdown(context, firstName, lastName, widget.userApproval);
                                  },

                                  child: Text('Select'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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


  void _showPotentialDuplicatesPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Potential Duplicates'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _potentialDuplicates.length,
                    itemBuilder: (context, index) {
                      final user = _potentialDuplicates[index];

                      return ExpansionTile(
                        title: Text('${(index + 1).toString()} : ${user['firstName'] ?? 'Unknown'} ${user['surname'] ?? 'Unknown'}'),
                        children: <Widget>[
                          ListTile(
                            title: Text('Phone Number:'),
                            subtitle: Text(user['phoneNumber'] ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Email:'),
                            subtitle: Text(user['email'] ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Data Entry:'),
                            subtitle: Text(user['dataEntry'] ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Reports:'),
                            subtitle: Text(user['reports'] ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Username:'),
                            subtitle: Text(user['username'] ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Last Login:'),
                            subtitle: Text(user['lastLogin'] ?? 'N/A'),
                          ),
                          ListTile(
                            title: Text('Password Last Updated:'),
                            subtitle: Text(user['passwordLastUpdated'] ?? 'N/A'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future <void> _showDropdown(BuildContext context, String firstName, String lastName, UserModel userApproval) async {
    final usernameController = TextEditingController();
    String proposedUsername = _generateProposedUsername(firstName, lastName);
    usernameController.text = proposedUsername;
    _showDuplicatesButton = false;
    var SelectedPayload = userApproval.userPayload!.firstWhere(
          (payloadu) => '${payloadu.firstName} ${payloadu.surname}' == '$firstName $lastName',);

    Future <bool> _checkExistingUsername(String username) async {
      EasyLoading.show(
        status: 'Checking for Existing Username...🔄',
        maskType: EasyLoadingMaskType.black,
      );
      final response = await d2repository.httpClient.get(
        'users?filter=userCredentials.username:eq:$username&fields=id',
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.body['users']??[0]??['id'].toList();
        if (data.isEmpty) {
          EasyLoading.showSuccess('No Existing Username found');
          return false;
        } else {
          EasyLoading.showSuccess('Existing Username found... Please Change the Username');
          proposedUsername = _suggestAlternativeUsername(proposedUsername, firstName, username);
          usernameController.text = proposedUsername;
          return true;
        }
      } else {

        _showMessage(context, "Error checking existing username.");
        return true;
      }
    }

    Future<bool> _checkDuplicate(UserModel userApproval, Userpayload SelectedPayload) async {
      EasyLoading.show(
        status: 'Performing Check...🔄 ',
        maskType: EasyLoadingMaskType.black,
      );
      if (userApproval.userPayload != null && userApproval.userPayload!.isNotEmpty) {
        String? email = SelectedPayload.email;
        String? phoneNumber = SelectedPayload.phoneNumber;
        String? userApprovalId = userApproval.id;

        if (email == null || phoneNumber == null || userApprovalId == null) {
          print("Email, PhoneNumber, or UserApprovalId is missing.");
          EasyLoading.showError('Missing Data.');
          return false;
        }

        try {
          print('Phone number query: $phoneNumber');
          print('Email query: $email');

          final emailResponse = await d2repository.httpClient.get(
              'users.json?filter=email:eq:$email&fields=id,firstName,surname,email,phoneNumber,userCredentials,disabled,createdBy[name],lastUpdatedBy[name],username,lastLogin,passwordLastUpdated,organisationUnits[id,name],dataViewOrganisationUnits[id,name]'
          );

          final phoneResponse = await d2repository.httpClient.get(
              'users.json?filter=phoneNumber:eq:$phoneNumber&fields=id,firstName,surname,email,phoneNumber,userCredentials,disabled,createdBy[name],lastUpdatedBy[name],username,lastLogin,passwordLastUpdated,organisationUnits[id,name],dataViewOrganisationUnits[id,name]'
          );

          dynamic emailResponseBody;
          if (emailResponse.body is String) {
            emailResponseBody = jsonDecode(emailResponse.body);
          } else {
            emailResponseBody = emailResponse.body;
          }

          dynamic phoneResponseBody;
          if (phoneResponse.body is String) {
            phoneResponseBody = jsonDecode(phoneResponse.body);
          } else {
            phoneResponseBody = phoneResponse.body;
          }

          if (emailResponseBody is! Map<String, dynamic> || phoneResponseBody is! Map<String, dynamic>) {
            print('Error: Response bodies are not maps');
            EasyLoading.showError('Invalid Response Format');
            return false;
          }

          if ((emailResponse.statusCode == 200 || emailResponse.statusCode == 304) &&
              (phoneResponse.statusCode == 200 || phoneResponse.statusCode == 304)) {

            final totalEmailUsers = emailResponseBody['pager']['total'];
            final totalPhoneUsers = phoneResponseBody['pager']['total'];

            print('Total Email Users Found: $totalEmailUsers');
            print('Total Phone Users Found: $totalPhoneUsers');

            List<dynamic> emailUsers = emailResponseBody['users'] ?? [];
            List<dynamic> phoneUsers = phoneResponseBody['users'] ?? [];

            print('Email Users: $emailUsers');
            print('Phone Users: $phoneUsers');

            bool isDuplicateEmail = emailUsers.any((user) => (user['id'] as String?) != userApprovalId);
            bool isDuplicatePhone = phoneUsers.any((user) => (user['id'] as String?) != userApprovalId);

            if (isDuplicateEmail || isDuplicatePhone) {
              _potentialDuplicates = [...emailUsers, ...phoneUsers];

              EasyLoading.showSuccess('Succeeded check!, duplicates were found');
              return true;
            }

            EasyLoading.showSuccess('Succeeded check!, No duplicates found!');
            return false;
          } else {
            print('Failed to fetch user data for email or phone number');
            EasyLoading.showError('Failed to fetch user data');
            return false;
          }
        } catch (e, stackTrace) {
          print('An error occurred: $e');
          print('Stack trace: $stackTrace');
          EasyLoading.showError('Error during duplicate check');
          return false;
        } finally {
          EasyLoading.dismiss();
        }
      } else {
        print("No payload data available.");
        EasyLoading.showError('No payload data available.');
        return false;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Username Details for $firstName $lastName'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: 'Username (Ensure five or more Characters)'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      bool hasDuplicates = await _checkDuplicate(userApproval, SelectedPayload);
                      setState(() {
                        _showDuplicatesButton = hasDuplicates;
                      });
                    },
                    child: Text('Check Duplicate'),
                  ),
                  if (_showDuplicatesButton)
                    ElevatedButton(
                      onPressed: () => _showPotentialDuplicatesPopup(context),
                      child: Text('View Potential Duplicates'),
                    ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDataAlert(context, SelectedPayload, false);
                        },
                        child: Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool usernameExists = await _checkExistingUsername(usernameController.text);
                          if (!usernameExists){
                            _confirmUsername(context, usernameController.text, SelectedPayload);
                          }
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

  String _generateProposedUsername(String firstName, String lastName) {
    return firstName[0].toLowerCase() + lastName.toLowerCase();
  }

  String _suggestAlternativeUsername(String baseUsername, String firstName, String existingUsernames){
    String suggestion = baseUsername;

    for (int i = 1; i <= firstName.length; i++) {
      suggestion = baseUsername + firstName.substring(0, i).toLowerCase();
      if (!existingUsernames.contains(suggestion)) {
        return suggestion;
      }
    }

    int number = 1;
    while (existingUsernames.contains(suggestion)) {
      suggestion = baseUsername + number.toString();
      number++;
    }

    return suggestion;
  }

  Future<void> _confirmUsername(BuildContext context, String username, Userpayload SelectedPayload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to create a user with username $username?'),
          actions: [
            TextButton(
              onPressed: () {
                _createUser(username, SelectedPayload);
                Navigator.of(context).pop();
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

  Future <void> _createUser(String username, Userpayload SelectedPayload, {bool isAccept = true}) async {
    if (widget.userPayload != null && widget.userPayload!.isNotEmpty) {
      SelectedPayload.username = username;
      SelectedPayload.password = "Hmis@2024";
      print('User created with username: ${SelectedPayload.username}');
    }
    await _loading(isAccept, SelectedPayload);
    Navigator.of(context).pop();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future  <void> showDataAlert(BuildContext context, Userpayload SelectedPayload, bool isRejectAll, {bool isAccept = false}) async {
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
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _textEditingController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: isRejectAll? 'Provide a reason for rejection of ALL requests' : 'Provide a reason for rejection of request',
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
                      isRejectAll
                          ? 'Are you sure you want to reject the of ALL request?'
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
              child: Text(isRejectAll ? 'Reject ALL' : 'Reject'),
              onPressed: () {
                if(isRejectAll == true){
                  userApproval.actionType = "REJECTED";
                  userApproval.status ="REJECTED";
                  userApproval.replyMessage = _textEditingController.text.trim();
                }
                else if(isRejectAll == false){
                  SelectedPayload.status = "REJECTED";
                  SelectedPayload.reason = _textEditingController.text.trim();
                  SelectedPayload.password = null;
                  SelectedPayload.username = null;
                  SelectedPayload.userCredentials!.username = null;
                }
                _loading(isAccept, SelectedPayload);
                Navigator.of(context).pop();
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