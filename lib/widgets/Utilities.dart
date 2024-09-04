
import 'package:flutter/material.dart';

import '../models/approve_model.dart';

class Utils {
  static Color determineRowColor(List<Userpayload>? userPayload) {
    if (userPayload != null && userPayload.isNotEmpty) {
      for (var userpayload in userPayload) {
        // Directly access the status field of PayloadUser
        String? status = userpayload.status;
        if (status == 'CREATED') {
          return Colors.green;
        } else if (status == 'APPROVED'){
          return Colors.green;
        } else if (status == 'REJECTED') {
          return Colors.red;
        }
      }
    }
    return Colors.transparent; // Default color if no relevant status is found
  }
}

/*class Utils {
  static Color determineRowColor(List<PayloadUser>? payload) {
    if (payload == null || payload.isEmpty) {
      print('Payload is null or empty');
      return Colors.transparent;
    }

    for (var payloadUser in payload) {
      // Directly access the status field from PayloadUser
      String? status = payloadUser.status;
      print('Found status: $status');

      // Determine color based on status
      if (status == 'CREATED') {
        return Colors.green;
      } else if (status == 'REJECTED') {
        return Colors.red;
      }
    }

    print('No matching status found');
    return Colors.transparent;
  }
}*/
