import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/token_store.dart';
import '../data/auth_repository.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).getAccessToken();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .saveTokens(accessToken: session.access, refreshToken: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clearTokens();
    ref.invalidateSelf();
  }
}