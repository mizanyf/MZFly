/// Enum representing the core states of MZ Fly.
enum GameStatus {
  /// The player is at the main menu.
  menu,

  /// Ready to play, bird is hovering, waiting for initial tap.
  ready,

  /// Active gameplay session.
  playing,

  /// Gameplay is paused.
  paused,

  /// The player collided and the game has ended.
  gameOver,
}
