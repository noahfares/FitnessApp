import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The version/build pair actually installed on the device — not a constant,
/// because the build number is set by the release workflow (`F-REL-005`) and
/// is only ever true once read back from the package.
class AppVersionInfo {
  final String version;
  final String buildNumber;

  const AppVersionInfo({required this.version, required this.buildNumber});
}

/// Seam over `package_info_plus`'s platform channel, so widget tests can
/// supply a fixed value instead of exercising a channel `flutter_test`
/// cannot service.
abstract interface class AppInfoService {
  Future<AppVersionInfo> current();
}

class PackageAppInfoService implements AppInfoService {
  const PackageAppInfoService();

  @override
  Future<AppVersionInfo> current() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersionInfo(version: info.version, buildNumber: info.buildNumber);
  }
}

final appInfoServiceProvider = Provider<AppInfoService>(
  (ref) => const PackageAppInfoService(),
);

final appVersionInfoProvider = FutureProvider<AppVersionInfo>(
  (ref) => ref.watch(appInfoServiceProvider).current(),
);
