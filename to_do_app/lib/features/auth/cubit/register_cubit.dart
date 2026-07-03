import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterState extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool agreedToTerms;
  final FormStatus status;
  final String? error;

  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.agreedToTerms = false,
    this.status = FormStatus.initial,
    this.error,
  });

  /// 0-4 strength score, mirrors the web's pw-strength meter logic.
  int get passwordStrength {
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  bool get isValid =>
      name.trim().isNotEmpty &&
      email.contains('@') &&
      password.length >= 6 &&
      password == confirmPassword &&
      agreedToTerms;

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? agreedToTerms,
    FormStatus? status,
    String? error,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [name, email, password, confirmPassword, obscurePassword, agreedToTerms, status, error];
}

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _repository;

  RegisterCubit(this._repository) : super(const RegisterState());

  void nameChanged(String v) => emit(state.copyWith(name: v, status: FormStatus.initial));

  void emailChanged(String v) => emit(state.copyWith(email: v, status: FormStatus.initial));

  void passwordChanged(String v) => emit(state.copyWith(password: v, status: FormStatus.initial));

  void confirmPasswordChanged(String v) => emit(state.copyWith(confirmPassword: v, status: FormStatus.initial));

  void toggleObscure() => emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleAgreed() => emit(state.copyWith(agreedToTerms: !state.agreedToTerms));

  Future<void> submit() async {
    if (!state.isValid) {
      final reason = state.password != state.confirmPassword
          ? "Passwords don't match."
          : !state.agreedToTerms
              ? 'Please agree to the Terms & Privacy Policy.'
              : 'Please fill in every field correctly.';
      emit(state.copyWith(status: FormStatus.failure, error: reason));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      await _repository.register(name: state.name, email: state.email, password: state.password);
      emit(state.copyWith(status: FormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Something went wrong. Please try again.'));
    }
  }
}
