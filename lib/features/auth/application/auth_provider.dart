import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isGuest;
  final String? userId;
  final String? userName;

  const AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.userId,
    this.userName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isGuest,
    String? userId,
    String? userName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({bool initialAuthenticated = false})
      : super(AuthState(
          isAuthenticated: initialAuthenticated,
          userId: initialAuthenticated ? 'sample_user_1' : null,
          userName: initialAuthenticated ? 'Alex Parker' : null,
        ));

  void signIn({String? userId, String? userName}) {
    state = state.copyWith(
      isAuthenticated: true,
      isGuest: false,
      userId: userId ?? 'sample_user_1',
      userName: userName ?? 'Alex Parker',
    );
  }

  void continueAsGuest() {
    state = const AuthState(
      isAuthenticated: true,
      isGuest: true,
      userId: 'guest_user',
      userName: 'Guest',
    );
  }

  void signOut() {
    state = const AuthState(isAuthenticated: false, isGuest: false, userId: null, userName: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
