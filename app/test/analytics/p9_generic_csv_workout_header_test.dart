import 'package:app/features/analytics/data/csv_import_service.dart';
import 'package:app/features/analytics/domain/import_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generic CSV workout column supplies the exercise name', () {
    const csv = 'date,workout,reps,weight\n2026-11-01,Squat,5,60';

    final preview = CsvImportService().parse(csv);

    expect(preview.format, ImportFormat.genericCsv);
    expect(preview.workouts, hasLength(1));
    expect(preview.workouts.single.exercises.single.sourceName, 'Squat');
  });
}
