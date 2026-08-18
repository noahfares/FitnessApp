import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_version.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/platform/app_info_service.dart';
import '../../shell/widgets/apple_list.dart';
import '../../shell/widgets/section_header.dart';
import '../../../core/l10n/l10n.dart';

const _repositoryUrl = 'https://github.com/noahfares/fitnessapp';

/// The policy lives in the repository, not on a host of its own (`F-REL-007`
/// §4) — a file with a commit history is harder to quietly rewrite than a page.
const _privacyPolicyUrl =
    'https://github.com/noahfares/fitnessapp/blob/main/PRIVACY.md';

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
    final colors = context.appColors;
    final versionInfo = ref.watch(appVersionInfoProvider);
    final versionText = versionInfo.when(
      data: (info) => '${info.version} (build ${info.buildNumber})',
      loading: () => appVersion,
      error: (_, _) => appVersion,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(context.l10n.settingsAbout)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          AppleListSection(
            children: [
              AppleListRow(
                title: context.l10n.settingsVersion,
                subtitle: versionText,
                showChevron: false,
              ),
              AppleListRow(
                title: context.l10n.settingsSourceCode,
                subtitle: _repositoryUrl,
                trailing: Icon(Icons.open_in_new, size: 16, color: colors.tint),
                showChevron: false,
                onTap: () => launchUrl(
                  Uri.parse(_repositoryUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              AppleListRow(
                title: context.l10n.settingsOpenSourceLicences,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'FitnessApp',
                  applicationVersion: versionText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(context.l10n.settingsPrivacy),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              context.l10n.settingsPrivacySummary,
              style: TextStyle(fontSize: 15, color: colors.label),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppleListSection(
            children: [
              AppleListRow(
                title: context.l10n.settingsPrivacyPolicy,
                subtitle: context.l10n.settingsTheFullTextInThe,
                trailing: Icon(Icons.open_in_new, size: 16, color: colors.tint),
                showChevron: false,
                onTap: () => launchUrl(
                  Uri.parse(_privacyPolicyUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
