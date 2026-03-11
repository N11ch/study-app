import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/buttons/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _pageDirection = 1; // +1 = swiped forward (left→right), -1 = back

  late final AnimationController _pageCtrl;
  // Icon: clean pop/zoom-in scale
  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;
  // Title/Subtitle: horizontal slide progress (0→1), direction applied in build
  late final Animation<double> _titleSlideT;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleSlideT;
  late final Animation<double> _subtitleFade;

  // NO _btnCtrl — button animates only on press via _NintendoPressButton

  late final AnimationController _outroCtrl;
  late final Animation<double> _outroExpand;
  late final Animation<double> _outroLogoOpacity;
  late final Animation<double> _outroLogoScale;
  // Welcome sequence
  late final Animation<double> _outroLine1Opacity;
  late final Animation<Offset> _outroLine1Slide;
  late final Animation<double> _outroLine2Opacity;
  late final Animation<Offset> _outroLine2Slide;
  late final Animation<double> _outroLine3Opacity;
  late final Animation<Offset> _outroLine3Slide;
  late final Animation<double> _outroCheckScale;
  late final Animation<double> _outroCheckOpacity;
  bool _outroStarted = false;

  late final AnimationController _particleCtrl;
  late final List<_Particle> _particles;

  late final AnimationController _rippleCtrl;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
        icon: Icons.school_rounded,
        title: 'Lern',
        subtitle:
            'Find expert tutors, book a session instantly, and pay only when you learn.'),
    OnboardingPage(
      icon: Icons.person_search_rounded,
      title: 'Find a Tutor.',
      subtitle:
          'Search tutor based on specific topics and learn exactly what you need.',
    ),
    OnboardingPage(
      icon: Icons.check_box_rounded,
      title: 'Choose your tutor.',
      subtitle:
          'Browse Tutor profiles, experience, and reviews to find the best match for you',
    ),
    OnboardingPage(
      icon: Icons.book,
      title: 'Learn anything.',
      subtitle: 'Keep learning no matter how hard it is',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupParticles();
    _setupPageAnim();
    _setupOutro();
    _setupRipple();
    // Fire page-1 entrance immediately — no intro, straight into onboarding
    _pageCtrl.forward(from: 0.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageCtrl.dispose();
    _outroCtrl.dispose();
    _particleCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _setupParticles() {
    final rng = Random(7);
    _particles = List.generate(
        10,
        (i) => _Particle(
              x: rng.nextDouble(),
              y: rng.nextDouble(),
              radius: 2.0 + rng.nextDouble() * 4.0,
              speed: 0.025 + rng.nextDouble() * 0.04,
              opacity: 0.06 + rng.nextDouble() * 0.12,
              drift: (rng.nextDouble() - 0.5) * 0.4,
              phase: rng.nextDouble() * 2 * pi,
            ));
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  void _setupPageAnim() {
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    // ── Icon: pop/zoom-in — scales from 0 to 1 with a slight overshoot, then settles ──
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageCtrl,
          curve: const Interval(0.0, 0.55, curve: _NintendoBounce())),
    );
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageCtrl,
          curve: const Interval(0.0, 0.25, curve: Curves.easeOut)),
    );

    // ── Title: horizontal slide progress 0→1, direction applied in build ──
    _titleSlideT = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageCtrl,
          curve: const Interval(0.10, 0.60, curve: Curves.easeOutCubic)),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageCtrl,
          curve: const Interval(0.10, 0.38, curve: Curves.easeOut)),
    );

    // ── Subtitle: slightly delayed slide in same direction ──
    _subtitleSlideT = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageCtrl,
          curve: const Interval(0.22, 0.72, curve: Curves.easeOutCubic)),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageCtrl,
          curve: const Interval(0.22, 0.52, curve: Curves.easeOut)),
    );
  }

  void _setupOutro() {
    _outroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    // Phase 1 (0–40%): white circle sweeps across screen
    _outroExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.0, 0.40, curve: Curves.easeInOut)),
    );
    // Phase 2 (38–70%): logo pops in
    _outroLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.38, 0.58, curve: Curves.easeOut)),
    );
    _outroLogoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.36, 0.60, curve: _NintendoBounce())),
    );
    // Phase 3 (54–100%): welcome lines stagger in
    _outroLine1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.54, 0.70, curve: Curves.easeOut)),
    );
    _outroLine1Slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _outroCtrl,
        curve: const Interval(0.54, 0.72, curve: Curves.easeOutBack)));
    _outroLine2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.64, 0.78, curve: Curves.easeOut)),
    );
    _outroLine2Slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _outroCtrl,
        curve: const Interval(0.64, 0.80, curve: Curves.easeOutBack)));
    _outroLine3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.74, 0.88, curve: Curves.easeOut)),
    );
    _outroLine3Slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _outroCtrl,
        curve: const Interval(0.74, 0.90, curve: Curves.easeOutBack)));
    // Check burst (72–92%)
    _outroCheckScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.72, 0.92, curve: _NintendoBounce())),
    );
    _outroCheckOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _outroCtrl,
          curve: const Interval(0.72, 0.82, curve: Curves.easeOut)),
    );
  }

  void _setupRipple() {
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _runPageEntrance() {
    if (!mounted) return;
    _pageCtrl.forward(from: 0.0);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _rippleCtrl.forward(from: 0.0);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _runOutro();
    }
  }

  void _skip() => _runOutro();

  Future<void> _runOutro() async {
    if (_outroStarted || !mounted) return;
    setState(() => _outroStarted = true);
    HapticFeedback.mediumImpact();
    await _outroCtrl.forward();
    if (!mounted) return;
    // Let the welcome screen sit for a beat before navigating
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushReplacementNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildParticles(),
            _buildRipple(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopNav(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        if (!mounted) return;
                        final dir = index > _currentPage ? 1 : -1;
                        setState(() {
                          _pageDirection = dir;
                          _currentPage = index;
                        });
                        HapticFeedback.selectionClick();
                        _runPageEntrance();
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        if (index == _currentPage) {
                          return RepaintBoundary(
                            child: _buildAnimatedPage(
                                _pages[index], theme, colorScheme),
                          );
                        }
                        return RepaintBoundary(
                          child: _buildStaticPage(
                              _pages[index], theme, colorScheme),
                        );
                      },
                    ),
                  ),
                  _buildIndicators(colorScheme),
                  // Button: no scale animation — press-only via _NintendoPressButton
                  _buildButton(),
                ],
              ),
            ),
            RepaintBoundary(child: _buildOutroOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedOpacity(
          opacity: _currentPage > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: TextButton(
            onPressed: _currentPage > 0
                ? () {
                    HapticFeedback.lightImpact();
                    _rippleCtrl.forward(from: 0.0);
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('< Back',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ),
        AnimatedOpacity(
          opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: TextButton(
            onPressed: _currentPage < _pages.length - 1 ? _skip : null,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Skip',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          final isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButton() {
    String label;
    if (_currentPage == 0) {
      label = 'Continue →';
    } else if (_currentPage == _pages.length - 1) {
      label = 'Get Started';
    } else {
      label = 'Next  →';
    }
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: _NintendoPressButton(
        text: label,
        onPressed: _nextPage,
      ),
    );
  }

  Widget _buildAnimatedPage(
      OnboardingPage page, ThemeData theme, ColorScheme colorScheme) {
    final index = _pages.indexOf(page);
    final isHero = index == 0;

    if (isHero) {
      return AnimatedBuilder(
        animation: _pageCtrl,
        builder: (_, __) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo icon: pop/zoom-in ──
              Opacity(
                opacity: _iconFade.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _iconScale.value.clamp(0.0, 1.3),
                  child: const _LogoIconBox(),
                ),
              ),

              const SizedBox(height: 40),

              // ── "Hi, Welcome to" label ──
              Opacity(
                opacity: _titleFade.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(
                    (1.0 - _titleSlideT.value) * 80 * _pageDirection,
                    0,
                  ),
                  child: Text(
                    'Hi, Welcome to',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ── "Lern" big bold title — gradient blue ──
              Opacity(
                opacity: _titleFade.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(
                    (1.0 - _titleSlideT.value) * 80 * _pageDirection,
                    0,
                  ),
                  child: GradientText(
                    'Lern',
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1479FF),
                        Color(0xFF147EFF),
                        Color(0xFF149AFF)
                      ],
                      stops: [0.0, 0.28, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 80,
                      letterSpacing: -3,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Subtitle — blue gradient tint ──
              Opacity(
                opacity: _subtitleFade.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(
                    (1.0 - _subtitleSlideT.value) * 60 * _pageDirection,
                    0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      page.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF1479FF),
                        height: 1.6,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // ── Regular pages (1–3) ──
    return AnimatedBuilder(
      animation: _pageCtrl,
      builder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: _iconFade.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _iconScale.value.clamp(0.0, 1.3),
                  child: _buildIconContainer(page, index),
                ),
              ),
              const SizedBox(height: AppSizes.xxl),
              Opacity(
                opacity: _titleFade.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(
                    (1.0 - _titleSlideT.value) * 80 * _pageDirection,
                    0,
                  ),
                  child: _buildTitleText(page, theme),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Opacity(
                opacity: _subtitleFade.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(
                    (1.0 - _subtitleSlideT.value) * 60 * _pageDirection,
                    0,
                  ),
                  child: Text(
                    page.subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.6,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticPage(
      OnboardingPage page, ThemeData theme, ColorScheme colorScheme) {
    final index = _pages.indexOf(page);
    final isHero = index == 0;

    if (isHero) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _LogoIconBox(),
          const SizedBox(height: 40),
          Text(
            'Hi, Welcome to',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          GradientText(
            'Lern',
            gradient: const LinearGradient(
              colors: [Color(0xFF1479FF), Color(0xFF147EFF), Color(0xFF149AFF)],
              stops: [0.0, 0.28, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 80,
              letterSpacing: -3,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              page.subtitle,
              style: const TextStyle(
                color: Color(0xFF1479FF),
                height: 1.6,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconContainer(page, index),
          const SizedBox(height: AppSizes.xxl),
          _buildTitleText(page, theme),
          const SizedBox(height: AppSizes.md),
          Text(
            page.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Title: page 0 gets huge extrabold, rest get standard 40sp w800
  Widget _buildTitleText(OnboardingPage page, ThemeData theme) {
    final isHero = _pages.indexOf(page) == 0;
    if (isHero) {
      return GradientText(
        page.title,
        gradient: const LinearGradient(
          colors: [Color(0xFF1479FF), Color(0xFF147EFF), Color(0xFF149AFF)],
          stops: [0.0, 0.28, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 72,
          letterSpacing: -3,
          height: 1.0,
        ),
        textAlign: TextAlign.center,
      );
    }
    return GradientText(
      page.title,
      gradient: const LinearGradient(
        colors: [Color(0xFF1479FF), Color(0xFF147EFF), Color(0xFF149AFF)],
        stops: [0.0, 0.28, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      style: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 40,
        letterSpacing: -1,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildIconContainer(OnboardingPage page, int index) {
    // Each page gets a unique icon arrangement with layered circles
    final configs = [
      _IconConfig(
          Icons.school_rounded, const [Color(0xFF1479FF), Color(0xFF14A5FF)]),
      _IconConfig(Icons.person_search_rounded,
          const [Color(0xFF1479FF), Color(0xFF14A5FF)]),
      _IconConfig(
          Icons.verified_rounded, const [Color(0xFF1479FF), Color(0xFF14A5FF)]),
      _IconConfig(Icons.auto_stories_rounded,
          const [Color(0xFF1479FF), Color(0xFF14A5FF)]),
    ];
    final cfg = configs[index.clamp(0, configs.length - 1)];

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: cfg.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cfg.colors.first.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle inner ring
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          // White circle bg
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Icon(cfg.icon, size: 58, color: cfg.colors.first),
        ],
      ),
    );
  }

  Widget _buildOutroOverlay() {
    return AnimatedBuilder(
      animation: _outroCtrl,
      builder: (_, __) {
        if (_outroCtrl.value == 0.0) return const SizedBox.shrink();
        final size = MediaQuery.of(context).size;
        final maxR = sqrt(size.width * size.width + size.height * size.height);
        final radius = _outroExpand.value.clamp(0.0, 1.0) * maxR;
        final logoOp = _outroLogoOpacity.value.clamp(0.0, 1.0);
        final logoSc = _outroLogoScale.value.clamp(0.0, 1.5);
        final line1Op = _outroLine1Opacity.value.clamp(0.0, 1.0);
        final line2Op = _outroLine2Opacity.value.clamp(0.0, 1.0);
        final line3Op = _outroLine3Opacity.value.clamp(0.0, 1.0);
        final checkSc = _outroCheckScale.value.clamp(0.0, 1.5);
        final checkOp = _outroCheckOpacity.value.clamp(0.0, 1.0);

        return Stack(
          children: [
            // White sweep
            CustomPaint(
              painter: _CircleExpandPainter(radius: radius),
              size: Size.infinite,
            ),

            // All content centered
            if (logoOp > 0)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo pop
                    Opacity(
                      opacity: logoOp,
                      child: Transform.scale(
                        scale: logoSc,
                        child: const _LogoIconBox(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App name
                    Opacity(
                      opacity: logoOp,
                      child: const Text(
                        'Lern',
                        style: TextStyle(
                          color: Color(0xFF1479FF),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Welcome lines stagger in ──

                    // Line 1: "Welcome aboard 🎉"
                    Opacity(
                      opacity: line1Op,
                      child: SlideTransition(
                        position: _outroLine1Slide,
                        child: const Text(
                          'Welcome aboard! 🎉',
                          style: TextStyle(
                            color: Color(0xFF1479FF),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Line 2: "You're all set"
                    Opacity(
                      opacity: line2Op,
                      child: SlideTransition(
                        position: _outroLine2Slide,
                        child: Text(
                          'Your learning journey starts now.',
                          style: TextStyle(
                            color: const Color(0xFF1479FF).withOpacity(0.65),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Line 3: "Good luck"
                    Opacity(
                      opacity: line3Op,
                      child: SlideTransition(
                        position: _outroLine3Slide,
                        child: Text(
                          'Good luck — you\'ve got this. 💪',
                          style: TextStyle(
                            color: const Color(0xFF1479FF).withOpacity(0.45),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Check burst ──
                    Opacity(
                      opacity: checkOp,
                      child: Transform.scale(
                        scale: checkSc,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1479FF).withOpacity(0.10),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF1479FF),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildParticles() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _particleCtrl,
        builder: (_, __) => CustomPaint(
          painter:
              _ParticlePainter(particles: _particles, t: _particleCtrl.value),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildRipple() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _rippleCtrl,
        builder: (_, __) {
          if (_rippleCtrl.value == 0.0) return const SizedBox.shrink();
          final size = MediaQuery.of(context).size;
          final op = ((1.0 - _rippleCtrl.value) * 0.03).clamp(0.0, 1.0);
          return Center(
            child: Transform.scale(
              scale: _rippleCtrl.value.clamp(0.0, 1.0),
              child: Container(
                width: size.width * 2.2,
                height: size.width * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(op),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Nintendo Press Button
// Squashes on finger-down, springs back with overshoot on release.
// Zero animation unless the user physically taps.
// ─────────────────────────────────────────────────────────────

class _NintendoPressButton extends StatefulWidget {
  const _NintendoPressButton({
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback onPressed;

  @override
  State<_NintendoPressButton> createState() => _NintendoPressButtonState();
}

class _NintendoPressButtonState extends State<_NintendoPressButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Press down: squash (scaleX wide, scaleY short)
  late final Animation<double> _scaleX;
  late final Animation<double> _scaleY;

  @override
  void initState() {
    super.initState();
    // Forward = press, reverse = spring back
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 420),
    );

    _scaleX = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _scaleY = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    // Spring back with overshoot via _NintendoSpringBack curve
    _ctrl.reverse();
    widget.onPressed();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(_scaleX.value, _scaleY.value, 1.0),
          child: child,
        ),
        child: AbsorbPointer(
          child: PrimaryButton(
            text: widget.text,
            onPressed: widget.onPressed, // enabled so it renders active
            width: 340,
            height: 70,
            radius: 90,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Curves
// ─────────────────────────────────────────────────────────────

/// Classic Nintendo pop: fast rise → overshoot → settle
class _NintendoBounce extends Curve {
  const _NintendoBounce();
  @override
  double transformInternal(double t) {
    if (t < 0.55) return (t / 0.55) * 1.20; // shoot to 1.20
    if (t < 0.75) return 1.20 - ((t - 0.55) / 0.20) * 0.28; // → 0.92
    return 0.92 + ((t - 0.75) / 0.25) * 0.08; // settle → 1.0
  }
}

// ─────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────

class _CircleExpandPainter extends CustomPainter {
  const _CircleExpandPainter({required this.radius});
  final double radius;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_CircleExpandPainter old) => old.radius != radius;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.t});
  final List<_Particle> particles;
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final progress = (t * p.speed * 10) % 1.0;
      final x = (p.x * size.width + sin(p.phase + t * 2 * pi) * 20 * p.drift)
          .clamp(0.0, size.width);
      final y = ((p.y - progress * 0.1) % 1.0) * size.height;
      final opacity =
          (p.opacity * (0.5 + 0.5 * sin(p.phase + progress * 2 * pi)))
              .clamp(0.0, 1.0);
      paint.color = Color.fromRGBO(255, 255, 255, opacity);
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────
// Lern Logo — page 0 hero, pixel-traced from logo PNG
// White cursive "L" with cyan 3D offset shadow
// ─────────────────────────────────────────────────────────────

/// 90×90 blue rounded-rectangle logo box — matches the design screenshot exactly.
/// The Lern "L" logo painter sits inside a blue rounded square (radius 16).
class _LogoIconBox extends StatelessWidget {
  const _LogoIconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF1479FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1479FF).withOpacity(0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(painter: _LernLogoPainter()),
      ),
    );
  }
}

/// Draws the Lern "L" lettermark exactly as in lern-logo.png:
/// - Chunky cursive "L" with rounded cap at top
/// - Vertical stem + horizontal bar at bottom
/// - Open "U" tail at base (two legs curving down)
/// - Cyan (#1AE8FF) offset shadow ~16px left, 14px down
/// - White letterform on top
class _LernLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Original artboard: 480×480
    final double sx = size.width / 480;
    final double sy = size.height / 480;

    // Scale helper
    Path buildL(double offX, double offY) {
      // All coords in original 480px space
      double x(double v) => (v + offX) * sx;
      double y(double v) => (v + offY) * sy;

      final path = Path();

      // ── Top of cap — crown curves left then right ──
      path.moveTo(x(190), y(80));
      path.cubicTo(x(218), y(76), x(252), y(86), x(252), y(115));

      // ── Right side of cap into stem (right edge) ──
      path.cubicTo(x(252), y(138), x(252), y(150), x(252), y(158));

      // ── Right edge of stem, very slight taper going down ──
      path.lineTo(x(241), y(240));
      path.lineTo(x(236), y(282));

      // ── Stem right side continues, right arm starts to emerge ──
      path.cubicTo(x(234), y(300), x(232), y(312), x(230), y(318));

      // ── Merge point — full horizontal bar begins ──
      // Transition: stem joins bar, bar extends right to ~357
      path.cubicTo(x(235), y(322), x(280), y(322), x(357), y(322));

      // ── Bottom-right corner of horizontal bar ──
      path.cubicTo(x(360), y(322), x(360), y(326), x(357), y(358));

      // ── Right leg of U tail — curves outward and down ──
      path.cubicTo(x(356), y(363), x(348), y(368), x(308), y(395));
      path.cubicTo(x(298), y(401), x(285), y(401), x(268), y(395));

      // ── U notch — inward curve between the two legs ──
      path.cubicTo(x(248), y(387), x(237), y(374), x(226), y(364));

      // ── Left leg inner edge — comes up slightly then turns ──
      path.cubicTo(x(216), y(354), x(208), y(352), x(207), y(369));

      // ── Left leg curves down and outward ──
      path.cubicTo(x(203), y(381), x(188), y(392), x(162), y(395));
      path.cubicTo(x(146), y(396), x(130), y(387), x(131), y(358));

      // ── Bottom of bar, left side going back left ──
      path.lineTo(x(131), y(322));

      // ── Left side of stem going back up ──
      path.lineTo(x(165), y(312));
      path.lineTo(x(165), y(158));

      // ── Top-left of cap: curves back up to start ──
      path.cubicTo(x(165), y(140), x(152), y(122), x(128), y(112));
      path.cubicTo(x(118), y(100), x(130), y(78), x(165), y(78));
      path.cubicTo(x(178), y(77), x(186), y(78), x(190), y(80));

      path.close();
      return path;
    }

    // Pass 1: cyan shadow (offset left/up as 3D depth effect)
    canvas.drawPath(
      buildL(-16, 14),
      Paint()
        ..color = const Color(0xFF1AE8FF)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    // Pass 2: white letter on top
    canvas.drawPath(
      buildL(0, 0),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_LernLogoPainter _) => false;
}

// ─────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────

class _IconConfig {
  final IconData icon;
  final List<Color> colors;
  const _IconConfig(this.icon, this.colors);
}

class _Particle {
  final double x, y, radius, speed, opacity, drift, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.drift,
    required this.phase,
  });
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class GradientText extends StatelessWidget {
  const GradientText(this.text,
      {super.key, required this.gradient, this.style, this.textAlign});
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (b) =>
          gradient.createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
