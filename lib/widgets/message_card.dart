import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../pages/data_approval_detail.dart';

import '../pages/testing_page.dart';
import '../providers/provider.dart';

import '../models/approve_model.dart';

class MessageBox extends StatelessWidget {
  MessageBox({
    required this.lastMessage,
    this.isDataApproval = false,
    this.dataApproval,
    this.isUserApproval = false,
    this.userApproval,
    required this.messageId,
    required this.read,
    required this.displayName,
    required this.subject,
    Key? key,
  }) : super(key: key);

  final String messageId;
  final bool read;
  final bool? isDataApproval;
  final ApproveModel? dataApproval;
  final bool? isUserApproval;
  final UserModel? userApproval;
  final String subject;
  final String displayName;
  final String lastMessage;

  @override
  Widget build(BuildContext context) {
    final fetchedData = Provider.of<MessageModel>(context);
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        fetchedData.initialValue();
        fetchedData.fetchMessageThreadsById(messageId);

        // Navigate based on approval type
        if (isDataApproval == true && dataApproval != null) {
          context.go('/home/request_details', extra: dataApproval);
        } else if (isUserApproval == true && userApproval != null) {
          context.go('/home/user_account_details', extra: userApproval);
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 10, 1),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/arrow.svg',
                          semanticsLabel: 'Acme Logo',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight:
                              read ? FontWeight.w400 : FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 17.0,
                              overflow: TextOverflow.ellipsis, // Ellipsis for overflow
                            ),
                            maxLines: 1, // Ensure text stays on one line
                            softWrap: false, // Prevent wrapping
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0), // Space between displayName and subject
                    Text(
                      subject,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Allow two lines for subject
                      softWrap: true, // Allow wrapping if it fits within two lines
                      style: TextStyle(
                        fontWeight: read ? FontWeight.w400 : FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4.0), // Space between subject and lastMessage

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
