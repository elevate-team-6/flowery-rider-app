class RiderSessionModel {
  final String id;
  final String name;
  final String phone;

  const RiderSessionModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  bool get hasValidIdentity => id.isNotEmpty;
}
