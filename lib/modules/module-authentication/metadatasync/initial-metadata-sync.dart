// ignore_for_file: file_names, use_build_context_synchronously, empty_catches

import 'dart:async';

import 'package:d2_touch/modules/auth/entities/user.entity.dart';
import 'package:d2_touch/modules/metadata/program/entities/program.entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_support_mobile/constants/d2-repository.dart';
import 'package:user_support_mobile/helpers/app_helper.dart';
import 'package:user_support_mobile/widgets/text_widgets/text_widget.dart';

class HomeMetadataSync extends StatefulWidget {
  final User? loggedInUser;

  const HomeMetadataSync({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  State<HomeMetadataSync> createState() => _HomeMetadataSyncState();
}

class _HomeMetadataSyncState extends State<HomeMetadataSync>
    with TickerProviderStateMixin {
  downloadMetaData() async {
    if (!await AppHelpers.isConnected()) {
      AppHelpers.noInternetWarning();
      AppHelpers.logout(dontShowMessage: true);
      return;
    }

    // setState(() {
    //   processesRunning = true;
    //   // processPercent = 1.0;
    // });

    // setState(() {
    //   currentProcess = "Syncing organisation units";
    // });
    // try {
    //   if (!await AppHelpers.isConnected()) {
    //     return;
    //   }
    //   await d2repository.organisationUnitModule.organisationUnit
    //       .download((p0, p1) {
    //     setState(() {
    //       // processPercent = p0.percentage / 800;
    //       currentSubProcess = p0.message;
    //     });
    //   });
    // } catch (error) {}

    setState(() {
      currentProcess = "Syncing data store keys";
      succesfullProcesses.add("Organisation units synced");
    });

    try {
      var response =
          await d2repository.httpClient.get('dataStore/dhis2-user-support');
      List<String> keys = response.body;

      for (String key in keys) {
        await d2repository.dataStore.dataStoreQuery
            .byNamespace('dhis2-user-support')
            .byKey(key)
            .download((p0, p1) {
          setState(() {
            processPercent = (p0.percentage + 10) / 800;
            currentSubProcess = p0.message;
          });
        });
      }
    } catch (error) {
      setState(() {
        currentProcess = error.toString();
      });
    }

    setState(() {
      currentProcess = "Syncing menu";
      succesfullProcesses.add("Locations synced");
    });

    try {
      await d2repository.dataStore.dataStoreQuery
          .byNamespace('eidsr')
          .byKey('mobile-menu')
          .download((p0, p1) {
        setState(() {
          processPercent = (p0.percentage + 200) / 800;
          currentSubProcess = p0.message;
        });
      });
    } catch (error) {
      setState(() {
        currentProcess = error.toString();
      });
    }
    try {
      await d2repository.dataStore.dataStoreQuery
          .byNamespace('eidsr')
          .byKey('instance')
          .download((p0, p1) {
        setState(() {
          processPercent = (p0.percentage + 200) / 800;
          currentSubProcess = p0.message;
        });
      });
    } catch (error) {
      setState(() {
        currentProcess = error.toString();
      });
    }

    setState(() {
      currentProcess = "Syncing datasets";
      succesfullProcesses.add("Data store keys synced");
    });

    // try {
    //   await d2repository.dataSetModule.dataSet
    //       .whereIn(attribute: "code", values: dataSetCodes, merge: false)
    //       .download((p0, p1) {
    //     setState(() {
    //       processPercent = (p0.percentage + 100) / 800;
    //       currentSubProcess = p0.message;
    //     });
    //   });
    // } catch (error) {
    //   //
    // }

    try {
      List<Program> programs = await d2repository.programModule.program.get();
      for (Program program in programs) {
        await d2repository.programModule.programRelationship
            .byFromProgram(program.id ?? '')
            .download((progress, complete) {
          setState(() {
            // processPercent = (progress.percentage + 100) / 800;
            currentSubProcess = progress.message;
          });
        });
      }
    } catch (error) {}

    setState(() {
      currentProcess = "Syncing Attribute Reserved Values";
      succesfullProcesses.add("Program configurations synced");
    });

    try {
      List<Program> programs = await d2repository.programModule.program
          .where(attribute: "code", value: "IMMEDIATE_REPORT")
          .get();

      String? programId = programs.isNotEmpty ? programs[0].id : null;

      if (programId == null) {
        setState(() {
          processPercent = 800;
          currentProcess = "Saving relationship types";
        });
      } else {
        await d2repository.programModule.programRelationship
            .byFromProgram(programId)
            .download((p0, p1) {
          setState(() {
            processPercent = (p0.percentage + 700) / 800;
            currentSubProcess = p0.message;
          });
        });
      }
    } catch (error) {
      //
    }

    setState(() {
      succesfullProcesses.add("Program relationship types synced");
      currentProcess = "";
      processesRunning = false;
    });

    await d2repository.userModule.userGroup.download((p0, p1) => {});

    await updateMetadataSyncTime();
    context.go('/home');
  }

  Future<void> updateMetadataSyncTime() async {
    DateTime syncCompletedAt = DateTime.now();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("last_metadata_sync",
        "${syncCompletedAt.year}-${syncCompletedAt.month}-${syncCompletedAt.day} ${syncCompletedAt.hour}:${syncCompletedAt.minute}");
  }

  @override
  void initState() {
    super.initState();

    downloadMetaData();
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  String currentProcess = "";
  String currentSubProcess = "";
  double processPercent = 0;
  bool processesRunning = false;
  int numberOfProcesses = 5;
  double progresIndicatorFractions = 0.0;
  List<String> succesfullProcesses = [];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Colors.blue,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 14),
                      TextWidget(
                        text: 'User support',
                        size: 25,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Lottie.asset('assets/lottie/lottie.json',
                          width: size.width * 0.55,
                          height: size.height * 0.55,
                          repeat: true,
                          animate: true)
                    ],
                  ),
                  SizedBox(
                      height: size.height * 0.1,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${(processPercent * 100).round()}%",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            Text(
                              currentSubProcess,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12.0),
                            ),
                          ])),
                  // AppHelpers.getVersionDetails(textColor: Colors.black)
                ],
              ),
            )),
        onWillPop: () async {
          return false;
        });
  }
}
