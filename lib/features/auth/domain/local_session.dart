/// Stand-in credential for the pre-backend build.
///
/// Sign-in and create-account store this marker so the whole session machinery
/// — persistence, restore on launch, revocation on 401 — runs for real while
/// the API does not exist yet. The repository call that returns a server token
/// replaces every use of it.
const String localSessionToken = 'local.session.v1';
