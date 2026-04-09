import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ApiClient();
  const storage = FlutterSecureStorage();
  return AuthNotifier(apiClient, storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._apiClient, this._storage) : super(AuthState()) {
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    print('AuthNotifier: Checking auth state...');
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Enforce artificial 1.5s delay for splash screen as required
      await Future.delayed(const Duration(milliseconds: 1500));

      final token = await _storage.read(key: 'accessToken');
      print('AuthNotifier: Token found: ${token != null}');

      if (token != null && !JwtDecoder.isExpired(token)) {
        try {
          final profileResponse = await _apiClient.get(AppEndpoints.profile);
          print('AuthNotifier: Profile response status: ${profileResponse.statusCode}');

          if (profileResponse.statusCode == 200) {
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: profileResponse.data,
            );
          } else {
            state = state.copyWith(status: AuthStatus.unauthenticated);
          }
        } catch (e) {
          print('AuthNotifier: Profile fetch error: $e');
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        print('AuthNotifier: No valid token found.');
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('AuthNotifier: Global error in checkAuthState: $e');
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _apiClient.post(
        AppEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];

        // Decode token to check role
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role'] ?? '';

        if (role == 'salesperson') {
          await _storage.write(key: 'accessToken', value: token);
          await _storage.write(key: 'refreshToken', value: refreshToken);

          // Get profile
          final profileResponse = await _apiClient.get(AppEndpoints.profile);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: profileResponse.data,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Access Denied: Salesperson role required.',
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Login failed: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Connection error. Please check your internet.',
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}
