import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../data/models/dream_model.dart';

const _emojiOptions = ['🏛️', '🚀', '🗾', '🏡', '💰', '🎓', '🎨'];
const _colorOptions = [AppColors.indigo500, AppColors.amber500, AppColors.sky500, AppColors.mint500];

Future<void> showAddDreamSheet(BuildContext context, {required ValueChanged<DreamModel> onSave}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddDreamSheet(onSave: onSave),
  );
}

class _AddDreamSheet extends StatefulWidget {
  final ValueChanged<DreamModel> onSave;
  const _AddDreamSheet({required this.onSave});

  @override
  State<_AddDreamSheet> createState() => _AddDreamSheetState();
}

class _AddDreamSheetState extends State<_AddDreamSheet> {
  final _title = TextEditingController();
  final _motivation = TextEditingController();
  String _emoji = _emojiOptions.first;
  Color _color = _colorOptions.first;
  DateTime _target = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _title.dispose();
    _motivation.dispose();
    super.dispose();
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    widget.onSave(DreamModel(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      emoji: _emoji,
      motivation: _motivation.text.trim().isEmpty ? 'A goal worth working toward.' : _motivation.text.trim(),
      target: _target,
      color: _color,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: p.bgSurface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: p.borderStrong, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Define a New Dream', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Dream title', hintText: 'e.g. Become a Software Architect')),
            const SizedBox(height: 16),
            Text('Emoji', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojiOptions.map((e) {
                final active = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: active ? p.brand : p.bgSunken,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(e, style: const TextStyle(fontSize: 18)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _colorOptions.map((c) {
                final active = c == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: active ? Border.all(color: p.textPrimary, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motivation,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Motivation — why does this matter?', hintText: 'Write a sentence that reminds future-you why you started…'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _target, firstDate: DateTime.now(), lastDate: DateTime(2100));
                if (picked != null) setState(() => _target = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Target date'),
                child: Text('${_target.year}-${_target.month.toString().padLeft(2, '0')}-${_target.day.toString().padLeft(2, '0')}'),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(label: 'Save Dream', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
