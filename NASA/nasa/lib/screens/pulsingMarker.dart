 // ignore_for_file: library_private_types_in_public_api

 import 'package:flutter/material.dart';

class  Pulsingmarker extends StatefulWidget {
  final double size;

  const  Pulsingmarker({
    Key? key,
    this.size = 70.0,
  }) : super(key: key);

  @override
  _PulsingmarkerState createState() => _PulsingmarkerState();
}

class _PulsingmarkerState extends State< Pulsingmarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // مدة النبضة (1.2 ثانية لتكون سريعة ومقلقة قليلاً بما يناسب الإنذار)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // 1. أنيميشن لتكبير الدائرة كلما انتشرت النبضة
    _scaleAnimation = Tween<double>(begin: 0.7, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 2. أنيميشن لتقليل الشفافية تدريجياً مع الاتساع
    _opacityAnimation = Tween<double>(begin: 0.85, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 3. تدرج ألوان الحريق: من الأصفر إلى البرتقالي ثم الأحمر
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.amber, end: Colors.orange),
        weight: 50, // النصف الأول من الوقت
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.orange, end: Colors.red),
        weight: 50, // النصف الثاني من الوقت
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الدائرة النابضة المتسعة (ذات الألوان المتدرجة)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorAnimation.value,
                  ),
                ),
              ),
            );
          },
        ),
        
        // النقطة المركزية الثابتة مع توهج ناري
        Container(
          width: widget.size * 0.45,
          height: widget.size * 0.45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.deepOrange.shade700,
            boxShadow: const [
              BoxShadow(
                color: Colors.red,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.local_fire_department, // أيقونة حريق واضحة
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}