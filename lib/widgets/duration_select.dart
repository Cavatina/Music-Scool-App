import 'package:flutter/material.dart';
import 'package:musicscool/generated/l10n.dart';

enum LessonDuration {
  halfHour,
  hour
}

extension LessonDurationMinutes on LessonDuration {
  int get minutes {
    switch (this) {
      case LessonDuration.halfHour: return 30;
      case LessonDuration.hour: return 60;
    }
  }
}

extension LessonDurationText on LessonDuration {
  String text(BuildContext context) {
    return '${minutes.toString()} ${S.of(context).minutes}';
  }
}

final LessonDuration defaultDuration = LessonDuration.halfHour;

typedef LessonDurationSelect = void Function(LessonDuration selected);

class DurationSelect extends StatefulWidget {
  const DurationSelect({super.key, required this.selected, required this.onSelect});

  final LessonDuration selected;
  final LessonDurationSelect onSelect;

  @override
  State<DurationSelect> createState() => _DurationSelectState();
}

class _DurationSelectState extends State<DurationSelect> {
  _DurationSelectState();
  late LessonDuration selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final double borderWidth = 0;
    List<bool> isSelected = [selected.index == 0, selected.index == 1];
    return LayoutBuilder(builder: (context, constraints) {
      return ToggleButtons(
        renderBorder: false,
        borderRadius: BorderRadius.circular(12),
        borderWidth: borderWidth,
        borderColor: Theme.of(context).colorScheme.secondary,
        constraints: BoxConstraints.expand(width: (constraints.maxWidth - (borderWidth * 3)) / 2),
        isSelected: isSelected,
        selectedColor: Theme.of(context).colorScheme.secondary,
        onPressed: (index) {
          setState(() {
            selected = LessonDuration.values[index];
            widget.onSelect(selected);
          });
        },
        children: LessonDuration.values.map((duration) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(duration.text(context)),
          );
        }).toList(),
      );
    });
  }
}