class CustomUser {
  String name;
  String phoneNumber;
  String email;
  String dateOfBirth;
  String gender;
  String emergencyContactName;
  String emergencyContactPhone;
  bool otpOnEmail;

  // Driver-specific fields
  bool isDriver;
  String vehicleType;
  String vehicleBrand;
  String vehicleModel;
  String vehicleNumber;
  String vehiclePhoto;
  String driversLicensePhoto;
  String userProfilePhoto;
  int vehicleAge;

  CustomUser({
    this.name = '',
    this.phoneNumber = '',
    this.email = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.otpOnEmail = false,
    this.isDriver = false,
    this.vehicleType = '',
    this.vehicleBrand = '',
    this.vehicleModel = '',
    this.vehicleNumber = '',
    this.vehiclePhoto = '',
    this.driversLicensePhoto = '',
    this.userProfilePhoto = '',
    this.vehicleAge = 0,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'otpOnEmail': otpOnEmail,
      'isDriver': isDriver,
      'vehicleType': vehicleType,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleNumber': vehicleNumber,
      'vehiclePhoto': vehiclePhoto,
      'driversLicensePhoto': driversLicensePhoto,
      'userProfilePhoto': userProfilePhoto,
      'vehicleAge': vehicleAge,
    };
  }
}
