class Facility {
  final String id;
  final String name;
  final String region;
  final String district;
  final String openedDate;
  final String createdAt;
  final String facilityType;
  final String ownership;
  final String operatingStatus;

  Facility({
    required this.id,
    required this.name,
    required this.region,
    required this.district,
    required this.openedDate,
    required this.createdAt,
    required this.facilityType,
    required this.ownership,
    required this.operatingStatus,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['Fac_IDNumber'] as String,
      name: json['Name'] as String,
      region: json['Region'] as String,
      district: json['District'] as String,
      openedDate: json['OpenedDate'] as String,
      createdAt: json['CreatedAt'] as String,
      facilityType: json['FacilityType'] as String,
      ownership: json['Ownership'] as String,
      operatingStatus: json['OperatingStatus'] as String,
    );
  }
}
