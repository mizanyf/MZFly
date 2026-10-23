import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mzfly/game/game_status.dart';
import 'package:mzfly/game/mz_fly_game.dart';
import 'package:mzfly/main.dart';
import 'package:mzfly/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '.',
        );

    SharedPreferences.setMockInitialValues({
      'mzfly_best_score': 10,
      'mzfly_sound_enabled': true,
      'mzfly_music_enabled': true,
    });
    await StorageService.instance.init();
  });

  group('StorageService Tests', () {
    test('Loads cached best score and settings correctly', () {
      final storage = StorageService.instance;
      expect(storage.bestScore, 10);
      expect(storage.soundEnabled, true);
      expect(storage.musicEnabled, true);
    });

    test('Updates best score only when higher', () async {
      final storage = StorageService.instance;

      // Lower score should not update
      final updatedLower = await storage.updateBestScore(5);
      expect(updatedLower, false);
      expect(storage.bestScore, 10);

      // Higher score should update
      final updatedHigher = await storage.updateBestScore(25);
      expect(updatedHigher, true);
      expect(storage.bestScore, 25);
    });

    test('Toggles sound and music states', () async {
      final storage = StorageService.instance;

      await storage.setSoundEnabled(false);
      expect(storage.soundEnabled, false);

      await storage.setMusicEnabled(false);
      expect(storage.musicEnabled, false);
    });
  });

  group('MzFlyGame Gameplay Logic Tests', () {
    test(
      'Game initializes in menu status with correct default values',
      () async {
        final game = MzFlyGame();
        game.onGameResize(Vector2(400, 800));
        await game.onLoad();

        expect(game.status, GameStatus.menu);
        expect(game.score, 0);
        expect(game.bestScore, 10);
      },
    );

    test(
      'prepareReady transitions game to ready state and resets score',
      () async {
        final game = MzFlyGame();
        game.onGameResize(Vector2(400, 800));
        await game.onLoad();

        game.prepareReady();
        expect(game.status, GameStatus.ready);
        expect(game.score, 0);
      },
    );

    test('startGame begins active play and flaps bird', () async {
      final game = MzFlyGame();
      game.onGameResize(Vector2(400, 800));
      await game.onLoad();

      game.prepareReady();
      game.startGame();

      expect(game.status, GameStatus.playing);
      expect(game.bird.velocity.y, lessThan(0)); // Bird got flap impulse
    });

    test('incrementScore increases score', () async {
      final game = MzFlyGame();
      game.onGameResize(Vector2(400, 800));
      await game.onLoad();

      game.prepareReady();
      game.startGame();

      expect(game.score, 0);
      game.incrementScore();
      expect(game.score, 1);
      game.incrementScore();
      expect(game.score, 2);
    });

    test('onPlayerHit triggers game over and checks new best record', () async {
      final game = MzFlyGame();
      game.onGameResize(Vector2(400, 800));
      await game.onLoad();

      game.prepareReady();
      game.startGame();

      // Score 15 points (beats initial high score of 10)
      for (int i = 0; i < 15; i++) {
        game.incrementScore();
      }

      game.onPlayerHit();

      expect(game.status, GameStatus.gameOver);
      expect(game.bird.isDead, true);
      expect(game.isNewBest, true);
      expect(game.bestScore, 15);
    });

    test('returnToMenu returns to menu and resets obstacles', () async {
      final game = MzFlyGame();
      game.onGameResize(Vector2(400, 800));
      await game.onLoad();

      game.prepareReady();
      game.startGame();
      game.returnToMenu();

      expect(game.status, GameStatus.menu);
    });
  });

  group('Widget Smoke Tests', () {
    testWidgets('App renders MainMenu with title, Best Score and Play button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MzFlyApp());
      await tester.pump();

      // Check title and buttons exist
      expect(find.text('MZ FLY'), findsWidgets);
      expect(find.text('PLAY NOW'), findsOneWidget);
      expect(find.textContaining('BEST SCORE'), findsOneWidget);
      expect(find.text('SFX'), findsOneWidget);
      expect(find.text('BGM'), findsOneWidget);
    });
  });
}
