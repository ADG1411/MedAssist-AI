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

  // Accurately mapped bounds for 663×1063 full_body.png front anatomy
  final Map<BodyPart, Rect> _bodyPartBounds = {
    BodyPart.head:           const Rect.fromLTRB(280,  12, 383, 125),
    BodyPart.neck:           const Rect.fromLTRB(298, 125, 365, 168),
    BodyPart.leftShoulder:   const Rect.fromLTRB(195, 168, 280, 225),
    BodyPart.rightShoulder:  const Rect.fromLTRB(383, 168, 468, 225),
    BodyPart.chest:          const Rect.fromLTRB(280, 172, 383, 300),
    BodyPart.leftUpperArm:   const Rect.fromLTRB(150, 225, 232, 358),
    BodyPart.rightUpperArm:  const Rect.fromLTRB(431, 225, 513, 358),
    BodyPart.abdomen:        const Rect.fromLTRB(275, 300, 388, 432),
    BodyPart.leftElbow:      const Rect.fromLTRB(122, 358, 200, 418),
    BodyPart.rightElbow:     const Rect.fromLTRB(463, 358, 541, 418),
    BodyPart.hipPelvis:      const Rect.fromLTRB(262, 432, 401, 538),
    BodyPart.leftForearm:    const Rect.fromLTRB( 88, 418, 172, 548),
    BodyPart.rightForearm:   const Rect.fromLTRB(491, 418, 575, 548),
    BodyPart.leftHand:       const Rect.fromLTRB( 82, 538, 162, 635),
    BodyPart.rightHand:      const Rect.fromLTRB(501, 538, 581, 635),
    BodyPart.leftThigh:      const Rect.fromLTRB(250, 538, 330, 714),
    BodyPart.rightThigh:     const Rect.fromLTRB(333, 538, 413, 714),
    BodyPart.leftKnee:       const Rect.fromLTRB(253, 714, 328, 792),
    BodyPart.rightKnee:      const Rect.fromLTRB(335, 714, 410, 792),
    BodyPart.leftShin:       const Rect.fromLTRB(248, 792, 326, 950),
    BodyPart.rightShin:      const Rect.fromLTRB(337, 792, 415, 950),
    BodyPart.leftFoot:       const Rect.fromLTRB(228, 950, 326, 1048),
    BodyPart.rightFoot:      const Rect.fromLTRB(337, 950, 435, 1048),
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
                              // Dot indicator — only visible when selected or hovered
                              if (isSelected || isHovered)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 18 : 14,
                                  height: isSelected ? 18 : 14,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? widget.highlightColor
                                        : widget.highlightColor.withOpacity(0.7),
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
