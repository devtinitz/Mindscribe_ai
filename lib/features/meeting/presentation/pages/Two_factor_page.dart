import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class TwoFactorPage extends GetView<AuthController> {
  const TwoFactorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HoverButton(
                onTap: () => Get.offAllNamed(AppRoutes.login),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded,
                      size: 40, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Vérification en 2 étapes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Un code à 6 chiffres a été envoyé à votre adresse email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              _OtpInput(mainController: controller.twoFactorController),

              const SizedBox(height: 24),

              Obx(() {
                final err = controller.twoFactorError.value;
                if (err == null) return const SizedBox();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(err,
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              }),

              Obx(() => _HoverButton(
                    onTap: controller.isVerifying.value
                        ? null
                        : controller.verifyTwoFactor,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: controller.isVerifying.value
                            ? AppColors.primary.withOpacity(0.6)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: controller.isVerifying.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Vérifier le code',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                      ),
                    ),
                  )),

              const SizedBox(height: 24),

              Center(
                child: _HoverButton(
                  onTap: controller.resendTwoFactorCode,
                  child: RichText(
                    text: TextSpan(
                      text: 'Vous n\'avez pas reçu le code ? ',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Renvoyer',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

// ─── 6 cases OTP ─────────────────────────────────────────────────────────────

class _OtpInput extends StatefulWidget {
  final TextEditingController mainController;
  const _OtpInput({required this.mainController});

  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput> {
  final List<TextEditingController> _boxes =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Sync depuis mainController si déjà rempli
    _syncFromMain();
    widget.mainController.addListener(_syncFromMain);
  }

  void _syncFromMain() {
    final code = widget.mainController.text;
    for (int i = 0; i < 6; i++) {
      final char = i < code.length ? code[i] : '';
      if (_boxes[i].text != char) _boxes[i].text = char;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.mainController.removeListener(_syncFromMain);
    for (final c in _boxes) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _onChanged(int i, String val) {
    final digit = val.replaceAll(RegExp(r'\D'), '');

    // Collage de 6 chiffres
    if (digit.length == 6) {
      _fillAll(digit);
      return;
    }

    if (digit.isNotEmpty) {
      _boxes[i].text = digit[digit.length - 1];
      if (i < 5) _nodes[i + 1].requestFocus();
    } else {
      _boxes[i].text = '';
      if (i > 0) _nodes[i - 1].requestFocus();
    }
    _syncToMain();
  }

  void _fillAll(String code) {
    for (int i = 0; i < 6; i++) {
      _boxes[i].text = i < code.length ? code[i] : '';
    }
    if (_nodes[5].canRequestFocus) _nodes[5].requestFocus();
    _syncToMain();
  }

  void _syncToMain() {
    final code = _boxes.map((c) => c.text).join();
    if (widget.mainController.text != code) {
      widget.mainController.text = code;
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      final digits = data!.text!.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        _fillAll(digits.substring(0, digits.length.clamp(0, 6)));
      }
    }
  }

  void _onKeyEvent(int i, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _boxes[i].text.isEmpty &&
        i > 0) {
      _nodes[i - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 48,
              height: 56,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (e) => _onKeyEvent(i, e),
                child: TextField(
                  controller: _boxes[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  showCursor: true,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (v) => _onChanged(i, v),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        _HoverButton(
          onTap: _paste,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.content_paste_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Coller le code',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hover button ─────────────────────────────────────────────────────────────

class _HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _HoverButton({required this.child, this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : (_hovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: AnimatedOpacity(
            opacity: _hovered && widget.onTap != null ? 0.85 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}