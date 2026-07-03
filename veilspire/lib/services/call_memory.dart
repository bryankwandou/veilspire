/// Per-character conversation memory. A companion remembers earlier calls
/// within the play session, so repeated calls build on one another —
/// the arc characters (Lyra, Seraphine) open up across calls.
class CallMemory {
  CallMemory._();

  static final Map<String, List<Map<String, String>>> _store = {};

  /// The running message history for one character, shared across calls.
  static List<Map<String, String>> historyFor(String characterId) =>
      _store.putIfAbsent(characterId, () => []);

  /// How many calls the player has had with this character this session.
  static final Map<String, int> _callCounts = {};

  static int beginCall(String characterId) =>
      _callCounts.update(characterId, (v) => v + 1, ifAbsent: () => 1);
}
