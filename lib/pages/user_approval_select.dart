
import 'package:flutter/material.dart';
import 'package:user_support_mobile/pages/ShowDropdownPage.dart';
import '../models/approve_model.dart';
import '../pages/user_approval_detail.dart';


class ApprovalTableDialogPage extends StatefulWidget {
  final List<dynamic> accounts;
  final UserModel userApproval;
  final List<Userpayload>? userPayload;

  const ApprovalTableDialogPage({
    Key? key,
    required this.accounts,
    required this.userApproval,
    required this.userPayload,
  }) : super(key: key);

    @override
  State<ApprovalTableDialogPage> createState() => _ApprovalTableDialogPageState();
}

class _ApprovalTableDialogPageState extends State<ApprovalTableDialogPage> {
  late UserModel userApproval;
  List<Userpayload>? userPayload;

  @override
  void initState() {
    super.initState();
    userApproval = widget.userApproval;
    userPayload = widget.userPayload;
  }


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
          itemCount: widget.accounts?.length,
          itemBuilder: (context, index) {
            final account = widget.accounts?[index];
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
                                           Navigator.push(
                                                         context,
                                                    MaterialPageRoute(
                                                    builder: (context) => ShowDropdownPage(
                                                            firstName: firstName,
                                                            lastName: lastName,
                                                            userApproval: widget.userApproval,
                                                            userPayload: widget.userPayload,
                                               ),
                                             ),
                                              );
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