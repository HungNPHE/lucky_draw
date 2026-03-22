import 'package:flutter/material.dart';
import '../../models/racer.dart';
import '../../theme/tet_theme.dart';

class RacingSetup extends StatelessWidget {
  final int racerCount;
  final List<Racer> racers;
  final Function(int) onRacerCountChanged;
  final Function(int, String) onRacerNameChanged;
  final VoidCallback onShuffle;
  final VoidCallback onStart;

  const RacingSetup({
    super.key,
    required this.racerCount,
    required this.racers,
    required this.onRacerCountChanged,
    required this.onRacerNameChanged,
    required this.onShuffle,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TetTheme.redPrimary.withOpacity(0.3),
                    TetTheme.redPrimary.withOpacity(0.1),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: TetTheme.gold.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TetTheme.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: TetTheme.gold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thiết lập cuộc đua',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: TetTheme.gold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Chọn số thú và đặt tên',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Shuffle button
                  GestureDetector(
                    onTap: onShuffle,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.shuffle_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Racer count selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số lượng thú đua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(7, (index) {
                      final count = index + 2;
                      final isSelected = count == racerCount;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onRacerCountChanged(count),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        TetTheme.redPrimary,
                                        Color(0xFFE0323A),
                                      ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? TetTheme.gold.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.1),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: TetTheme.redPrimary.withOpacity(0.3),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(
              height: 1,
              color: Colors.white.withOpacity(0.1),
              indent: 16,
              endIndent: 16,
            ),
            
            // Racer name inputs
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đặt tên cho các thú',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...racers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final racer = entry.value;
                    
                    return _RacerNameInput(
                      index: index,
                      racer: racer,
                      onNameChanged: (name) => onRacerNameChanged(index, name),
                    );
                  }),
                ],
              ),
            ),
            
            // Start button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GestureDetector(
                onTap: onStart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TetTheme.goldLight,
                        TetTheme.gold,
                        TetTheme.goldDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: TetTheme.gold.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '🏁',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'BẮT ĐẦU ĐUA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: TetTheme.redDark,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
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

class _RacerNameInput extends StatefulWidget {
  final int index;
  final Racer racer;
  final Function(String) onNameChanged;

  const _RacerNameInput({
    required this.index,
    required this.racer,
    required this.onNameChanged,
  });

  @override
  State<_RacerNameInput> createState() => _RacerNameInputState();
}

class _RacerNameInputState extends State<_RacerNameInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.racer.name);
  }

  @override
  void didUpdateWidget(_RacerNameInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.racer.name != widget.racer.name &&
        _controller.text != widget.racer.name) {
      _controller.text = widget.racer.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Emoji avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.racer.color.withOpacity(0.8),
                  widget.racer.color.withOpacity(0.5),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.racer.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: widget.onNameChanged,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Tên thú ${widget.index + 1}',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: widget.racer.color.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
