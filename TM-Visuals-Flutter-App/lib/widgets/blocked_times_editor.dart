import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/blocked_time_range.dart';

String _label(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

/// Edits a draft. The parent owns loading, whole-day availability, and saving.
/// When switching dates, key this widget by date to discard the old dialog.
class BlockedTimesEditor extends StatefulWidget {
  const BlockedTimesEditor({
    super.key,
    required this.ranges,
    required this.enabled,
    required this.onChanged,
  });

  final List<BlockedTimeRange> ranges;
  final bool enabled;
  final ValueChanged<List<BlockedTimeRange>> onChanged;

  @override
  State<BlockedTimesEditor> createState() => _BlockedTimesEditorState();
}

class _BlockedTimesEditorState extends State<BlockedTimesEditor> {
  Future<void> _edit([int? index]) async {
    final original = List<BlockedTimeRange>.of(widget.ranges);
    final initial = index == null
        ? BlockedTimeRange(startMinutes: 360, endMinutes: 420)
        : original[index];
    final remaining = [
      for (var i = 0; i < original.length; i++)
        if (i != index) original[i],
    ];
    final result = await showDialog<BlockedTimeRange>(
      context: context,
      builder: (_) => _BlockedTimeDialog(initial: initial, others: remaining),
    );
    // An in-flight load or save must not be overwritten by an old dialog.
    if (!mounted ||
        !widget.enabled ||
        result == null ||
        !listEquals(original, widget.ranges)) {
      return;
    }
    widget.onChanged(
      [...remaining, result]
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes)),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Blocked times', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (widget.ranges.isEmpty) const Text('No blocked periods.'),
      for (var index = 0; index < widget.ranges.length; index++)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            '${_label(widget.ranges[index].startMinutes)} – ${_label(widget.ranges[index].endMinutes)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit blocked time',
                onPressed: widget.enabled ? () => _edit(index) : null,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Remove blocked time',
                onPressed: widget.enabled
                    ? () {
                        widget.onChanged([...widget.ranges]..removeAt(index));
                      }
                    : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: widget.enabled ? () => _edit() : null,
        icon: const Icon(Icons.add),
        label: const Text('Add blocked time'),
      ),
    ],
  );
}

class _BlockedTimeDialog extends StatefulWidget {
  const _BlockedTimeDialog({required this.initial, required this.others});
  final BlockedTimeRange initial;
  final List<BlockedTimeRange> others;

  @override
  State<_BlockedTimeDialog> createState() => _BlockedTimeDialogState();
}

class _BlockedTimeDialogState extends State<_BlockedTimeDialog> {
  late int start = widget.initial.startMinutes;
  late int end = widget.initial.endMinutes;
  String? error;

  Future<void> _pick(bool isStart) async {
    final minutes = isStart ? start : end;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!mounted || time == null) return;
    setState(() {
      if (isStart) {
        start = time.hour * 60 + time.minute;
      } else {
        end = time.hour * 60 + time.minute;
      }
      error = null;
    });
  }

  void _save() {
    if (end <= start) {
      setState(() => error = 'End time must be later than start time.');
      return;
    }
    final range = BlockedTimeRange(startMinutes: start, endMinutes: end);
    final issue = BlockedTimeRange.validate([...widget.others, range]);
    if (issue != null) {
      setState(() => error = issue);
      return;
    }
    Navigator.of(context).pop(range);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Blocked period'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton(
          key: const ValueKey('blocked-start'),
          onPressed: () => _pick(true),
          child: Text('Start time: ${_label(start)}'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey('blocked-end'),
          onPressed: () => _pick(false),
          child: Text('End time: ${_label(end)}'),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save period')),
    ],
  );
}
