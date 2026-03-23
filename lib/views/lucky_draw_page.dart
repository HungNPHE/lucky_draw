import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../theme/tet_theme.dart';
import '../viewmodels/lucky_draw_viewmodel.dart';
import 'widgets/lucky_wheel.dart';
import 'widgets/history_list.dart';
import 'widgets/rule_dialog.dart';
import 'widgets/tag_input_field.dart';
import 'widgets/named_value_input.dart';
import 'widgets/range_input_field.dart';

class LuckyDrawPage extends StatefulWidget {
  const LuckyDrawPage({super.key});

  @override
  State<LuckyDrawPage> createState() => _LuckyDrawPageState();
}

class _LuckyDrawPageState extends State<LuckyDrawPage>
    with TickerProviderStateMixin {
  final TextEditingController _customValuesController = TextEditingController();
  final FocusNode _customValuesFocusNode = FocusNode();
  bool _didInitControllers = false;

  late final ConfettiController _confettiController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  LuckyDrawViewModel? _vm;
  bool _prevSpinning = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<LuckyDrawViewModel>();

    if (!_didInitControllers) {
      _customValuesController.text = vm.customValuesInput;
      _didInitControllers = true;
    }

    if (!identical(_vm, vm)) {
      _vm?.removeListener(_onVmChanged);
      _vm = vm;
      _prevSpinning = vm.isSpinning;
      _vm!.addListener(_onVmChanged);
    }
  }

  int? _getMaxValue(LuckyDrawViewModel vm) {
    if (vm.mode == SpinMode.range) return vm.maxNumber;
    final values = vm.customValues;
    if (values.isEmpty) return null;
    var max = values.first;
    for (final v in values.skip(1)) {
      if (v > max) max = v;
    }
    return max;
  }

  void _onVmChanged() {
    final vm = _vm;
    if (vm == null) return;
    final finishedSpinning = _prevSpinning && !vm.isSpinning;
    if (finishedSpinning && vm.currentNumber != null) {
      final maxValue = _getMaxValue(vm);
      if (maxValue != null && vm.currentNumber == maxValue) {
        _confettiController.play();
      }
    }
    _prevSpinning = vm.isSpinning;
  }

  @override
  void dispose() {
    _vm?.removeListener(_onVmChanged);
    _confettiController.dispose();
    _pulseController.dispose();
    _customValuesController.dispose();
    _customValuesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LuckyDrawViewModel>();

    if (!_customValuesFocusNode.hasFocus &&
        _customValuesController.text != vm.customValuesInput) {
      _customValuesController.value = TextEditingValue(
        text: vm.customValuesInput,
        selection:
        TextSelection.collapsed(offset: vm.customValuesInput.length),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TetTheme.bgGradientStart,
              TetTheme.bgGradientMid,
              TetTheme.bgGradientEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative background circles - dịu hơn
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TetTheme.redPrimary.withOpacity(0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TetTheme.gold.withOpacity(0.03),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: _buildHeader(context),
                      ),

                      // Lucky Wheel Content
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildWheelCard(context, vm),
                            _buildSettingsCard(context, vm),
                            _buildSpinButton(context, vm),
                          ],
                        ),
                      ),

                      // History header
                      SliverToBoxAdapter(
                        child: _buildHistoryHeader(context, vm),
                      ),

                      // History items
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => HistoryList.buildTile(
                            item: vm.history[index],
                            index: index,
                          ),
                          childCount: vm.history.length,
                        ),
                      ),

                      if (vm.history.isEmpty)
                        SliverToBoxAdapter(
                          child: _buildEmptyHistory(),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                    ],
                  ),
                ),
              ),

              // Confetti
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    emissionFrequency: 0.02,
                    numberOfParticles: 30,
                    maxBlastForce: 26,
                    minBlastForce: 14,
                    gravity: 0.25,
                    colors: const [
                      TetTheme.redPrimary,
                      TetTheme.gold,
                      TetTheme.goldLight,
                      Colors.yellow,
                      Colors.white,
                      Color(0xFFFF6B6B),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
      child: Row(
        children: [
          // Icon bao bì đỏ
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TetTheme.gold.withOpacity(0.9),
                  TetTheme.goldLight.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: TetTheme.gold.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text('🧧', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [TetTheme.goldLight, TetTheme.gold],
                  ).createShader(bounds),
                  child: const Text(
                    'Lì Xì May Mắn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quay số – bốc lì xì vui cả nhà 🎊',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.65),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          _GlassButton(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const RuleDialog(),
              );
            },
            child: const Icon(Icons.info_outline_rounded,
                color: TetTheme.goldLight, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelCard(BuildContext context, LuckyDrawViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: _GlassCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: TetTheme.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Vòng quay may mắn',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TetTheme.gold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: LuckyWheel(
                isSpinning: vm.isSpinning,
                result: vm.currentName ?? vm.currentNumber,
                values: (vm.mode == SpinMode.range && vm.rangeValues.isNotEmpty) ? vm.rangeValues : null,
                stringValues: (vm.mode == SpinMode.customList && vm.wheelValues.isNotEmpty) ? vm.wheelValues : null,
              ),
            ),
            if (vm.currentNumber != null && !vm.isSpinning) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TetTheme.redPrimary.withOpacity(0.15),
                      TetTheme.gold.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: TetTheme.gold.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎁 ', style: TextStyle(fontSize: 16)),
                        Text(
                          'Kết quả: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (vm.currentName != null) ...[
                          Text(
                            '${vm.currentName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: TetTheme.goldLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '${vm.currentNumber}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: TetTheme.goldLight,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, LuckyDrawViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: TetTheme.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Thiết lập vòng quay',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TetTheme.gold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mode selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: Colors.white.withOpacity(0.08), width: 1),
              ),
              child: Row(
                children: [
                  _ModeTab(
                    label: 'Khoảng số',
                    icon: Icons.linear_scale_rounded,
                    selected: vm.mode == SpinMode.range,
                    onTap: () => vm.setMode(SpinMode.range),
                  ),
                  _ModeTab(
                    label: 'Danh sách',
                    icon: Icons.format_list_numbered_rounded,
                    selected: vm.mode == SpinMode.customList,
                    onTap: () => vm.setMode(SpinMode.customList),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position:
                  Tween(begin: const Offset(0, 0.06), end: Offset.zero)
                      .animate(anim),
                  child: child,
                ),
              ),
              child: vm.mode == SpinMode.range
                  ? _buildRangeInput(vm)
                  : _buildCustomListInput(vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeInput(LuckyDrawViewModel vm) {
    return Column(
      key: const ValueKey('range'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập các giá trị – ngăn cách bằng dấu phẩy, dấu cách hoặc Enter',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        RangeInputField(
          initialValue: vm.minNumber,
          finalValue: vm.maxNumber,
          onInitialChanged: (value) => vm.setRangeMin(value.toString()),
          onFinalChanged: (value) => vm.setRangeMax(value.toString()),
          hint: 'VD: 1, 100',
          label: 'Khoảng số',
        ),
        const SizedBox(height: 8),
        // Quick range chips
        Wrap(
          spacing: 8,
          children: [
            _QuickChip(
              label: '1 – 10',
              onTap: () {
                vm.setRangeMin('1');
                vm.setRangeMax('10');
              },
            ),
            _QuickChip(
              label: '1 – 50',
              onTap: () {
                vm.setRangeMin('1');
                vm.setRangeMax('50');
              },
            ),
            _QuickChip(
              label: '1 – 100',
              onTap: () {
                vm.setRangeMin('1');
                vm.setRangeMax('100');
              },
            ),
            _QuickChip(
              label: '1 – 1000',
              onTap: () {
                vm.setRangeMin('1');
                vm.setRangeMax('1000');
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Current range display
        if (vm.minNumber <= vm.maxNumber)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.arrow_right_alt_rounded,
                    color: TetTheme.gold.withOpacity(0.7), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Sẽ quay từ ${vm.minNumber} đến ${vm.maxNumber}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: TetTheme.goldLight.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCustomListInput(LuckyDrawViewModel vm) {
    return Column(
      key: const ValueKey('list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NamedValueInput(

          initialValues: vm.namedValues,
          onChanged: (values) {
            vm.setNamedValues(values);
          },
          onRemoveValue: (value) {
            vm.removeCustomValue(value.display);
          },
        ),
      ],
    );
  }

  Widget _buildSpinButton(BuildContext context, LuckyDrawViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: vm.isSpinning ? 1.0 : _pulseAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: vm.isSpinning
                ? LinearGradient(
              colors: [
                Colors.grey.shade700,
                Colors.grey.shade600,
              ],
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TetTheme.goldLight.withOpacity(0.95),
                TetTheme.gold.withOpacity(0.9),
                TetTheme.goldDark.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: vm.isSpinning
                ? []
                : [
              BoxShadow(
                color: TetTheme.gold.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: TetTheme.redPrimary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: vm.isSpinning
                  ? null
                  : () async {
                if (vm.mode == SpinMode.customList &&
                    vm.customValues.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Vui lòng nhập danh sách giá trị hợp lệ.'),
                    ),
                  );
                  return;
                }
                HapticFeedback.heavyImpact();
                await vm.spin();
                if (!context.mounted) return;
                if (vm.mode == SpinMode.customList &&
                    vm.currentNumber != null) {
                  final number = vm.currentNumber!;
                  final name = vm.currentName;
                  final keep = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => _ResultDialog(number: number, name: name),
                  );
                  if (keep == false) {
                    // Xóa theo tên hiển thị nếu có, hoặc theo số
                    final valueToRemove = name ?? number;
                    vm.removeCustomValue(valueToRemove);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text('Đã xóa $valueToRemove khỏi danh sách.')),
                    );
                  }
                }
              },
              child: Center(
                child: vm.isSpinning
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Đang quay...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🎡', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Text(
                      'QUAY NGAY',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: TetTheme.redDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryHeader(BuildContext context, LuckyDrawViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: TetTheme.goldLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Lịch sử quay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          if (vm.history.isNotEmpty)
            _GlassButton(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xóa lịch sử?'),
                    content: const Text(
                        'Toàn bộ lịch sử quay sẽ bị xóa. Bạn có chắc không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: TetTheme.redPrimary),
                        onPressed: () {
                          vm.clearHistory();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Xóa',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: Colors.white.withOpacity(0.6), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    'Xóa',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Text('🎴',
                  style: TextStyle(
                      fontSize: 32, color: Colors.white.withOpacity(0.25))),
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có lượt quay nào',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hãy quay để bắt đầu!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── Sub-widgets ───────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        child: child,
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [TetTheme.redPrimary, Color(0xFFE0323A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
              BoxShadow(
                color: TetTheme.redPrimary.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : Colors.white.withOpacity(0.45),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: TetTheme.gold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: TetTheme.gold.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: TetTheme.goldLight.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int number;
  final String? name;
  const _ResultDialog({required this.number, this.name});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a0a0a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          if (name != null && name!.isNotEmpty) ...[
            Text(
              name!,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Giá trị may mắn!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Text(
              '$number',
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: TetTheme.goldLight,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Số may mắn!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      content: const Text(
        'Giữ giá trị này trong danh sách hay xóa khỏi vòng quay?',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white60, height: 1.5),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Giữ lại',
              style: TextStyle(color: Colors.white60)),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [TetTheme.redPrimary, Color(0xFFE0323A)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Xóa khỏi danh sách',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}