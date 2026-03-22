import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/tet_theme.dart';
import '../../viewmodels/lucky_draw_viewmodel.dart';

/// Widget nhập danh sách giá trị bất kỳ (chữ, số hoặc kết hợp)
/// VD: "1", "a", "b", "c", "3", "Giải 1", "An"
class NamedValueInput extends StatefulWidget {
  final List<NamedValue> initialValues;
  final ValueChanged<List<NamedValue>> onChanged;

  const NamedValueInput({
    super.key,
    required this.initialValues,
    required this.onChanged,
  });

  @override
  State<NamedValueInput> createState() => _NamedValueInputState();
}

class _NamedValueInputState extends State<NamedValueInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<NamedValue> _items = [];

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialValues);
  }

  @override
  void didUpdateWidget(covariant NamedValueInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus) {
      final newItems = List<NamedValue>.from(widget.initialValues);
      if (!_listEquals(newItems, _items)) {
        setState(() => _items = newItems);
      }
    }
  }

  bool _listEquals(List<NamedValue> a, List<NamedValue> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].display != b[i].display) return false;
    }
    return true;
  }

  /// Parse input text - nhận bất kỳ giá trị nào
  /// Nếu là số thì lưu cả numericValue để quay
  NamedValue? _parseInput(String input) {
    input = input.trim();
    if (input.isEmpty) return null;
    
    // Try to parse as number
    final numericValue = int.tryParse(input);
    
    return NamedValue(
      display: input,
      numericValue: numericValue,
    );
  }

  void _addItem() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    
    final value = _parseInput(input);
    if (value == null) return;

    setState(() {
      _items.add(value);
      _controller.clear();
    });
    
    widget.onChanged(List.from(_items));
    _focusNode.requestFocus();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    widget.onChanged(List.from(_items));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Single input field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'VD: 1, a, b, c, 3, Giải 1...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TetTheme.gold.withOpacity(0.9),
                        TetTheme.goldLight.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: TetTheme.redDark,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Items list
        if (_items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _items.asMap().entries.map((e) {
              return _NamedValueChip(
                item: e.value,
                onRemove: () => _removeItem(e.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.casino_rounded,
                color: TetTheme.gold.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${_items.length} giá trị trong vòng quay',
                style: TextStyle(
                  fontSize: 12.5,
                  color: TetTheme.goldLight.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NamedValueChip extends StatelessWidget {
  final NamedValue item;
  final VoidCallback onRemove;

  const _NamedValueChip({
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TetTheme.surfaceLight.withOpacity(0.8),
            TetTheme.surfaceDark.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TetTheme.gold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.display,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
