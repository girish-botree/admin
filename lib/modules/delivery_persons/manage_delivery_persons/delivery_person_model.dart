class DeliveryPerson {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String identificationNumber;
  final String vehicleType;
  final String vehicleNumber;
  final DateTime dateOfBirth;
  final String emergencyContact;
  final String? profilePictureUrl;
  final String? documentsUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeliveryPerson({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.identificationNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.dateOfBirth,
    required this.emergencyContact,
    this.profilePictureUrl,
    this.documentsUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryPerson.fromJson(Map<String, dynamic> json) {
    return DeliveryPerson(
      id: (json['id']?.toString()) ?? '',
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      identificationNumber: (json['identificationNumber'] as String?) ?? '',
      vehicleType: (json['vehicleType'] as String?) ?? '',
      vehicleNumber: (json['vehicleNumber'] as String?) ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'].toString())
          : DateTime.now().subtract(Duration(days: 18 * 365)),
      emergencyContact: (json['emergencyContact'] as String?) ?? '',
      profilePictureUrl: json['profilePictureUrl'] as String?,
      documentsUrl: json['documentsUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'identificationNumber': identificationNumber,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'emergencyContact': emergencyContact,
      'profilePictureUrl': profilePictureUrl,
      'documentsUrl': documentsUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  String get formattedDateOfBirth =>
      '${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  DeliveryPerson copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? identificationNumber,
    String? vehicleType,
    String? vehicleNumber,
    DateTime? dateOfBirth,
    String? emergencyContact,
    String? profilePictureUrl,
    String? documentsUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryPerson(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      documentsUrl: documentsUrl ?? this.documentsUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryPerson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeliveryPerson{id: $id, fullName: $fullName, email: $email, vehicleType: $vehicleType}';
  }
}

/// Delivery Agent model for admin API endpoints
class DeliveryAgent {
  final String id;
  final String? userId;
  final String phoneNumber;
  final String address;
  final String identificationNumber;
  final String vehicleType;
  final String vehicleNumber;
  final DateTime dateOfBirth;
  final String emergencyContact;
  final String availabilityStatus;
  final DateTime joinedOn;
  final String? profilePictureUrl;
  final double? ratings;
  final String? documentsUrl;
  final bool isActive;
  final int maxCapacity;
  final int currentLoad;

  DeliveryAgent({
    required this.id,
    this.userId,
    required this.phoneNumber,
    required this.address,
    required this.identificationNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.dateOfBirth,
    required this.emergencyContact,
    required this.availabilityStatus,
    required this.joinedOn,
    this.profilePictureUrl,
    this.ratings,
    this.documentsUrl,
    required this.isActive,
    required this.maxCapacity,
    required this.currentLoad,
  });

  // Computed property for display name (using vehicle info as identifier)
  String get name => '$vehicleType - $vehicleNumber';

  // Computed property for covered pincodes (placeholder for now)
  List<String> get coveredPincodes => [];

  // Backward compatibility
  DateTime get createdOn => joinedOn;

  DateTime? get modifiedOn => null;

  factory DeliveryAgent.fromJson(Map<String, dynamic> json) {
    return DeliveryAgent(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      identificationNumber: json['identificationNumber'] as String,
      vehicleType: json['vehicleType'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      emergencyContact: json['emergencyContact'] as String,
      availabilityStatus: json['availabilityStatus'] as String,
      joinedOn: DateTime.parse(json['joinedOn'] as String),
      profilePictureUrl: json['profilePictureUrl'] as String?,
      ratings: json['ratings'] != null
          ? (json['ratings'] as num).toDouble()
          : null,
      documentsUrl: json['documentsUrl'] as String?,
      isActive: json['isActive'] as bool,
      maxCapacity: json['maxCapacity'] as int,
      currentLoad: json['currentLoad'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'address': address,
      'identificationNumber': identificationNumber,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'emergencyContact': emergencyContact,
      'availabilityStatus': availabilityStatus,
      'joinedOn': joinedOn.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
      'ratings': ratings,
      'documentsUrl': documentsUrl,
      'isActive': isActive,
      'maxCapacity': maxCapacity,
      'currentLoad': currentLoad,
    };
  }

  // Create a copy with updated fields for editing
  DeliveryAgent copyWith({
    String? id,
    String? userId,
    String? phoneNumber,
    String? address,
    String? identificationNumber,
    String? vehicleType,
    String? vehicleNumber,
    DateTime? dateOfBirth,
    String? emergencyContact,
    String? availabilityStatus,
    DateTime? joinedOn,
    String? profilePictureUrl,
    double? ratings,
    String? documentsUrl,
    bool? isActive,
    int? maxCapacity,
    int? currentLoad,
  }) {
    return DeliveryAgent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      joinedOn: joinedOn ?? this.joinedOn,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      ratings: ratings ?? this.ratings,
      documentsUrl: documentsUrl ?? this.documentsUrl,
      isActive: isActive ?? this.isActive,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentLoad: currentLoad ?? this.currentLoad,
    );
  }

  @override
  String toString() {
    return 'DeliveryAgent{id: $id, name: $name, phoneNumber: $phoneNumber, availabilityStatus: $availabilityStatus, ratings: $ratings}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryAgent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}