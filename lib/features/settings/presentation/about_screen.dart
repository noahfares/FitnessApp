import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_version.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/platform/app_info_service.dart';
import '../../../l10n/generated/app_localizations.dart';

const _repositoryUrl = 'https://github.com/noahfares/fitnessapp';

/// Settings › About (`F-SET-009`).
///
/// The version shown here is the only diagnostic context this app will ever
/// have: there is no crash reporting and no telemetry (ADR-0002), so a bug
/// report can only name a build if this screen tells the user which one they
/// are on. The build number is read from the installed package rather than a
/// constant, because it is set by the release workflow (`F-REL-005`) and a
/// constant would just be restating a claim instead of checking it.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final versionInfo = ref.watch(appVersionInfoProvider);
    final versionText = versionInfo.when(
      data: (info) => '${info.version} (build ${info.buildNumber})',
      loading: () => appVersion,
      error: (_, _) => appVersion,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.aboutVersionLabel),
            subtitle: Text(versionText),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.aboutSourceCodeLabel),
            subtitle: const Text(_repositoryUrl),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(
              Uri.parse(_repositoryUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            title: Text(l10n.aboutLicencesLabel),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'FitnessApp',
              applicationVersion: versionText,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutPrivacyHeading,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.aboutPrivacyBody, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
