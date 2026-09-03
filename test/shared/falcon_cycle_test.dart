import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/shared/widgets/falcon.dart';

void main() {
  group('FalconCycle', () {
    for (final clip in FalconClip.values) {
      group(clip.name, () {
        final cycle = clip.cycle;

        test('is nothing but its loop', () {
          expect(cycle.total, clip.loop);
        });

        test('opens on the first frame', () {
          expect(cycle.frameAt(Duration.zero), 0);
        });

        test('walks the frames across one turn', () {
          expect(cycle.frameAt(clip.loop ~/ 2), clip.frameCount ~/ 2);
          expect(
            cycle.frameAt(clip.loop - const Duration(milliseconds: 1)),
            clip.frameCount - 1,
          );
        });

        test('comes round again', () {
          expect(cycle.frameAt(clip.loop), 0);
          expect(
            cycle.frameAt(clip.loop * 3 + clip.loop ~/ 2),
            cycle.frameAt(clip.loop ~/ 2),
          );
        });

        test('never asks for a frame that was not rendered', () {
          for (var ms = 0; ms < cycle.total.inMilliseconds; ms += 7) {
            expect(
              cycle.frameAt(Duration(milliseconds: ms)),
              inInclusiveRange(0, clip.frameCount - 1),
              reason: '${clip.name} at ${ms}ms',
            );
          }
        });
      });
    }
  });
}
