class Appointment {
  final String userId;
  final int serviceId;
  final String appointmentDate;
  final String status;

  Appointment({
    required this.userId,
    required this.serviceId,
    required this.appointmentDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "serviceId": serviceId,
      "appointmentDate": appointmentDate,
      "status": status,
    };
  }
}
