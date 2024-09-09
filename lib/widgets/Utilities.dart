


import 'package:flutter/material.dart';


class Utils {
  static Color determineRowColor(dynamic payload) {
    if (payload is List) {
      for (var payloadUser in payload) {
        if (payloadUser['payload'] != null) {
          for (var userPayload in payloadUser['payload']) {
            String? status = userPayload['status'];
            if (status == 'CREATED') {
              return Colors.green.withOpacity(0.2);
            } else if (status == 'REJECTED') {
              return Colors.red.withOpacity(0.2);
            }
          }

        }
      }
    }
    return Colors.transparent; // Default color if no relevant status is found
  }
}

