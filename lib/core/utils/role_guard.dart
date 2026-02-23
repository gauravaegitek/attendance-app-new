import '../../services/storage_service.dart';
import '../constants/app_constants.dart';

class RoleGuard {
  static String get _role => StorageService.getUserRole().toLowerCase();

  static bool get isAdmin => _role == AppConstants.roleAdmin;
  static bool get isManager => _role == AppConstants.roleManager;
  static bool get isHR => _role == AppConstants.roleHR;

  /// Admin / Manager / HR → WFH admin screen
  static bool get canManageWFH => isAdmin || isManager || isHR;

  /// Admin tab only
  static bool get showAdminTab => isAdmin;
}