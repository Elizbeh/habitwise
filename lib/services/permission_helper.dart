import 'package:habitwise/models/group.dart';

class PermissionHelper {
  static bool hasPermission(String userId, String action, HabitWiseGroup group) {
    String role = getUserRole(userId, group.groupRoles); // assuming you store roles as a Map

    // Only admins have permissions for all actions
    if (role == 'admin') return true;

    // For members, define specific actions they can perform, if any.
    if (role == 'member') {
        // Example: Allow members to add goals, but not to delete or edit.
        if (action == 'add_goal') return true;  
        return false; // Default to no permission for other actions
    }

    return false; // Default to no permission for unrecognized roles
  }

  static String getUserRole(String userId, Map<String, String> groupRoles) {
    return groupRoles[userId] ?? 'member'; // Return 'member' if no specific role is assigned
  }
}
