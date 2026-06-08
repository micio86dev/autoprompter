import 'package:permission_handler/permission_handler.dart';

/// Outcome of a microphone permission check/request, reduced to the three
/// states the UI cares about.
enum MicPermissionStatus { granted, denied, permanentlyDenied }

/// Microphone permission contract, so the teleprompter can receive a fake
/// implementation in tests instead of touching the platform.
abstract class MicPermissionService {
  /// Current permission status, without prompting the user.
  Future<MicPermissionStatus> status();

  /// Requests the permission, showing the OS dialog if needed.
  Future<MicPermissionStatus> request();

  /// Opens the system settings page for this app.
  Future<void> openSettings();
}

/// Real implementation backed by `permission_handler`.
class PermissionHandlerMicService implements MicPermissionService {
  const PermissionHandlerMicService();

  @override
  Future<MicPermissionStatus> status() => _map(Permission.microphone.status);

  @override
  Future<MicPermissionStatus> request() => _map(Permission.microphone.request());

  @override
  Future<void> openSettings() => openAppSettings();

  Future<MicPermissionStatus> _map(Future<PermissionStatus> future) async {
    final status = await future;
    if (status.isGranted || status.isLimited) {
      return MicPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MicPermissionStatus.permanentlyDenied;
    }
    return MicPermissionStatus.denied;
  }
}
