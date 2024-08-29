// lib/pages/facility_screen/local_hospital_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user_support_mobile/models/facility_model/facility_model.dart';
import 'package:user_support_mobile/pages/facility_screen/facility_dateRange_picker.dart';
import 'package:user_support_mobile/pages/faility_components/alert_message.dart';
import 'package:user_support_mobile/pages/faility_components/facility_table.dart';
import 'package:user_support_mobile/pages/faility_components/search_button.dart';
import 'package:user_support_mobile/pages/faility_components/search_field.dart';
import 'package:user_support_mobile/pages/faility_components/success_overlay.dart';
import 'package:user_support_mobile/pages/faility_components/update_button.dart';
import 'package:user_support_mobile/services/facility_service/facility_service.dart';


class LocalHospitalScreen extends StatefulWidget {
  const LocalHospitalScreen({Key? key}) : super(key: key);

  @override
  State<LocalHospitalScreen> createState() => _LocalHospitalScreenState();
}

class _LocalHospitalScreenState extends State<LocalHospitalScreen> {
  final TextEditingController _controller = TextEditingController();
  Facility? _facility;
  bool _showTable = false;
  bool _showAlert = false;
  bool _showSuccessOverlay = false;
  bool _isLoading = false;
  String _alertMessage = '';

  late FacilityService _facilityService;

  @override
  void initState() {
    super.initState();
    _facilityService = FacilityService(
      baseUrl: 'http://41.59.227.69',
      authHeader: base64Encode(utf8.encode('dhis:Dhis@2024')),
    );
  }

  Future<void> _fetchFacilityData(String code) async {
    setState(() {
      _isLoading = true;
      _showTable = false;
      _showAlert = false;
      _alertMessage = '';
    });

    final facility = await _facilityService.fetchFacilityData(code);

    setState(() {
      _isLoading = false;
      if (facility == null) {
        _alertMessage = 'No facility found';
        _showAlert = true;
      } else {
        _facility = facility;
        _showTable = true;
      }
    });

    if (_showAlert) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _showAlert = false;
        });
      });
    }
  }

  void _handleSearch() {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      setState(() {
        _alertMessage = 'Input is empty';
        _showAlert = true;
      });
    } else if (!_isNumeric(input)) {
      setState(() {
        _alertMessage = 'Input should be in numbers';
        _showAlert = true;
      });
    } else if (!RegExp(r'^\d{6}-\d$').hasMatch(input)) {
      setState(() {
        _alertMessage = 'Invalid input, check your code';
        _showAlert = true;
      });
    } else {
      _fetchFacilityData(input);
    }
  }

  bool _isNumeric(String input) {
    return double.tryParse(input.replaceAll('-', '')) != null;
  }

  void _handleUpdate() {
    setState(() {
      _showSuccessOverlay = true;
      _showTable = false;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showSuccessOverlay = false;
      });
    });
  }

  void _onBottomNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FacilityDaterangePicker()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Facility search'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search for health facility by code',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(height: 20.0),
                SearchField(controller: _controller),
                SizedBox(height: 10.0),
                SearchButton(onPressed: _handleSearch),
                SizedBox(height: 16.0),
                if (_isLoading) Center(child: CircularProgressIndicator()),
                if (_showAlert) AlertMessage(message: _alertMessage),
                if (_showTable && _facility != null) FacilityTable(facility: _facility!),
                SizedBox(height: 16.0),
                if (_showTable) UpdateButton(onPressed: _handleUpdate),
              ],
            ),
          ),
          if (_showSuccessOverlay) SuccessOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        currentIndex: 0,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
