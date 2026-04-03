import 'package:flutter/material.dart';

enum BodyPart {
  head,
  neck,
  leftShoulder,
  rightShoulder,
  chest,
  leftUpperArm,
  rightUpperArm,
  abdomen,
  leftElbow,
  rightElbow,
  hipPelvis,
  leftForearm,
  rightForearm,
  leftHand,
  rightHand,
  leftThigh,
  rightThigh,
  leftKnee,
  rightKnee,
  leftShin,
  rightShin,
  leftFoot,
  rightFoot,
}

class InteractiveBodyMap extends StatefulWidget {
  final Function(BodyPart)? onPartSelected;
  final BodyPart? selectedPart;
  final Color highlightColor;

  const InteractiveBodyMap({
    super.key,
    this.onPartSelected,
    this.selectedPart,
    this.highlightColor = const Color.fromRGBO(59, 130, 246, 0.7),
  });

  @override
  State<InteractiveBodyMap> createState() => _InteractiveBodyMapState();
}

class _InteractiveBodyMapState extends State<InteractiveBodyMap> {
  BodyPart? _hoveredPart;

  // Based on 663x1063 image
  final double originalWidth = 663.0;
  final double originalHeight = 1063.0;

  // Tightened bounds — arms/hands pulled inward to hug the anatomy
  final Map<BodyPart, Rect> _bodyPartBounds = {
    BodyPart.head:           const Rect.fromLTRB(269,   5, 394, 135),
    BodyPart.neck:           const Rect.fromLTRB(285, 135, 378, 172),
    BodyPart.leftShoulder:   const Rect.fromLTRB(155, 160, 275, 248),
    BodyPart.rightShoulder:  const Rect.fromLTRB(388, 160, 508, 248),
    BodyPart.chest:          const Rect.fromLTRB(265, 180, 398, 310),
    BodyPart.leftUpperArm:   const Rect.fromLTRB(120, 248, 230, 380),
    BodyPart.rightUpperArm:  const Rect.fromLTRB(433, 248, 543, 380),
    BodyPart.abdomen:        const Rect.fromLTRB(260, 310, 403, 445),
    BodyPart.leftElbow:      const Rect.fromLTRB( 95, 380, 195, 445),
    BodyPart.rightElbow:     const Rect.fromLTRB(468, 380, 568, 445),
    BodyPart.hipPelvis:      const Rect.fromLTRB(248, 445, 415, 555),
    BodyPart.leftForearm:    const Rect.fromLTRB( 65, 445, 165, 570),
    BodyPart.rightForearm:   const Rect.fromLTRB(498, 445, 598, 570),
    BodyPart.leftHand:       const Rect.fromLTRB( 40, 570, 135, 680),
    BodyPart.rightHand:      const Rect.fromLTRB(528, 570, 623, 680),
    BodyPart.leftThigh:      const Rect.fromLTRB(228, 555, 328, 745),
    BodyPart.rightThigh:     const Rect.fromLTRB(335, 555, 435, 745),
    BodyPart.leftKnee:       const Rect.fromLTRB(238, 745, 322, 818),
    BodyPart.rightKnee:      const Rect.fromLTRB(341, 745, 425, 818),
    BodyPart.leftShin:       const Rect.fromLTRB(232, 818, 320, 975),
    BodyPart.rightShin:      const Rect.fromLTRB(343, 818, 431, 975),
    BodyPart.leftFoot:       const Rect.fromLTRB(210, 975, 318, 1058),
    BodyPart.rightFoot:      const Rect.fromLTRB(345, 975, 453, 1058),
  };

  // Map for human-readable labels shown on the body
  static const Map<BodyPart, String> _labels = {
    BodyPart.head: 'Head',
    BodyPart.neck: 'Neck',
    BodyPart.leftShoulder: 'L.Shoulder',
    BodyPart.rightShoulder: 'R.Shoulder',
    BodyPart.chest: 'Chest',
    BodyPart.leftUpperArm: 'L.Arm',
    BodyPart.rightUpperArm: 'R.Arm',
    BodyPart.abdomen: 'Abdomen',
    BodyPart.leftElbow: 'L.Elbow',
    BodyPart.rightElbow: 'R.Elbow',
    BodyPart.hipPelvis: 'Hip',
    BodyPart.leftForearm: 'L.Forearm',
    BodyPart.rightForearm: 'R.Forearm',
    BodyPart.leftHand: 'L.Hand',
    BodyPart.rightHand: 'R.Hand',
    BodyPart.leftThigh: 'L.Thigh',
    BodyPart.rightThigh: 'R.Thigh',
    BodyPart.leftKnee: 'L.Knee',
    BodyPart.rightKnee: 'R.Knee',
    BodyPart.leftShin: 'L.Shin',
    BodyPart.rightShin: 'R.Shin',
    BodyPart.leftFoot: 'L.Foot',
    BodyPart.rightFoot: 'R.Foot',
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: originalWidth / originalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaleX = constraints.maxWidth / originalWidth;
          final scaleY = constraints.maxHeight / originalHeight;

          return Stack(
            children: [
              // Base image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/full_body.png',
                  fit: BoxFit.fill,
                ),
              ),

              // Interactive zones
              ..._bodyPartBounds.entries.map((entry) {
                final part = entry.key;
                final rect = entry.value;

                final isSelected = widget.selectedPart == part;
                final isHovered = _hoveredPart == part;

                return Positioned(
                  left: rect.left * scaleX,
                  top: rect.top * scaleY,
                  width: rect.width * scaleX,
                  height: rect.height * scaleY,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredPart = part),
                    onExit: (_) => setState(() => _hoveredPart = null),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => widget.onPartSelected?.call(part),
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Dot indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isSelected ? 18 : (isHovered ? 14 : 8),
                                height: isSelected ? 18 : (isHovered ? 14 : 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? widget.highlightColor
                                      : (isHovered
                                          ? widget.highlightColor.withOpacity(0.7)
                                          : widget.highlightColor.withOpacity(0.25)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: isSelected ? 2.5 : 0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: widget.highlightColor.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 3,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              // Label (only shown on select / hover)
                              if (isSelected || isHovered)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _labels[part] ?? '',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF2563EB)
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
