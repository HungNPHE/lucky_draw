import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/tet_theme.dart';

/// Widget nhập khoảng số với 2 ô riêng biệt (từ số - đến số)
class RangeInputField extends StatefulWidget {
  final int initialValue;
  final int finalValue;
  final ValueChanged<int> onInitialChanged;
  final ValueChanged<int> onFinalChanged;
  final String hint;
  final String label;

  const RangeInputField({
    super.key,
    required this.initialValue,
    required this.finalValue,
    required this.onInitialChanged,
    required this.onFinalChanged,
    required this.hint,
    required this.label,
  });

  @override
  State<RangeInputField> createState() => _RangeInputFieldState();
}

class _RangeInputFieldState extends State<RangeInputField> {
  late TextEditingController _initialController;
  late TextEditingController _finalController;
  final FocusNode _initialFocusNode = FocusNode();
  final FocusNode _finalFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initialController = TextEditingController(text: widget.initialValue.toString());
    _finalController = TextEditingController(text: widget.finalValue.toString());
  }

  @override
  void didUpdateWidget(covariant RangeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Sync từ bên ngoài nếu không đang focus
    if (!_initialFocusNode.hasFocus && 
        _initialController.text != widget.initialValue.toString()) {
      _initialController.text = widget.initialValue.toString();
    }
    
    if (!_finalFocusNode.hasFocus && 
        _finalController.text != widget.finalValue.toString()) {
      _finalController.text = widget.finalValue.toString();
    }
  }

  void _onInitialChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      widget.onInitialChanged(parsed);
    }
  }

  void _onFinalChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      widget.onFinalChanged(parsed);
    }
  }

  @override
  void dispose() {
    _initialController.dispose();
    _finalController.dispose();
    _initialFocusNode.dispose();
    _finalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // From number field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Từ số',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _initialController,
                    focusNode: _initialFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: '1',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.3),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: TetTheme.surfaceDark.withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TetTheme.gold.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _onInitialChanged,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Arrow separator
            Icon(
              Icons.arrow_forward_rounded,
              color: TetTheme.gold.withOpacity(0.6),
              size: 20,
            ),
            
            const SizedBox(width: 12),
            
            // To number field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đến số',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _finalController,
                    focusNode: _finalFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: '100',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.3),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: TetTheme.surfaceDark.withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TetTheme.gold.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _onFinalChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
