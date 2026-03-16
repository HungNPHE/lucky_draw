import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../theme/tet_theme.dart';
import '../viewmodels/lucky_draw_viewmodel.dart';
import 'widgets/lucky_wheel.dart';
import 'widgets/history_list.dart';
import 'widgets/rule_dialog.dart';

class LuckyDrawPage extends StatefulWidget {
  const LuckyDrawPage({super.key});

  @override
  State<LuckyDrawPage> createState() => _LuckyDrawPageState();
}

class _LuckyDrawPageState extends State<LuckyDrawPage> {
  final TextEditingController _customValuesController = TextEditingController();
  final FocusNode _customValuesFocusNode = FocusNode();
  bool _didInitControllers = false;

  late final ConfettiController _confettiController;
  LuckyDrawViewModel? _vm;
  bool _prevSpinning = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2200),
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
        selection: TextSelection.collapsed(offset: vm.customValuesInput.length),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TetTheme.redPrimary,
              TetTheme.redDark,
              Color(0xFF2d0f0f),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Lì Xì May Mắn",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            color: TetTheme.gold,
                                            blurRadius: 8,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Quay số nhanh – bốc lì xì cực vui cho cả phòng",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFFFF3C2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline_rounded),
                                color: TetTheme.goldLight,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const RuleDialog(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Vòng quay may mắn",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: TetTheme.redDark),
                                  ),
                                  const SizedBox(height: 12),
                                  LuckyWheel(
                                    isSpinning: vm.isSpinning,
                                    result: vm.currentNumber,
                                    values: vm.mode == SpinMode.customList
                                        ? vm.customValues
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        color: TetTheme.redPrimary,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Thiết lập vòng quay",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<SpinMode>(
                                          title:
                                              const Text("Quay theo khoảng số"),
                                          value: SpinMode.range,
                                          groupValue: vm.mode,
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: TetTheme.redPrimary,
                                          onChanged: (mode) {
                                            if (mode != null) vm.setMode(mode);
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<SpinMode>(
                                          title:
                                              const Text("Quay theo danh sách"),
                                          value: SpinMode.customList,
                                          groupValue: vm.mode,
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: TetTheme.redPrimary,
                                          onChanged: (mode) {
                                            if (mode != null) vm.setMode(mode);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (vm.mode == SpinMode.range) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue:
                                                vm.minNumber.toString(),
                                            keyboardType:
                                                TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Từ số",
                                            ),
                                            onChanged: vm.setRangeMin,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            initialValue:
                                                vm.maxNumber.toString(),
                                            keyboardType:
                                                TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Đến số",
                                            ),
                                            onChanged: vm.setRangeMax,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else
                                    TextField(
                                      controller: _customValuesController,
                                      focusNode: _customValuesFocusNode,
                                      decoration: const InputDecoration(
                                        labelText: "Danh sách giá trị",
                                        hintText:
                                            "VD: 1,10 hoặc 1,3,5,7,10 (cách nhau bởi dấu phẩy)",
                                      ),
                                      onChanged: vm.setCustomValuesInput,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: vm.isSpinning
                                    ? null
                                    : () async {
                                        if (vm.mode == SpinMode.customList &&
                                            vm.customValues.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Vui lòng nhập danh sách giá trị hợp lệ.",
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        await vm.spin();
                                        if (!context.mounted) return;
                                        if (vm.mode == SpinMode.customList &&
                                            vm.currentNumber != null) {
                                          final number = vm.currentNumber!;
                                          final keep =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) {
                                              return AlertDialog(
                                                title: Row(
                                                  children: [
                                                    const Text("Kết quả: "),
                                                    Text(
                                                      "$number",
                                                      style: const TextStyle(
                                                        color:
                                                            TetTheme.redPrimary,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "Giữ số này trong danh sách hay xóa khỏi vòng quay?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx)
                                                            .pop(true),
                                                    child: const Text("Giữ"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx)
                                                            .pop(false),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          TetTheme.redPrimary,
                                                    ),
                                                    child: const Text("Xóa"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (keep == false) {
                                            vm.removeCustomValue(number);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Đã xóa $number khỏi danh sách.",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                icon: vm.isSpinning
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.casino_rounded,
                                        size: 24,
                                      ),
                                label: Text(
                                  vm.isSpinning ? "Đang quay..." : "Quay ngay",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: TetTheme.goldLight,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Lịch sử quay",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => HistoryList.buildTile(
                            item: vm.history[index],
                          ),
                          childCount: vm.history.length,
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
                ),
              ),
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    emissionFrequency: 0.02,
                    numberOfParticles: 26,
                    maxBlastForce: 24,
                    minBlastForce: 12,
                    gravity: 0.25,
                    colors: const [
                      TetTheme.redPrimary,
                      TetTheme.gold,
                      TetTheme.goldLight,
                      Colors.yellow,
                      Colors.white,
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
}