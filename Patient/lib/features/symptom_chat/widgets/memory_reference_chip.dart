import 'package:flutter/material.dart';

/// Memory reference chip — shows prior related symptom references from
/// existing chat history. Pure UI interpretation, no backend changes.
class MemoryReferenceChip extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final String currentBodyRegion;

  const MemoryReferenceChip({
    super.key,
    required this.messages,
    required this.currentBodyRegion,
  });

  /// Scans existing chat history for prior mentions of related body regions.
  List<String> _findRelatedMemories() {
    final references = <String>[];
    final region = currentBodyRegion.toLowerCase();

    // Related region groups for UI hints
    const relatedGroups = {
      'shoulder': ['arm', 'neck', 'upper back'],
      'knee': ['leg', 'hip', 'ankle'],
      'back': ['spine', 'lower back', 'upper back'],
      'head': ['neck', 'temple', 'forehead'],
      'chest': ['heart', 'rib', 'lung'],
      'stomach': ['abdomen', 'gut', 'digestive'],
    };

    final relatedTerms = <String>[region];
    for (final entry in relatedGroups.entries) {
      if (region.contains(entry.key) || entry.value.any((v) => region.contains(v))) {
        relatedTerms.addAll([entry.key, ...entry.value]);
      }
    }

    // Scan older user messages for references
    for (final msg in messages) {
      if (msg['role'] != 'user') continue;
      final text = (msg['text'] ?? '').toString().toLowerCase();
      for (final term in relatedTerms) {
        if (text.contains(term) && !references.any((r) => r.contains(term))) {
          if (text.contains('strain')) {
            references.add('Similar to previous $term strain');
          } else if (text.contains('pain')) {
            references.add('Related to earlier $term pain');
          } else if (text.contains('ache')) {
            references.add('Connected to prior $term ache');
          }
        }
      }
      if (references.length >= 2) break;
    }

    return references;
  }

  @override
  Widget build(BuildContext context) {
    final memories = _findRelatedMemories();
    if (memories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: memories.map((memory) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                  width: 0.7),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.memory_rounded,
                    size: 12, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 5),
                Text(memory,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
