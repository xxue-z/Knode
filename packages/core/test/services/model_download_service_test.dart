import 'package:test/test.dart';
import 'package:core/services/model_download_service.dart';
import 'package:core/models/local_model.dart';

void main() {
  group('ModelDownloadService', () {
    group('filterModelsByRam', () {
      LocalModel createModel(String id, String minRam) {
        return LocalModel(
          id: id,
          name: 'Test Model',
          size: '1 GB',
          minRam: minRam,
          description: 'Test',
          quantization: 'Q4_K_M',
          downloadUrls: {'global': 'https://example.com/model.gguf'},
        );
      }

      test('filters out models that require more than 80% of total memory', () {
        final models = [
          createModel('small', '2 GB'),
          createModel('medium', '6 GB'),
          createModel('large', '16 GB'),
        ];

        final filtered = ModelDownloadService.filterModelsByRam(
          models: models,
          totalMemoryGB: 8.0,
        );

        expect(filtered.length, 2);
        expect(filtered.map((m) => m.id), containsAll(['small', 'medium']));
        expect(filtered.map((m) => m.id), isNot(contains('large')));
      });

      test('returns all models when skipCheck is true', () {
        final models = [
          createModel('small', '2 GB'),
          createModel('large', '16 GB'),
        ];

        final filtered = ModelDownloadService.filterModelsByRam(
          models: models,
          totalMemoryGB: 8.0,
          skipCheck: true,
        );

        expect(filtered.length, 2);
      });

      test('returns all models when totalMemoryGB is 0', () {
        final models = [
          createModel('small', '2 GB'),
          createModel('large', '16 GB'),
        ];

        final filtered = ModelDownloadService.filterModelsByRam(
          models: models,
          totalMemoryGB: 0.0,
        );

        expect(filtered.length, 2);
      });

      test('model exactly at 80% threshold passes', () {
        final models = [
          createModel('border', '6.4 GB'),
        ];

        final filtered = ModelDownloadService.filterModelsByRam(
          models: models,
          totalMemoryGB: 8.0,
        );

        expect(filtered.length, 1);
      });

      test('model slightly above 80% threshold fails', () {
        final models = [
          createModel('border', '6.5 GB'),
        ];

        final filtered = ModelDownloadService.filterModelsByRam(
          models: models,
          totalMemoryGB: 8.0,
        );

        expect(filtered.length, 0);
      });

      test('handles empty model list', () {
        final filtered = ModelDownloadService.filterModelsByRam(
          models: [],
          totalMemoryGB: 8.0,
        );

        expect(filtered.isEmpty, true);
      });

      test('allows models with unparseable minRam', () {
        final models = [
          createModel('unparseable', ''),
          createModel('invalid', 'abc'),
          createModel('large', '16 GB'),
        ];

        final filtered = ModelDownloadService.filterModelsByRam(
          models: models,
          totalMemoryGB: 8.0,
        );

        expect(filtered.length, 2);
        expect(filtered.map((m) => m.id), containsAll(['unparseable', 'invalid']));
      });

      test('handles MB format correctly', () {
        final models = [
          createModel('small_mb', '512 MB'),
          createModel('large_mb', '2048 MB'),
        ];

        final filtered = ModelDownloadService.filterModelsByRam(
          models: models,
          totalMemoryGB: 2.0,
        );

        expect(filtered.length, 1);
        expect(filtered.first.id, 'small_mb');
      });
    });
  });
}
