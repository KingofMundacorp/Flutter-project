import 'package:flutter/material.dart';
class LocalHospitalScreen extends StatefulWidget {
  const LocalHospitalScreen({Key? key}) : super(key: key);

  @override
  State<LocalHospitalScreen> createState() => _LocalHospitalScreenState();
}

class _LocalHospitalScreenState extends State<LocalHospitalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Facility Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search for health facility by code',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              height: 50.0,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  labelText: 'Enter facility code',
                  labelStyle: TextStyle(fontSize: 13.0),
                  isDense: true,
                ),
              ),
            ),
           // Space between the text field and the button
            Align(
              alignment: Alignment.centerRight, // Align the button to the left
              child: ElevatedButton(
                onPressed: () {
                  // Action when the button is pressed
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[350], // Button background color
                  side: BorderSide(color: Colors.grey), // Grey border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Small border radius
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0), // Padding inside the button
                ),
                child: Text(
                  'Search',
                  style: TextStyle(fontSize: 14.0), // Button text font size
                ),
              ),
            ),
            SizedBox(height: 16.0), // Space between the button and the table
            Expanded( // Ensures the table takes up remaining space
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey, width: 1),
                    verticalInside: BorderSide.none, // Remove the vertical lines
                    bottom: BorderSide(color: Colors.grey, width: 1),
                  ),
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Header background color
                      ),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Align(
                              alignment: Alignment.centerRight, // Align header to the right
                              child: Text(
                                'Value',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < 8; i++)
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0), // Increased padding for more space
                              child: Text(
                                _getNameForRow(i),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0), // Increased padding for more space
                              child: Align(
                                alignment: Alignment.centerRight, // Align text to the right
                                child: Text(
                                  _getValueForRow(i),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0), // Space between the table and the update button
            Align(
              alignment: Alignment.centerLeft, // Align the button to the left
              child: ElevatedButton(
                onPressed: () {
                  // Action when the button is pressed
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Button background color
                  side: BorderSide(color: Colors.blue), // Blue border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Small border radius
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0), // Padding inside the button
                ),
                child: Text(
                  'Update',
                  style: TextStyle(fontSize: 14.0), // Button text font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Example methods to get data for each row, replace these with your actual data
  String _getNameForRow(int index) {
    const names = [
      'Facility Id', 'Name', 'Region', 'District', 'Opened Date', 'Created At', 'Facility Type', 'Ownership', 'Operating States'
    ];
    return names[index];
  }

  String _getValueForRow(int index) {
    const values = [
      '105457-5', 'ETEST', 'Tabora', 'Tabora', '2024-05-27', '2024-05-30', 'Health Center', 'Company/Business name', 'Operating'
    ];
    return values[index];
  }
}
