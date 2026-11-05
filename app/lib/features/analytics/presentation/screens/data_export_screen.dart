import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:app/features/analytics/presentation/providers/backup_export_providers.dart';
import 'package:app/features/analytics/presentation/providers/csv_export_providers.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_dialog.dart';
import '../../../../ui/candy/candy_scaffold.dart';

/// P4 data export screen: CSV export and portable GymLvl backup export.
///
/// Both exports are owner-only and one-way (no restore/import in P4).
/// The produced data is copied to the clipboard; no credentials, tokens, or
/// secrets are ever included.
class DataExportScreen extends ConsumerWidget {
  const DataExportScreen({super.key});

  Future<void> _copyCsv(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(csvExportProvider.future);
    await Clipboard.setData(ClipboardData(text: result.toSingleStream()));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('export_copied'.tr(ref))));
    }
  }

  Future<void> _copyBackup(WidgetRef ref, BuildContext context) async {
    final json = await ref.read(backupExportProvider.future);
    await Clipboard.setData(ClipboardData(text: json));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('export_copied'.tr(ref))));
    }
  }

  void _showInfo(
    WidgetRef ref,
    BuildContext context,
    String title,
    String body,
  ) {
    CandyDialog.show(
      context: context,
      title: title,
      message: body,
      primaryActionLabel: null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyScaffold(
      appBar: AppBar(
        title: Text('export_title'.tr(ref)),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CandyCard(
              shadow: CandyCardShadow.medium,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'export_title'.tr(ref),
                    style: const TextStyle(
                      fontFamily: CandyFonts.display,
                      fontSize: 18,
                      color: CandyColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Chỉ xuất dữ liệu của chính bạn. Không bao gồm mật khẩu, '
                    'mã thông báo hoặc khóa Supabase.',
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 13,
                      color: CandyColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // CSV export.
                  CandyButton(
                    label: 'export_csv'.tr(ref),
                    variant: CandyButtonVariant.primary,
                    onPressed: () => _copyCsv(ref, context),
                    icon: Icons.file_download,
                  ),
                  const SizedBox(height: 12.0),
                  // Backup export.
                  CandyButton(
                    label: 'export_backup'.tr(ref),
                    variant: CandyButtonVariant.secondary,
                    onPressed: () => _copyBackup(ref, context),
                    icon: Icons.backup,
                  ),
                  const SizedBox(height: 20.0),
                  // Info.
                  CandyButton(
                    label: null,
                    child: const Text(
                      'Sao lưu là xuất một chiều (không khôi phục/nhập trong P4).',
                      style: TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 12,
                        color: CandyColors.charcoal,
                      ),
                    ),
                    variant: CandyButtonVariant.neutral,
                    size: CandyButtonSize.small,
                    isFullWidth: false,
                    onPressed: () => _showInfo(
                      ref,
                      context,
                      'export_title'.tr(ref),
                      'CSV và sao lưu GymLvl chỉ xuất dữ liệu của bạn. '
                      'Không khôi phục hay nhập trong P4.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
