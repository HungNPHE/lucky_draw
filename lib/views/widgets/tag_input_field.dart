import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/tet_theme.dart';

/// Widget nhập số dạng "tag" – người dùng nhập số rồi
/// nhấn dấu phẩy (,) / dấu cách / Enter để xác nhận thêm tag.
class TagInputField extends StatefulWidget {
  final List<int> initialValues;
  final ValueChanged<List<int>> onChanged;
  final String hint;
  final String label;

  const TagInputField({
    super.key,
    required this.initialValues,
    required this.onChanged,
    required this.hint,
    required this.label,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<int> _tags = [];

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialValues);
  }

  @override
  void didUpdateWidget(covariant TagInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync từ bên ngoài nếu không đang focus
    if (!_focusNode.hasFocus) {
      final newTags = List<int>.from(widget.initialValues);
      if (!_listEquals(newTags, _tags)) {
        setState(() => _tags = newTags);
      }
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _tryAddFromController() {
    final raw = _controller.text
        .replaceAll(',', ' ')
        .trim();
    if (raw.isEmpty) return;

    // Có thể dán nhiều số cùng lúc
    final parts = raw.split(RegExp(r'[\s,]+'));
    bool changed = false;
    for (final p in parts) {
      final v = int.tryParse(p.trim());
      if (v != null) {
        _tags.add(v);
        changed = true;
      }
    }
    if (changed) {
      _controller.clear();
      setState(() {});
      widget.onChanged(List.from(_tags));
    }
  }

  void _removeTag(int index) {
    setState(() => _tags.removeAt(index));
    widget.onChanged(List.from(_tags));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TetTheme.surfaceDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focusNode.hasFocus
                ? TetTheme.gold.withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: _focusNode.hasFocus ? 1.5 : 1,
          ),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ..._tags.asMap().entries.map((e) => _TagChip(
              value: e.value,
              onRemove: () => _removeTag(e.key),
            )),
            // Input field
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 220),
                child: Focus(
                  onFocusChange: (hasFocus) => setState(() {}),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: _tags.isEmpty ? widget.hint : 'Thêm số...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                    inputFormatters: [
                      // Cho phép số, dấu phẩy, dấu trừ (số âm)
                      FilteringTextInputFormatter.allow(RegExp(r'[-\d,\s]')),
                    ],
                    onChanged: (val) {
                      // Tách khi gặp dấu phẩy hoặc dấu cách
                      if (val.contains(',') || val.endsWith(' ')) {
                        _tryAddFromController();
                      }
                    },
                    onSubmitted: (_) {
                      _tryAddFromController();
                      _focusNode.requestFocus();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final int value;
  final VoidCallback onRemove;

  const _TagChip({required this.value, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4, right: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B0000),
            TetTheme.redPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TetTheme.redPrimary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}