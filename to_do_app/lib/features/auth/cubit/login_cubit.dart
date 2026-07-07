import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/session_cubit.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/form_status.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool obscurePassword;
  final bool rememberMe;
  final FormStatus status;
  final String? error;

  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.rememberMe = true,
    this.status = FormStatus.initial,
    this.error,
  });

  bool get isValid => email.contains('@') && password.length >= 6;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? rememberMe,
    FormStatus? status,
    String? error,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [email, password, obscurePassword, rememberMe, status, error];
}

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _repository;
  final SessionCubit _session;

  LoginCubit(this._repository, this._session) : super(const LoginState());

  void emailChanged(String value) => emit(state.copyWith(email: value, status: FormStatus.initial));

  void passwordChanged(String value) => emit(state.copyWith(password: value, status: FormStatus.initial));

  void toggleObscure() => emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleRemember() => emit(state.copyWith(rememberMe: !state.rememberMe));

  Future<void> submit() async {
    if (!state.isValid) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Enter a valid email and password.'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      final user = await _repository.login(email: state.email, password: state.password);
      _session.setAuthenticated(user);
      emit(state.copyWith(status: FormStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(status: FormStatus.failure, error: e.displayMessage));
    } catch (e) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Something went wrong. Please try again.'));
    }
  }
}
