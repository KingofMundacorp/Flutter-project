import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'user_approval_screen.dart';

import '../models/approve_model.dart';
import '../providers/provider.dart';
import 'package:flutter_html/flutter_html.dart';


class UserApprovalDetailPage extends StatefulWidget {
  const UserApprovalDetailPage({Key? key, required this.userApproval})
      : super(key: key);
  final UserModel? userApproval;

  @override
  UserApprovalDetailPageState createState() => UserApprovalDetailPageState();
}

class UserApprovalDetailPageState extends State<UserApprovalDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageContent(
        userApproval: widget.userApproval!,
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  const PageContent({Key? key, required this.userApproval}) : super(key: key);
  final UserModel userApproval;

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
                  //  await context.read<MessageModel>().fetchUserApproval;
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
                                  showDataAlert(context, isAccept: true);
                                  // Start loading action
                                 //_loading();
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
        // if (isLoading)
        //   SizedBox(
        //     width: size.width,
        //     height: size.height,
        //     child: AbsorbPointer(
        //       absorbing: isLoading,
        //       child: Container(
        //         color: Colors.white.withOpacity(0.2),
        //         child: Center(
        //             child: CircularProgressIndicator(
        //           strokeWidth: 10,
        //         )),
        //       ),
        //     ),
        //   )
        // else
        //   Container(),
      ],
    );
  }

  void _loading({bool isAccept = false}) async {
    // Show loading indicator
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      // Call approvalUserRequest and handle response
      await context.read<MessageModel>().approvalUserRequest(
        widget.userApproval,
        message: isAccept ? null : _textEditingController.text.trim(),
      );

      // After processing, check if still loading
      bool loading = context.read<MessageModel>().isLoading;

      if (!loading) {
        // Show success message and navigate to the user account page
        EasyLoading.showSuccess('Success!');
        context.pushReplacement('/home/user_account');
      }
    } catch (e) {
      // Handle errors and show an appropriate message
      EasyLoading.showError('Error: ${e.toString()}');
      context.pushReplacement('/home/user_account');
    } finally {
      EasyLoading.dismiss();
    }
  }

// .

  showDataAlert(BuildContext context, {bool isAccept = false}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            content: Container(
              // height: 300,
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
                          maxLines: 8,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Reasons',
                          ),
                        ),
                      ),
                    if (isAccept)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'You are about to accept.',
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Start loading action
                          //_loading();
                          if (isAccept) {
                            context
                                .read<MessageModel>()
                                .approvalUserRequest(widget.userApproval);
                            // Navigator.of(context).pop();
                          } else {
                            // context.read<MessageModel>().approvalUserRequest(
                            //     widget.userApproval,
                            //     message: _textEditingController.text.trim());
                            // context.read<MessageModel>().approvalUserRequest(
                            //     widget.userApproval,
                            //     message: _textEditingController.text.trim());
                            _loading();
                          }
                          await context.read<MessageModel>().fetchUserApproval;
                          //Navigator.of(context).pop();
                          // Future.delayed(const Duration(milliseconds: 500), () {
                          //   Navigator.pushNamed(
                          //       context, UserApprovalScreen.routeName);
                          // });
                        },
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.black,
                          // fixedSize: Size(250, 50),
                        ),
                        child: Text(
                          "Confirm",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
