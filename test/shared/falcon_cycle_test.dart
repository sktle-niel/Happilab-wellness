import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/shared/widgets/falcon.dart';

void main() {
  /// Whatever the clip, it must never ask for a frame the tool did not render.
  void expectEveryFrameExists(FalconClip clip) {
    final cycle = FalconCycle(clip);
    for (var ms = 0; ms < cycle.total.inMilliseconds; ms += 7) {
      expect(
        cycle.frameAt(Duration(milliseconds: ms)),
        inInclusiveRange(0, clip.frameCount - 1),
        reason: '${clip.name} at ${ms}ms',
      );
    }
  }

  group('FalconCycle — the mark', () {
    const clip = FalconClip.mark;
    const cycle = FalconCycle(clip);

    final looping = clip.loop * clip.loops;
    final closed = clip.frameCount - 1;

    test('runs loop, tail, rest, and the tail back again', () {
      expect(cycle.total, looping + clip.tail * 2 + clip.rest);
    });

    test('opens on the first frame of the loop', () {
      expect(cycle.frameAt(Duration.zero), 0);
    });

    test('walks the loop frames across one turn', () {
      expect(cycle.frameAt(clip.loop ~/ 2), clip.loopFrames ~/ 2);
      expect(
        cycle.frameAt(clip.loop - const Duration(milliseconds: 1)),
        clip.loopFrames - 1,
      );
    });

    test('starts the loop over on every turn', () {
      for (var turn = 0; turn < clip.loops; turn++) {
        expect(cycle.frameAt(clip.loop * turn), 0, reason: 'turn $turn');
      }
    });

    test('folds once the last turn is done', () {
      expect(cycle.frameAt(looping), clip.loopFrames);
      expect(
        cycle.frameAt(looping + clip.tail - const Duration(milliseconds: 1)),
        closed,
      );
    });

    test('holds the closed frame for the whole rest', () {
      final rested = looping + clip.tail;
      expect(cycle.frameAt(rested), closed);
      expect(cycle.frameAt(rested + clip.rest ~/ 2), closed);
      expect(
        cycle.frameAt(rested + clip.rest - const Duration(milliseconds: 1)),
        closed,
      );
    });

    test('opens by running the tail backwards', () {
      final opening = looping + clip.tail + clip.rest;

      expect(
        cycle.frameAt(opening + clip.tail ~/ 2),
        closed - clip.tailFrames ~/ 2,
      );
      // And it lands back where the loop picks up.
      expect(
        cycle.frameAt(opening + clip.tail - const Duration(milliseconds: 1)),
        clip.loopFrames,
      );
    });

    test('comes round again', () {
      expect(cycle.frameAt(cycle.total), cycle.frameAt(Duration.zero));
      expect(
        cycle.frameAt(cycle.total * 3 + clip.loop ~/ 2),
        cycle.frameAt(clip.loop ~/ 2),
      );
    });

    test('never asks for a frame that was not rendered', () {
      expectEveryFrameExists(clip);
    });
  });

  group('FalconCycle — the loader', () {
    const clip = FalconClip.loader;
    const cycle = FalconCycle(clip);

    test('is nothing but the loop', () {
      expect(cycle.total, clip.loop);
      expect(clip.tailFrames, 0);
    });

    test('never stops, because a loader that stops looks broken', () {
      for (var ms = 0; ms < cycle.total.inMilliseconds; ms += 7) {
        expect(
          cycle.frameAt(Duration(milliseconds: ms)),
          lessThan(clip.loopFrames),
          reason: 'at ${ms}ms',
        );
      }
    });
  });
}
