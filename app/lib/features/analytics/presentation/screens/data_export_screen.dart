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

/// Owner-scoped CSV and portable GymLvl backup export.
/// The produced data is copied to the clipboard without credentials or keys.
class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  bool _exporting = false;
  bool _exportingBackup = false;
  String? _errorMessage;

  Future<void> _copyCsv() => _copyExport(backup: false);

  Future<void> _copyBackup() => _copyExport(backup: true);

  Future<void> _copyExport({required bool backup}) async {
    if (_exporting) return;
    setState(() {
      _exporting = true;
      _exportingBackup = backup;
      _errorMessage = null;
    });
    try {
      final text = backup
          ? await ref.refresh(backupExportProvider.future)
          : (await ref.refresh(csvExportProvider.future)).toSingleStream();
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('export_copied'.tr(ref))));
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _exportErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportingBackup = false;
        });
      }
    }
  }

  String _exportErrorMessage(Object error) {
    final code = error is StateError ? error.message.toString() : null;
    if (code == 'session_required') {
      return translateText(
        ref,
        vi: 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại trước khi xuất dữ liệu.',
        en: 'Your session has expired. Sign in again before exporting data.',
      );
    }
    if (code == 'workout_export_incomplete' ||
        code == 'custom_exercise_export_incomplete' ||
        code == 'measurement_export_incomplete') {
      return translateText(
        ref,
        vi: 'Không thể đọc đầy đủ dữ liệu để sao lưu. Chưa sao chép dữ liệu. Hãy thử lại.',
        en: 'Could not read all data for the backup. Nothing was copied. Please retry.',
      );
    }
    return translateText(
      ref,
      vi: 'Không thể xuất dữ liệu an toàn. Chưa sao chép dữ liệu. Hãy thử lại.',
      en: 'Could not export data safely. Nothing was copied. Please retry.',
    );
  }

  void _showInfo(String title, String body) {
    CandyDialog.show(
      context: context,
      title: title,
      message: body,
      primaryActionLabel: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backupLimitations = translateText(
      ref,
      vi:
          'Bản sao lưu JSON gồm buổi tập, hiệp tập, số đo và bài tập tự tạo. '
          'Không gồm tùy chọn cá nhân. Chỉ có thể khôi phục vào cùng tài khoản GymLvl.',
      en:
          'The JSON backup includes workouts, sets, measurements, and custom exercises. '
          'Preferences are excluded. It can only be restored to the same GymLvl account.',
    );
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
                    translateText(
                      ref,
                      vi:
                          'Chỉ xuất dữ liệu của chính bạn. Không bao gồm mật khẩu, '
                          'mã thông báo hoặc khóa Supabase.',
                      en:
                          'Only your own data is exported. Passwords, tokens, '
                          'and Supabase keys are excluded.',
                    ),
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
                    onPressed: _exporting ? null : _copyCsv,
                    isLoading: _exporting && !_exportingBackup,
                    icon: Icons.file_download,
                  ),
                  const SizedBox(height: 12.0),
                  // Backup export.
                  CandyButton(
                    label: 'export_backup'.tr(ref),
                    variant: CandyButtonVariant.secondary,
                    onPressed: _exporting ? null : _copyBackup,
                    isLoading: _exporting && _exportingBackup,
                    icon: Icons.backup,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    backupLimitations,
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 13,
                      color: CandyColors.charcoal,
                    ),
                  ),
                  if (_exporting || _errorMessage != null) ...[
                    const SizedBox(height: 12.0),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _errorMessage ??
                            translateText(
                              ref,
                              vi: 'Đang chuẩn bị dữ liệu để xuất…',
                              en: 'Preparing data for export…',
                            ),
                        style: const TextStyle(
                          fontFamily: CandyFonts.body,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CandyColors.ink,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20.0),
                  // Info.
                  CandyButton(
                    label: null,
                    variant: CandyButtonVariant.neutral,
                    size: CandyButtonSize.small,
                    isFullWidth: false,
                    onPressed: () =>
                        _showInfo('export_title'.tr(ref), backupLimitations),
                    child: Text(
                      translateText(
                        ref,
                        vi: 'Thông tin về bản sao lưu',
                        en: 'About this backup',
                      ),
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 12,
                        color: CandyColors.charcoal,
                      ),
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
