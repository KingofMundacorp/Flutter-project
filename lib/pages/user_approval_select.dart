
import 'package:flutter/material.dart';
import '../models/approve_model.dart';
import '../pages/user_approval_detail.dart';


class ApprovalTableDialogPage extends StatelessWidget {
  final List<dynamic> accounts;
  final UserModel userApproval;
  final List<Userpayload>? userPayload;
  final Function(BuildContext, String, String, UserModel) showDropdown;

  const ApprovalTableDialogPage({
    Key? key,
    required this.accounts,
    required this.userApproval,
    required this.userPayload,
    required this.showDropdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
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
    );
  }
}