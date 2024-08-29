import 'package:flutter/material.dart';
import 'package:user_support_mobile/pages/facility_screen/local_hospital_screen.dart';

class FacilityDaterangePicker extends StatefulWidget {
  @override
  State<FacilityDaterangePicker> createState() => _FacilityDaterangePickerState();
}

class _FacilityDaterangePickerState extends State<FacilityDaterangePicker> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  int _currentIndex = 1; // Set the initial index to Calendar

  void _onBottomNavTap(int index) {
    if (index == 0) { // Index 0 corresponds to the Home tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocalHospitalScreen()),
      );
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0]; // Format date as needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Facility search'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Search for health facility by code',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(
                labelText: 'Start Date',
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context, _startDateController),
                  icon: Icon(Icons.calendar_today),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                labelText: 'End Date',
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context, _endDateController),
                  icon: Icon(Icons.calendar_today),
                ),
              ),
              readOnly: true,
            ),
          ],
        ),
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
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue, // Set selected item color to blue
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.grey[200],
        onTap: _onBottomNavTap,
      ),
    );
  }
}
