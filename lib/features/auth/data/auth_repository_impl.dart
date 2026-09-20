import '../../../core/network/token_refresher.dart';
import '../../../core/network/token_store.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'auth_remote.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStore);

  final AuthRemote _remote;
  final TokenStore _tokenStore;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final response = await _remote.login(email: email, password: password);
    final session = response.toSession(email.trim().toLowerCase());
    await _persist(session);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final response = await _remote.register(
      nombre: nombre,
      email: email,
      password: password,
    );
    final session = response.toSession(email.trim().toLowerCase());
    await _persist(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final access = await _tokenStore.readAccessToken();
    final email = await _tokenStore.readEmail();
    if (access == null || email == null) {
      return null;
    }
    final nombre = await _tokenStore.readNombre();
    final refresh = await _tokenStore.readRefreshToken();
    return AuthSession(
      email: email,
      nombre: nombre ?? '',
      accessToken: access,
      refreshToken: refresh ?? '',
      roles: const [],
    );
  }

  @override
  Future<TokenRefreshResult?> refreshSession(String refreshToken) async {
    final response = await _remote.refresh(refreshToken: refreshToken);
    return TokenRefreshResult(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      nombre: response.nombre,
    );
  }

  @override
  Future<void> logout() async {
    try {
      final refresh = await _tokenStore.readRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        await _remote.logout(refreshToken: refresh);
      }
    } finally {
      await _tokenStore.clear();
    }
  }

  @override
  Future<void> clearSession() => _tokenStore.clear();

  Future<void> _persist(AuthSession session) {
    return _tokenStore.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      nombre: session.nombre,
      email: session.email,
    );
  }
}