import 'dart:math' as math;

class ReadinessProjection {
  const ReadinessProjection._(
    this.globalLevel,
    this.classLevel,
    this.globalXpToNext,
    this.classXpToNext,
    this._globalFloor,
    this._classFloor,
    this._globalDelta,
    this._classDelta,
    this._classXpBase,
    this._classXpSlope,
    this._earnedGlobalLevel,
    this._earnedClassLevel,
    this._earnedGlobalXpToNext,
    this._earnedClassXpToNext,
  );
  final int globalLevel,
      classLevel,
      globalXpToNext,
      classXpToNext,
      _globalFloor,
      _classFloor,
      _globalDelta,
      _classDelta,
      _earnedGlobalLevel,
      _earnedClassLevel,
      _earnedGlobalXpToNext,
      _earnedClassXpToNext;
  final double _classXpBase, _classXpSlope;
  factory ReadinessProjection.calculate({
    required int confirmedGlobalFloor,
    required int confirmedClassFloor,
    required int globalPostConfirmationXp,
    required int classPostConfirmationXp,
    required int earnedGlobalLevel,
    required int earnedGlobalXpToNext,
    required int earnedClassLevel,
    required int earnedClassXpToNext,
    required double classXpBase,
    required double classXpSlope,
  }) {
    if (confirmedGlobalFloor < 1 ||
        confirmedGlobalFloor > 10 ||
        confirmedClassFloor < 1 ||
        confirmedClassFloor > 20 ||
        globalPostConfirmationXp < 0 ||
        classPostConfirmationXp < 0) {
      throw ArgumentError('Invalid readiness inputs');
    }
    return _build(
      confirmedGlobalFloor,
      confirmedClassFloor,
      globalPostConfirmationXp,
      classPostConfirmationXp,
      earnedGlobalLevel,
      earnedClassLevel,
      earnedGlobalXpToNext,
      earnedClassXpToNext,
      classXpBase,
      classXpSlope,
    );
  }
  ReadinessProjection advance({int globalXp = 0, int classXp = 0}) => _build(
    _globalFloor,
    _classFloor,
    _globalDelta + math.max(0, globalXp),
    _classDelta + math.max(0, classXp),
    _earnedGlobalLevel,
    _earnedClassLevel,
    _earnedGlobalXpToNext,
    _earnedClassXpToNext,
    _classXpBase,
    _classXpSlope,
  );
  static ReadinessProjection _build(
    int gf,
    int cf,
    int gd,
    int cd,
    int egl,
    int ecl,
    int egNext,
    int ecNext,
    double base,
    double slope,
  ) {
    final rawG = _level(gf, gd, _globalThreshold, 100);
    final rawC = _level(cf, cd, (n) => (base * math.pow(n, slope)).floor(), 20);
    final gl = math.max(egl, rawG), cl = math.max(ecl, rawC);
    final gn = egl > rawG
        ? egNext
        : _remaining(gl, gf, gd, _globalThreshold, 100);
    final cn = ecl > rawC
        ? ecNext
        : _remaining(
            cl,
            cf,
            cd,
            (n) => (base * math.pow(n, slope)).floor(),
            20,
          );
    return ReadinessProjection._(
      gl,
      cl,
      gn,
      cn,
      gf,
      cf,
      gd,
      cd,
      base,
      slope,
      egl,
      ecl,
      egNext,
      ecNext,
    );
  }

  static int _level(int floor, int delta, int Function(int) t, int cap) {
    var n = floor;
    while (n < cap && t(n + 1) - t(floor) <= delta) {
      n++;
    }
    return n;
  }

  static int _remaining(int l, int f, int d, int Function(int) t, int cap) =>
      l >= cap ? 0 : math.max(0, t(l + 1) - t(f) - d);
  static int _globalThreshold(int n) =>
      n <= 1 ? 0 : (100 * math.pow(n - 1, 1.5)).floor();
}
