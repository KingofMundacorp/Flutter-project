import 'package:flutter/material.dart';

// Facility Details Screen displaying the table
class FacilityDetailsScreen extends StatelessWidget {
  final Map<String, String> facility;

  const FacilityDetailsScreen({required this.facility, Key? key}) : super(key: key);

  // Method to show the update success dialog
  void _showUpdateSuccessDialog(BuildContext context) {
    final alertDialog = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            'Update Successful',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return alertDialog;
      },
    );

    // Automatically dismiss the dialog after 1 second
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss the dialog
    });
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[200]),
      children: [
        _buildTableCell('Field', isHeader: true),
        _buildTableCell('Value', isHeader: true),
      ],
    );
  }

  TableCell _buildTableCell(String content, {bool isHeader = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(facility['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              //border: TableBorder.all(color: Colors.grey),
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey, width: 1),
                verticalInside: BorderSide.none,
                bottom: BorderSide(color: Colors.grey, width: 1),
              ),
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                _buildTableHeaderRow(), // Add header row
                _buildTableRow('Facility Code', facility['code']!),
                _buildTableRow('Name', facility['name']!),
                _buildTableRow('Region', facility['region']!,
                ),
              ],
            ),
            SizedBox(height: 20,),
            Container(
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  _showUpdateSuccessDialog(context); // Show the dialog when button is pressed
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[200],
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String field, String value) {
    return TableRow(
      children: [
        _buildTableCell(field),
        _buildTableCell(value),
      ],
    );
  }
}