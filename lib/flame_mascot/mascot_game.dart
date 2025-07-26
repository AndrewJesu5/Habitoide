// lib/flame_mascot/mascot_game.dart

import 'dart:ui' as ui show Color;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors, Paint, FilterQuality;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kDebugMode;

import '../habit_provider.dart';

enum SimpleAnimationStateKey { normal, active }
enum MascotExpression { neutral, happy, sad }

class MascotCharacter extends PositionComponent with HasGameReference<MascotGame> {
  static const double originalFrameSize = 40.0;
  static const double scaleFactor = 9.0;
  static final Vector2 characterDisplaySize = Vector2.all(originalFrameSize * scaleFactor);

  SpriteComponent? body;
  SpriteComponent? currentOpenEyes;
  SpriteComponent? eyesClosed;
  SpriteComponent? mouth;
  SpriteAnimationGroupComponent<SimpleAnimationStateKey>? earsAnimationGroup;
  SpriteComponent? earsSadStatic;
  SpriteComponent? staticTail;
  SpriteAnimationComponent? animatedTailComponent;
  SpriteComponent? outfit;
  SpriteComponent? staticTear;
  SpriteAnimationComponent? animatedTearComponent;

  Sprite? _spriteEyeOpenNormal;
  Sprite? _spriteEyeOpenHappy;
  Sprite? _spriteEyeClosed;
  Sprite? _spriteEarsSad;

  Timer? blinkTimer;
  Timer? earWiggleTimer;
  Timer? tailAnimationActivationTimer;
  Timer? tearAnimationActivationTimer;

  bool _assetsLoadedSuccessfully = true;
  bool _isTailAnimatingCurrently = false;
  bool _isTearAnimatingCurrently = false;
  MascotExpression _currentExpression = MascotExpression.neutral;
  bool _isCurrentlyBlinking = false;

  final String _eyesOpenAsset = 'olhos_abertos.png';
  final String _eyesClosedAsset = 'olhos_fechados.png';
  final String _eyesHappyAsset = 'olhos_felizes.png';
  final String _earsPosAAsset = 'orelhas_posicao_A.png';
  final String _earsPosBAsset = 'orelhas_posicao_B.png';
  final String _earsSadAsset = 'orelhas_tristes.png';
  final String _staticTailAsset = 'rabo_estatico.png';
  final List<String> _tailAnimationFramesAssets = [
    'rabo_frame1.png', 'rabo_frame2.png', 'rabo_frame3.png', 'rabo_frame4.png',
  ];
  final double _tailAnimationStepTime = 0.15;
  final String _staticTearAsset = 'lagrima_frame1.png';
  final List<String> _tearAnimationFramesAssets = ['lagrima_frame2.png', 'lagrima_frame3.png'];
  final double _tearAnimationStepTime = 0.25;

  MascotCharacter() : super(size: characterDisplaySize);

  Future<Sprite> _loadSafeSprite(String fileName) async {
    try {
      final sprite = await game.loadSprite(fileName);
      return sprite;
    } catch (e) {
      if (kDebugMode) { print("[MascotCharacter] !!! ERRO ao carregar asset: $fileName - $e"); }
      _assetsLoadedSuccessfully = false;
      rethrow;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;

    try {
      const int tearPriority = 5;
      const int earsPriority = 4;
      const int eyesPriority = 3;
      const int bodyPriority = 0;
      const int tailPriority = -1;
      
      final Paint pixelPaint = Paint()..filterQuality = FilterQuality.none;

      final bodySprite = await _loadSafeSprite('corpo.png');
      body = SpriteComponent(sprite: bodySprite, size: characterDisplaySize, anchor: Anchor.center, position: size / 2, paint: pixelPaint, priority: bodyPriority);
      add(body!);

      
      await _updateMouthSprite("neutra");

      _spriteEyeOpenNormal = await _loadSafeSprite(_eyesOpenAsset);
      _spriteEyeOpenHappy = await _loadSafeSprite(_eyesHappyAsset);
      _spriteEyeClosed = await _loadSafeSprite(_eyesClosedAsset);

      currentOpenEyes = SpriteComponent(
        sprite: _spriteEyeOpenNormal, size: characterDisplaySize, anchor: Anchor.center, position: size / 2,
        paint: pixelPaint, priority: eyesPriority,
      );
      add(currentOpenEyes!);

      eyesClosed = SpriteComponent(
        sprite: _spriteEyeClosed, size: characterDisplaySize, anchor: Anchor.center, position: size / 2,
        paint: pixelPaint, priority: eyesPriority,
      );

      final earsPosASprite = await _loadSafeSprite(_earsPosAAsset);
      final earsPosBSprite = await _loadSafeSprite(_earsPosBAsset);
      _spriteEarsSad = await _loadSafeSprite(_earsSadAsset);

      final earsIdleAnim = SpriteAnimation.spriteList([earsPosASprite], stepTime: 1, loop: true);
      final earsWiggleAnim = SpriteAnimation.spriteList([earsPosBSprite, earsPosASprite], stepTime: 0.25, loop: false);
      
      earsAnimationGroup = SpriteAnimationGroupComponent<SimpleAnimationStateKey>(
        animations: { SimpleAnimationStateKey.normal: earsIdleAnim, SimpleAnimationStateKey.active: earsWiggleAnim },
        current: SimpleAnimationStateKey.normal, size: characterDisplaySize, anchor: Anchor.center, position: size / 2,
        paint: pixelPaint, priority: earsPriority,
      );
      
      earsSadStatic = SpriteComponent(
        sprite: _spriteEarsSad, size: characterDisplaySize, anchor: Anchor.center, position: size / 2,
        paint: pixelPaint, priority: earsPriority,
      );
      
      add(earsAnimationGroup!);


      final staticTailSpriteInstance = await _loadSafeSprite(_staticTailAsset);
      staticTail = SpriteComponent(
        sprite: staticTailSpriteInstance, size: characterDisplaySize, anchor: Anchor.center,
        position: size / 2, paint: pixelPaint, priority: tailPriority,
      );
      add(staticTail!);

      final List<Sprite> tailAnimationSpriteList = [];
      for (String frameAsset in _tailAnimationFramesAssets) {
        tailAnimationSpriteList.add(await _loadSafeSprite(frameAsset));
      }
      final tailAnimationSequence = SpriteAnimation.spriteList(tailAnimationSpriteList, stepTime: _tailAnimationStepTime, loop: false);
      animatedTailComponent = SpriteAnimationComponent(
        animation: tailAnimationSequence, playing: false, removeOnFinish: false, 
        size: characterDisplaySize, anchor: Anchor.center, 
        position: staticTail!.position, paint: pixelPaint, priority: tailPriority,
      );

      final staticTearSpriteInstance = await _loadSafeSprite(_staticTearAsset);
      staticTear = SpriteComponent(
        sprite: staticTearSpriteInstance, size: characterDisplaySize, anchor: Anchor.center,
        position: size / 2, paint: pixelPaint, priority: tearPriority,
      );

      final List<Sprite> tearAnimationSpriteList = [];
      for (String frameAsset in _tearAnimationFramesAssets) {
        tearAnimationSpriteList.add(await _loadSafeSprite(frameAsset));
      }
      final tearAnimationSequence = SpriteAnimation.spriteList(tearAnimationSpriteList, stepTime: _tearAnimationStepTime, loop: false);
      animatedTearComponent = SpriteAnimationComponent(
        animation: tearAnimationSequence, playing: false, removeOnFinish: false,
        size: characterDisplaySize, anchor: Anchor.center,
        position: staticTear!.position, paint: pixelPaint, priority: tearPriority,
      );

      _assetsLoadedSuccessfully = true;

    } catch (e) {
      if (kDebugMode) { print("!!! ERRO FATAL AO CARREGAR ASSETS: $e"); }
      _assetsLoadedSuccessfully = false;
      return;
    }

    if (_assetsLoadedSuccessfully) {
      blinkTimer = Timer(2.0 + math.Random().nextDouble() * 1.0, onTick: _onBlinkTick, repeat: true)..start();
      earWiggleTimer = Timer(13.0 + math.Random().nextDouble() * 4.0, onTick: _onEarWiggleTick, repeat: true)..start();
      tailAnimationActivationTimer = Timer(8.0 + math.Random().nextDouble() * 4.0, onTick: _onTailAnimationTick, repeat: true)..start();
      tearAnimationActivationTimer = Timer(5.0 + math.Random().nextDouble() * 2.0, onTick: _onTearAnimationTick, repeat: true)..start();
    }
  }

  Future<void> updateOutfit(String outfitAsset) async {
    if (outfit != null && outfit!.isMounted) {
      remove(outfit!);
      outfit = null;
    }

    if (outfitAsset != 'default' && outfitAsset.isNotEmpty) {
      try {
        final outfitSprite = await _loadSafeSprite(outfitAsset);
        outfit = SpriteComponent(
          sprite: outfitSprite,
          size: characterDisplaySize,
          anchor: Anchor.center,
          position: size / 2,
          paint: Paint()..filterQuality = FilterQuality.none,
          priority: 1,
        );
        add(outfit!);
      } catch (e) {
        if (kDebugMode) {
          print("Erro ao carregar o traje: $outfitAsset - $e");
        }
      }
    }
  }

  void _onBlinkTick() {
    if (!isMounted || !_assetsLoadedSuccessfully || _isCurrentlyBlinking || currentOpenEyes == null || eyesClosed == null) { return; }
    _isCurrentlyBlinking = true;
    if (currentOpenEyes!.isMounted) { remove(currentOpenEyes!); }
    if (!eyesClosed!.isMounted) { add(eyesClosed!); }

    Future.delayed(const Duration(milliseconds: 150), () {
      if (isMounted) {
        if (eyesClosed!.isMounted) { remove(eyesClosed!); }
        Sprite? targetOpenEyeSprite;
        switch (_currentExpression) {
            case MascotExpression.happy: targetOpenEyeSprite = _spriteEyeOpenHappy; break;
            default: targetOpenEyeSprite = _spriteEyeOpenNormal; break;
        }
        if (targetOpenEyeSprite != null) {
            currentOpenEyes!.sprite = targetOpenEyeSprite;
            if (!currentOpenEyes!.isMounted) { add(currentOpenEyes!); }
        }
        _isCurrentlyBlinking = false;
      }
    });
    blinkTimer?.limit = 2.0 + math.Random().nextDouble() * 1.0;
  }

  void _onEarWiggleTick() {
    if (!isMounted || !_assetsLoadedSuccessfully) { return; }
    if (_currentExpression != MascotExpression.sad && earsAnimationGroup?.current == SimpleAnimationStateKey.normal) {
      earsAnimationGroup?.current = SimpleAnimationStateKey.active;
    }
    earWiggleTimer?.limit = 13.0 + math.Random().nextDouble() * 4.0;
  }

  void _onTailAnimationTick() {
    if (!isMounted || !_assetsLoadedSuccessfully || _isTailAnimatingCurrently) { return; }
    if (staticTail?.isMounted ?? false) { remove(staticTail!); }
    if (animatedTailComponent != null && !(animatedTailComponent!.isMounted)) {
      add(animatedTailComponent!);
    }
    animatedTailComponent?.animationTicker?.reset(); 
    if (animatedTailComponent != null) { animatedTailComponent!.playing = true; }
    _isTailAnimatingCurrently = true;
    tailAnimationActivationTimer?.limit = 8.0 + math.Random().nextDouble() * 4.0;
  }
  
  void _onTearAnimationTick() {
    if (!isMounted || !_assetsLoadedSuccessfully || _isTearAnimatingCurrently || _currentExpression != MascotExpression.sad) {
      tearAnimationActivationTimer?.limit = 5.0 + math.Random().nextDouble() * 2.0;
      return;
    }
    if (staticTear?.isMounted ?? false) { remove(staticTear!); }
    if (animatedTearComponent != null && !(animatedTearComponent!.isMounted)) {
      add(animatedTearComponent!);
    }
    animatedTearComponent?.animationTicker?.reset();
    if (animatedTearComponent != null) { animatedTearComponent!.playing = true; }
    _isTearAnimatingCurrently = true;
    tearAnimationActivationTimer?.limit = 5.0 + math.Random().nextDouble() * 2.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_assetsLoadedSuccessfully || !isMounted) { return; }
    
    blinkTimer?.update(dt);
    earWiggleTimer?.update(dt);
    tailAnimationActivationTimer?.update(dt);
    tearAnimationActivationTimer?.update(dt);

    if (earsAnimationGroup?.current == SimpleAnimationStateKey.active && (earsAnimationGroup?.animationTicker?.done() ?? false)) {
      earsAnimationGroup?.current = SimpleAnimationStateKey.normal;
    }
    if (_isTailAnimatingCurrently && (animatedTailComponent?.animationTicker?.done() ?? false)) {
      if (animatedTailComponent?.isMounted ?? false) { remove(animatedTailComponent!); }
      if (staticTail != null && !(staticTail!.isMounted)) { add(staticTail!); }
      _isTailAnimatingCurrently = false;
    }
    if (_isTearAnimatingCurrently && (animatedTearComponent?.animationTicker?.done() ?? false)) {
      if (animatedTearComponent?.isMounted ?? false) { remove(animatedTearComponent!); }
      if (_currentExpression == MascotExpression.sad && staticTear != null && !(staticTear!.isMounted)) {
        add(staticTear!);
      }
      _isTearAnimatingCurrently = false;
    }
  }
  
  Future<void> _updateMouthSprite(String mouthType) async {
    if (mouth?.isMounted ?? false) { remove(mouth!); }
    try {
      final newMouthSprite = await _loadSafeSprite('boca_$mouthType.png');
      mouth = SpriteComponent(
        sprite: newMouthSprite, size: characterDisplaySize, anchor: Anchor.center,
        position: size / 2, paint: Paint()..filterQuality = FilterQuality.none,
        priority: 2,
      );
      add(mouth!);
    } catch (e) { /* Tratar erro */ }
  }

  void setExpression(MascotExpression newExpression) {
    if (!_assetsLoadedSuccessfully || !isMounted) { return; }
    if (_currentExpression == newExpression && !_isCurrentlyBlinking) { return; }
    
    _currentExpression = newExpression;

    String mouthType = "neutra";
    if (newExpression == MascotExpression.happy) { mouthType = "feliz"; }
    else if (newExpression == MascotExpression.sad) { mouthType = "triste"; }
    _updateMouthSprite(mouthType);

    if (!_isCurrentlyBlinking && currentOpenEyes != null) {
        Sprite? targetOpenEyeSprite;
        switch (newExpression) {
            case MascotExpression.happy: targetOpenEyeSprite = _spriteEyeOpenHappy; break;
            default: targetOpenEyeSprite = _spriteEyeOpenNormal; break;
        }
        if (targetOpenEyeSprite != null) {
            currentOpenEyes!.sprite = targetOpenEyeSprite;
            if (!currentOpenEyes!.isMounted) {
                if (eyesClosed?.isMounted ?? false) { remove(eyesClosed!); }
                add(currentOpenEyes!);
            }
        }
    }

    if (newExpression == MascotExpression.sad) {
      if (earsAnimationGroup?.isMounted ?? false) { remove(earsAnimationGroup!); }
      if (earsSadStatic != null && !(earsSadStatic!.isMounted)) { add(earsSadStatic!); }
    } else {
      if (earsSadStatic?.isMounted ?? false) { remove(earsSadStatic!); }
      if (earsAnimationGroup != null && !(earsAnimationGroup!.isMounted)) {
        add(earsAnimationGroup!);
        earsAnimationGroup!.current = SimpleAnimationStateKey.normal;
      }
    }
    
    if (newExpression == MascotExpression.sad) {
      if (staticTear != null && !(staticTear!.isMounted) && !_isTearAnimatingCurrently) {
        add(staticTear!);
      }
    } else {
      if (staticTear?.isMounted ?? false) { remove(staticTear!); }
      if (animatedTearComponent?.isMounted ?? false) { remove(animatedTearComponent!); }
      _isTearAnimatingCurrently = false;
    }
  }
}

class MascotGame extends FlameGame {
  final HabitProvider habitProvider;
  late MascotCharacter mascot;
  bool _mascotInitialized = false;
  MascotState? _lastProviderState;
  String? _lastOutfitAsset;

  MascotGame({required this.habitProvider});

  @override
  ui.Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      mascot = MascotCharacter();
      mascot.position = size / 2;
      await add(mascot);
      
      _lastOutfitAsset = habitProvider.currentOutfit;
      await mascot.updateOutfit(_lastOutfitAsset!);

      _mascotInitialized = true;
    } catch (e) { 
      if (kDebugMode) { print("Erro ao inicializar MascotGame: $e"); }
      _mascotInitialized = false; 
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_mascotInitialized) { return; }

    // Atualiza a expressão do mascote
    final currentState = habitProvider.mascotState;
    if (_lastProviderState != currentState) {
      _lastProviderState = currentState;
      
      MascotExpression targetExpression;
      switch (currentState) {
        case MascotState.happy: targetExpression = MascotExpression.happy; break;
        case MascotState.sad:   targetExpression = MascotExpression.sad;   break;
        default:                targetExpression = MascotExpression.neutral;break;
      }
      
      if (mascot._currentExpression != targetExpression) {
        mascot.setExpression(targetExpression);
      }
    }
    
    final currentOutfit = habitProvider.currentOutfit;
    if (_lastOutfitAsset != currentOutfit) {
      _lastOutfitAsset = currentOutfit;
      mascot.updateOutfit(currentOutfit);
    }
  }
}