class WorkspaceModel {
  final String id;
  final String name;
  final String inviteCode;

  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.inviteCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inviteCode': inviteCode,
    };
  }
}