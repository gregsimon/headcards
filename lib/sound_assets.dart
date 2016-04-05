part of headcards;


class SoundAssets {
  SoundAssets(this._bundle) {
    _soundEffectPlayer = new SoundEffectPlayer(4);
  }

  AssetBundle _bundle;
  SoundEffectPlayer _soundEffectPlayer;
  Map<String, SoundEffect> _soundEffects = <String, SoundEffect>{};

  Future load(String name) async {
    _soundEffects[name] = await _soundEffectPlayer.load(
      await _bundle.load('assets/$name.wav')
    );
  }

  void play(String name) {
    _soundEffectPlayer.play(_soundEffects[name]);
  }
}
