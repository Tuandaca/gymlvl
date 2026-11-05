import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/bodyweight/data/supabase_body_measurement_repository.dart';
import 'package:app/features/bodyweight/domain/body_measurement.dart';
import 'package:app/features/bodyweight/presentation/providers/body_measurement_providers.dart';
import 'package:app/core/config/supabase_config.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_dialog.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';
import '../../../../ui/candy/candy_stat_tile.dart';
import '../../../../ui/candy/candy_text_field.dart';

/// General body measurements screen (P4 Gate 2).
///
/// Shows the latest measurement per supported type plus a chronological
/// history. Supports adding a new measurement (type, value, unit, note,
/// measured_at). Owner-scoped via RLS; never writes XP/rewards. Graceful
/// empty state.
class BodyMeasurementsScreen extends ConsumerStatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  ConsumerState<BodyMeasurementsScreen> createState() =>
      _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState
    extends ConsumerState<BodyMeasurementsScreen> {
  BodyMeasurementType _selectedType = BodyMeasurementType.bodyWeight;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final DateTime _measuredAt = DateTime.now().toUtc();

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    final value = double.tryParse(_valueController.text.trim());
    if (value == null || value <= 0) {
      return;
    }
    final repository = SupabaseBodyMeasurementRepository(SupabaseConfig.client);
    try {
      await repository.insert(
        BodyMeasurement(
          id: '',
          userId: SupabaseConfig.client.auth.currentUser?.id ?? '',
          type: _selectedType,
          value: value,
          unit: _selectedType.canonicalUnit == 'kg'
              ? BodyMeasurementUnit.kg
              : BodyMeasurementUnit.cm,
          measuredAt: _measuredAt,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );
      if (mounted) {
        ref.invalidate(bodyMeasurementsProvider);
        ref.invalidate(bodyMeasurementsByTypeProvider(_selectedType));
        _valueController.clear();
        _notesController.clear();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => CandyDialog(
          title: 'add_measurement'.tr(ref),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type dropdown.
                DropdownButtonFormField<BodyMeasurementType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'measurement_type'.tr(ref),
                    border: const OutlineInputBorder(),
                  ),
                  items: BodyMeasurementType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text('${t.labelKey}'.tr(ref)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setDialogState(() => _selectedType = v);
                    setState(() => _selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                // Value.
                CandyTextField(
                  controller: _valueController,
                  labelText: 'measurement_value'.tr(ref),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                // Unit (read-only hint).
                Text(
                  '${'measurement_unit'.tr(ref)}: '
                  '${_selectedType.canonicalUnit.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 13,
                    color: CandyColors.charcoal,
                  ),
                ),
                const SizedBox(height: 12),
                // Notes.
                CandyTextField(
                  controller: _notesController,
                  labelText: 'measurement_notes'.tr(ref),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                // Measured at.
                Text(
                  '${'measured_at'.tr(ref)}: '
                  '${_measuredAt.day.toString().padLeft(2, '0')}/'
                  '${_measuredAt.month.toString().padLeft(2, '0')}/'
                  '${_measuredAt.year}',
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 13,
                    color: CandyColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          primaryActionLabel: 'add_measurement'.tr(ref),
          onPrimaryAction: () => _saveMeasurement(),
          secondaryActionLabel: null,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _valueText(double v) => v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(bodyMeasurementsProvider);

    return measurementsAsync.when(
      data: (measurements) {
        if (measurements.isEmpty) {
          return _buildEmpty();
        }
        // Group latest per type.
        final latestByType = <BodyMeasurementType, BodyMeasurement>{};
        for (final m in measurements) {
          latestByType.putIfAbsent(m.type, () => m);
        }
        return _buildContent(measurements, latestByType);
      },
      loading: () => _buildLoading(),
      error: (e, _) => _buildError(e.toString()),
    );
  }

  Widget _buildLoading() => CandyScaffold(
    appBar: AppBar(
      title: Text('measurements_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildError(String message) => CandyScaffold(
    appBar: AppBar(
      title: Text('measurements_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyErrorState(
        title: 'error_title'.tr(ref),
        message: message,
        retryLabel: 'retry'.tr(ref),
        onRetry: null,
      ),
    ),
  );

  Widget _buildEmpty() => CandyScaffold(
    appBar: AppBar(
      title: Text('measurements_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CandyEmptyState(
            icon: Icons.monitor_weight_outlined,
            title: 'export_no_data'.tr(ref),
            message: 'Chưa có chỉ số cơ thể nào. Thêm lần đo đầu tiên.',
            actionLabel: 'add_measurement'.tr(ref),
            onAction: () => _openAddDialog(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );

  Widget _buildContent(
    List<BodyMeasurement> measurements,
    Map<BodyMeasurementType, BodyMeasurement> latestByType,
  ) {
    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          'measurements_title'.tr(ref),
          style: const TextStyle(fontFamily: CandyFonts.display),
        ),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
        actions: [
          CandyButton(
            label: 'add_measurement'.tr(ref),
            variant: CandyButtonVariant.secondary,
            size: CandyButtonSize.small,
            isFullWidth: false,
            onPressed: () => _openAddDialog(),
            icon: Icons.add,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Latest per type as stat tiles.
            ...latestByType.entries.map((entry) {
              final m = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CandyStatTile(
                  label: '${m.type.labelKey}'.tr(ref),
                  value:
                      '${_valueText(m.value)} ${m.unit.wireValue.toUpperCase()}',
                  subtitle:
                      '${'measured_at'.tr(ref)}: ${_formatDate(m.measuredAt)}',
                  accentColor: CandyColors.hotPink,
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            // History list (chronological newest first).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Lịch sử đo lường'.tr(ref),
                style: const TextStyle(
                  fontFamily: CandyFonts.display,
                  fontSize: 16,
                  color: CandyColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...measurements.map((m) => _historyRow(m)).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _historyRow(BodyMeasurement m) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${m.type.labelKey}'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 14,
                    color: CandyColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(m.measuredAt)} '
                  '${m.notes != null ? '• ${m.notes}' : ''}',
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    color: CandyColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${_valueText(m.value)} ${m.unit.wireValue.toUpperCase()}',
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 16,
                color: CandyColors.hotPink,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
