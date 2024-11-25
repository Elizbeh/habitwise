import 'package:habitwise/models/group.dart';

class PermissionHelper {
  static bool hasPermission(String userId, String action, HabitWiseGroup group) {
    String role = getUserRole(userId, group.groupRoles);

    // Only admins have permissions for all actions
    if (role == 'admin') return true;

    // For members, define specific actions they can perform, if any.
    if (role == 'member') {
      // Allow members to leave a group
      if (action == 'leave_group') return true;  
      return false; // Default to no permission for other actions
    }

    return false; // Default to no permission for unrecognized roles
  }

  static String getUserRole(String userId, Map<String, String> groupRoles) {
    return groupRoles[userId] ?? 'member'; // Return 'member' if no specific role is assigned
  }
}
