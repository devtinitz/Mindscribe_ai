import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/recorder_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';

class RecordingPage extends GetView<RecorderController> {
  const RecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: Obx(() => _buildBody(size))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_rounded,
                    size: 20, color: AppColors.primary),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "Nouvelle Réunion",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── Corps principal ───────────────────────────────────────────────
  Widget _buildBody(Size size) {
    final isRecording = controller.isRecording.value;
    final isUploading = controller.isUploading.value;
    final hasRecorded = controller.hasRecorded.value;

    // ── Phase 2 : lecteur + boutons valider/réenregistrer ──────────
    if (hasRecorded && !isUploading) {
      return _buildPlayerView(size);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 10),

        _buildStatusBar(isRecording, isUploading),

        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: size.width,
                  height: 180,
                  child: isUploading
                      ? const _UploadingWave()
                      : isRecording
                          ? const _WaveformAnimated()
                          : const _WaveformIdle(),
                ),

                const SizedBox(height: 36),

                isUploading
                    ? _buildUploadingButton()
                    : _buildRecordButton(isRecording),

                const SizedBox(height: 20),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isUploading
                        ? 'Envoi en cours, veuillez patienter...'
                        : isRecording
                            ? 'Appuyez pour arrêter'
                            : 'Appuyez pour enregistrer',
                    key: ValueKey('$isRecording-$isUploading'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.hint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        _buildBottomSection(),
      ],
    );
  }

  // ── Phase 2 : lecteur audio + valider ────────────────────────────
  Widget _buildPlayerView(Size size) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Titre
          const Text(
            'Enregistrement terminé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Donnez un titre à votre réunion',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // ── Champ titre ───────────────────────────────────────────
          TextField(
            controller: controller.titleController,
            decoration: InputDecoration(
              hintText: 'Ex: Réunion de suivi projet...',
              prefixIcon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.hint),
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
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Icône micro
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 40),
          ),

          const SizedBox(height: 32),

          // Barre de progression
          Obx(() {
            final pos = controller.playbackPosition.value;
            final dur = controller.playbackDuration.value;
            final progress = dur.inMilliseconds > 0
                ? pos.inMilliseconds / dur.inMilliseconds
                : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(Get.context!).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.primary,
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (v) {
                      final ms = (v * dur.inMilliseconds).toInt();
                      controller.seekTo(Duration(milliseconds: ms));
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(pos),
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    Text(_formatDuration(dur),
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            );
          }),

          const SizedBox(height: 16),

          // Bouton play/pause
          Obx(() => GestureDetector(
                onTap: controller.togglePlayback,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    controller.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              )),

          const SizedBox(height: 40),

          // Boutons Réenregistrer / Valider
          Row(
            children: [
              // Réenregistrer
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.retake,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Réenregistrer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Valider → upload
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.validateAndUpload,
                  icon: const Icon(Icons.send_rounded,
                      size: 18, color: Colors.white),
                  label: const Text(
                    'Valider',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Barre de statut ───────────────────────────────────────────────
  Widget _buildStatusBar(bool isRecording, bool isUploading) {
    final Color color = isUploading
        ? AppColors.primary
        : isRecording
            ? AppColors.danger
            : AppColors.hint;

    final String label = isUploading
        ? 'Envoi en cours...'
        : isRecording
            ? 'Enregistrement en cours'
            : 'En attente';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isUploading) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
          ] else if (isRecording) ...[
            _PulsingDot(),
            const SizedBox(width: 10),
          ] else ...[
            Icon(Icons.mic_none_rounded, size: 16, color: color),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (isRecording && !isUploading) ...[
            const SizedBox(width: 16),
            const _RecordingTimer(),
          ],
        ],
      ),
    );
  }

  // ── Bouton enregistrement ─────────────────────────────────────────
  Widget _buildRecordButton(bool isRecording) {
    return GestureDetector(
      onTap: () {
        if (isRecording) {
          controller.stopRecording();
        } else {
          controller.startRecording();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: isRecording ? 80 : 88,
        height: isRecording ? 80 : 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isRecording
              ? const LinearGradient(
                  colors: [Color(0xFFFF4D6D), Color(0xFFCC1A3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryGlow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: isRecording
                  ? AppColors.danger.withOpacity(0.45)
                  : AppColors.primary.withOpacity(0.38),
              blurRadius: isRecording ? 30 : 24,
              spreadRadius: isRecording ? 4 : 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isRecording
                ? Container(
                    key: const ValueKey('stop'),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                : const Icon(
                    key: ValueKey('mic'),
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
          ),
        ),
      ),
    )
        .animate(target: isRecording ? 1 : 0)
        .custom(
          duration: 1200.ms,
          builder: (context, value, child) => child,
        );
  }

  // ── Bouton pendant upload ─────────────────────────────────────────
  Widget _buildUploadingButton() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.15),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
      ),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ── Bas de page ───────────────────────────────────────────────────
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  controller.status.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: controller.isRecording.value
                        ? AppColors.danger
                        : AppColors.textSecondary,
                  ),
                ),
              )),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    size: 16, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Parlez clairement. Dès que vous arrêtez, l'IA transcrit et génère le compte-rendu automatiquement.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Onde pendant upload ──────────────────────────────────────────────────────

class _UploadingWave extends StatefulWidget {
  const _UploadingWave();

  @override
  State<_UploadingWave> createState() => _UploadingWaveState();
}

class _UploadingWaveState extends State<_UploadingWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _UploadWavePainter(t: _ctrl.value),
      ),
    );
  }
}

class _UploadWavePainter extends CustomPainter {
  final double t;
  _UploadWavePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = h / 2;
    const barCount = 42;
    const barW = 3.5;
    final gap = (w - barCount * barW) / (barCount + 1);

    for (int i = 0; i < barCount; i++) {
      final x = gap + i * (barW + gap);
      final wave = math.sin((t * math.pi * 2) + i * 0.3) * 0.4 + 0.5;
      final barH = wave * cx * 1.2;

      final paint = Paint()
        ..color = AppColors.primary.withOpacity(0.5 + wave * 0.4)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barW;

      canvas.drawLine(
        Offset(x + barW / 2, cx - barH / 2),
        Offset(x + barW / 2, cx + barH / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_UploadWavePainter old) => old.t != t;
}

// ─── Onde animée (enregistrement) ────────────────────────────────────────────

class _WaveformAnimated extends StatefulWidget {
  const _WaveformAnimated();

  @override
  State<_WaveformAnimated> createState() => _WaveformAnimatedState();
}

class _WaveformAnimatedState extends State<_WaveformAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _WavePainter(t: _ctrl.value),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  _WavePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = h / 2;
    const barCount = 42;
    const barW = 3.5;
    final gap = (w - barCount * barW) / (barCount + 1);
    final rng = math.Random(42);

    for (int i = 0; i < barCount; i++) {
      final x = gap + i * (barW + gap);
      final base = 0.15 + rng.nextDouble() * 0.25;
      final wave1 = math.sin((t * math.pi * 2) + i * 0.45) * 0.35;
      final wave2 = math.sin((t * math.pi * 4) + i * 0.3) * 0.15;
      final amplitude = (base + wave1 + wave2).clamp(0.06, 0.92);
      final barH = amplitude * (cx * 1.8);

      final color = Color.lerp(
        AppColors.accentMint.withOpacity(0.7),
        AppColors.danger,
        amplitude * 0.8,
      )!;

      final paint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barW;

      canvas.drawLine(
        Offset(x + barW / 2, cx - barH / 2),
        Offset(x + barW / 2, cx + barH / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.t != t;
}

// ─── Onde au repos ────────────────────────────────────────────────────────────

class _WaveformIdle extends StatelessWidget {
  const _WaveformIdle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _IdleWavePainter());
  }
}

class _IdleWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = h / 2;
    const barCount = 42;
    const barW = 3.5;
    final gap = (w - barCount * barW) / (barCount + 1);
    final rng = math.Random(42);

    for (int i = 0; i < barCount; i++) {
      final x = gap + i * (barW + gap);
      final barH = (0.08 + rng.nextDouble() * 0.12) * cx;

      final paint = Paint()
        ..color = AppColors.border
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barW;

      canvas.drawLine(
        Offset(x + barW / 2, cx - barH),
        Offset(x + barW / 2, cx + barH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Timer ────────────────────────────────────────────────────────────────────

class _RecordingTimer extends StatefulWidget {
  const _RecordingTimer();

  @override
  State<_RecordingTimer> createState() => _RecordingTimerState();
}

class _RecordingTimerState extends State<_RecordingTimer> {
  late final Stopwatch _sw;
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _sw = Stopwatch()..start();
    _ticker = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  @override
  void dispose() {
    _sw.stop();
    super.dispose();
  }

  String get _formatted {
    final s = _sw.elapsed.inSeconds;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _ticker,
      builder: (_, __) => Text(
        _formatted,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.danger,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─── Point pulsant ────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.danger,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─── Fond animé ───────────────────────────────────────────────────────────────

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _c1;
  late final AnimationController _c2;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 9))
      ..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 13))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2]),
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _BgPainter(t1: _c1.value, t2: _c2.value),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t1, t2;
  _BgPainter({required this.t1, required this.t2});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;



    void blob(double cx, double cy, double r, Color c) {
      final g = Paint()
        ..shader = RadialGradient(colors: [c, c.withOpacity(0)])
            .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, g);
    }

    blob(
        w * 0.85 + math.sin(t1 * math.pi * 2) * w * 0.05,
        h * 0.1 + math.cos(t1 * math.pi * 2) * h * 0.04,
        w * 0.5,
        const Color(0xFF00004D).withOpacity(0.05));

    blob(
        w * 0.05 + math.sin(t2 * math.pi * 2) * w * 0.05,
        h * 0.55 + math.cos(t2 * math.pi * 2) * h * 0.05,
        w * 0.45,
        const Color(0xFF4F6FFF).withOpacity(0.05));

    final lp = Paint()
      ..color = const Color(0xFF00004D).withOpacity(0.022)
      ..strokeWidth = 1;
    for (int i = 0; i < 7; i++) {
      canvas.drawLine(Offset(w / 6 * i, 0), Offset(w / 6 * i, h), lp);
    }
    for (int i = 0; i < 13; i++) {
      canvas.drawLine(Offset(0, h / 12 * i), Offset(w, h / 12 * i), lp);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t1 != t1 || old.t2 != t2;
}