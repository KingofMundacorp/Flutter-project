import 'package:flutter/material.dart';
import 'package:user_support_mobile/pages/facility_screen/local_hospital_screen.dart';
import '../faility_components/facilityDetails.dart';

class FacilityDaterangePicker extends StatefulWidget {
  @override
  State<FacilityDaterangePicker> createState() => _FacilityDaterangePickerState();
}

class _FacilityDaterangePickerState extends State<FacilityDaterangePicker> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  int _currentIndex = 1; // Set the initial index to Calendar

  // List of mock facilities
  final List<Map<String, String>> _facilityList = [
    {'code': '001', 'name': 'Green Valley Hospital', 'region': 'Arusha'},
    {'code': '002', 'name': 'Blue Lake Clinic', 'region': 'Mwanza'},
    {'code': '003', 'name': 'Sunrise Medical Center', 'region': 'Dar es Salaam'},
    {'code': '004', 'name': 'Oceanview Hospital', 'region': 'Tanga'},
    {'code': '005', 'name': 'Mountainview Clinic', 'region': 'Kilimanjaro'},
    {'code': '006', 'name': 'Palm Tree Health Center', 'region': 'Dodoma'},
    {'code': '007', 'name': 'Golden Sands Hospital', 'region': 'Zanzibar'},
    {'code': '008', 'name': 'Riverbank Clinic', 'region': 'Morogoro'},
    {'code': '009', 'name': 'Hilltop Medical Center', 'region': 'Mbeya'},
    {'code': '010', 'name': 'Coastal Health Clinic', 'region': 'Lindi'},
  ];

  List<Map<String, String>> _filteredFacilities = [];

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
        _filterFacilities();
      });
    }
  }

  void _filterFacilities() {
    final startDate = DateTime.tryParse(_startDateController.text);
    final endDate = DateTime.tryParse(_endDateController.text);

    if (startDate != null && endDate != null) {
      // Show only the first 3 facilities if both start and end dates are set
      setState(() {
        _filteredFacilities = _facilityList.take(3).toList();
      });
    } else if (startDate != null) {
      // Show all facilities if only the start date is set
      setState(() {
        _filteredFacilities = _facilityList;
      });
    } else {
      // Show no facilities if no date is set
      setState(() {
        _filteredFacilities = [];
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
              'Search for health facility by calendar',
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
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFacilities.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text("Facility: ${_filteredFacilities[index]['name']}"),
                      subtitle: Text("Region: ${_filteredFacilities[index]['region']}"),
                      trailing: Text("Code: ${_filteredFacilities[index]['code']}"),
                      onTap: () {
                        // When a facility is tapped, navigate to the FacilityDetailsScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FacilityDetailsScreen(
                              facility: _filteredFacilities[index],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.grey[200],
        onTap: _onBottomNavTap,
      ),
    );
  }
}
