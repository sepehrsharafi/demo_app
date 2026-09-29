import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_nav_bar.dart';

/// A [Hero.flightShuttleBuilder] that keeps a photo in flight beneath the
/// tab bar's island.
///
/// Hero flights are drawn in the navigator's overlay, above every page and
/// so above the island too. A photo opened from near the bottom of Learn
/// would cross over the island on its way into the article and back, and
/// then drop behind it as it landed. This cuts the island's shape out of
/// the flying photo, so it is always beneath, as it is at rest.
Widget flyBeneathIsland(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final toHero = toHeroContext.widget as Hero;
  return _BeneathIsland(child: toHero.child);
}

class _BeneathIsland extends SingleChildRenderObjectWidget {
  const _BeneathIsland({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBeneathIsland();
}

class _RenderBeneathIsland extends RenderProxyBox {
  // The flight moves every frame, so the island's place relative to it has
  // to be worked out at paint time rather than layout time.
  @override
  bool get alwaysNeedsCompositing => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final island = _islandRect();
    if (island == null) {
      super.paint(context, offset);
      return;
    }
    final origin = localToGlobal(Offset.zero);
    final bounds = Offset.zero & size;
    final hole = RRect.fromRectAndRadius(
      island.shift(-origin),
      Radius.circular(island.height / 2),
    );
    if (!bounds.overlaps(hole.outerRect)) {
      super.paint(context, offset);
      return;
    }
    final visible = Path.combine(
      PathOperation.difference,
      Path()..addRect(bounds),
      Path()..addRRect(hole),
    );
    context.pushClipPath(
      needsCompositing,
      offset,
      bounds,
      visible,
      super.paint,
    );
  }

  /// The island in global coordinates, if it is on screen.
  static Rect? _islandRect() {
    final box = navIslandKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
