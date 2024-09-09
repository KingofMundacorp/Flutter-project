import 'package:flutter/material.dart';
import 'package:user_support_mobile/models/facility_model/facility_model.dart'; // Adjust the import according to your project structure

class FacilityTable extends StatelessWidget {
  final Facility facility;

  const FacilityTable({required this.facility, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Table(
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
            _buildTableRow('Facility Id', facility.id),
            _buildTableRow('Name', facility.name),
            _buildTableRow('Region', facility.region),
            _buildTableRow('District', facility.district),
            _buildTableRow('Opened Date', facility.openedDate),
            _buildTableRow('Created At', facility.createdAt),
            _buildTableRow('Facility Type', facility.facilityType),
            _buildTableRow('Ownership', facility.ownership),
            _buildTableRow('Operating Status', facility.operatingStatus),
          ],
        ),
      ),
    );
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

  TableRow _buildTableRow(String header, String value) {
    return TableRow(
      children: [
        _buildTableCell(header),
        _buildTableCell(value),
      ],
    );
  }

  TableCell _buildTableCell(String content, {bool isHeader = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Align(
          alignment:  Alignment.centerLeft,
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
}
