import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final String folderPath;
  final int frameCount;
  final Duration frameDuration;

  const AnimatedBackground({
    super.key,
    required this.folderPath,
    required this.frameCount,
    this.frameDuration = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  int _currentFrame = 1;
  Timer? _timer;
  bool _imagesPrecached = false;

  void _preloadImages() async {
    final folders = {
      "assets/images/start": 1,
      "assets/images/calculated": 4,
      "assets/images/error": 4,
      "assets/images/value": 1,
    };

    for (final entry in folders.entries) {
      for (int i = 1; i <= entry.value; i++) {
        final fileName = i.toString().padLeft(3, '0');
        final path = '${entry.key}/mono_$fileName.png';
        await precacheImage(AssetImage(path), context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_imagesPrecached) {
      _preloadImages();
      _imagesPrecached = true;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground old) {
    // COMO FUNCIONA ESTE CODIGO?
    super.didUpdateWidget(old);
    // Si cambian carpeta o cantidad de frames, reinicia la animación
    if (old.folderPath != widget.folderPath ||
        old.frameCount != widget.frameCount) {
      _startAnimation();
    }
  }
  
  void _startAnimation() {
    _timer?.cancel();
    _currentFrame = 1; // Empieza en el primer frame siempre
    _timer = Timer.periodic(widget.frameDuration, (_) {
      setState(() {
        if (_currentFrame < widget.frameCount) {
          _currentFrame++;
        } /* else {
          _currentFrame = 1; // Al llegar al tope, vuelve a 1
        } 
        */
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _currentFrame.toString().padLeft(3, '0');
    final path = '${widget.folderPath}/mono_$fileName.png';

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (ctx, error, stack) {
        debugPrint('ERROR: no existe asset ▶ $path');
        return const SizedBox(); // o un placeholder
      },
    );
  }
}
