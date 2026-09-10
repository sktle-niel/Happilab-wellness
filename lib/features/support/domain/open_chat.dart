/// The chat the member has open, remembered for the session: leaving the
/// screen and coming back lands in the same line, not a second one. It is
/// let go when the chat ends, and with the session.
class OpenChat {
  String? id;

  void forget() => id = null;
}
