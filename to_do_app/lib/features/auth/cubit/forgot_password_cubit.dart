import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/form_status.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordState extends Equatable {
  final int step; // 1 = email, 2 = reset token, 3 = new password
  final String email;
  final String token;
  final String newPassword;
  final String confirmPassword;
  final FormStatus status;
  final String? error;

  const ForgotPasswordState({
    this.step = 1,
    this.email = '',
    this.token = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.status = FormStatus.initial,
    this.error,
  });

  ForgotPasswordState copyWith({
    int? step,
    String? email,
    String? token,
    String? newPassword,
    String? confirmPassword,
    FormStatus? status,
    String? error,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      token: token ?? this.token,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [step, email, token, newPassword, confirmPassword, status, error];
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _repository;

  ForgotPasswordCubit(this._repository) : super(const ForgotPasswordState());

  void emailChanged(String v) => emit(state.copyWith(email: v));

  void tokenChanged(String v) => emit(state.copyWith(token: v));

  void newPasswordChanged(String v) => emit(state.copyWith(newPassword: v));

  void confirmPasswordChanged(String v) => emit(state.copyWith(confirmPassword: v));

  Future<void> submitEmail() async {
    if (!state.email.contains('@')) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Enter a valid email address.'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      await _repository.requestPasswordReset(state.email);
      emit(state.copyWith(status: FormStatus.initial, step: 2));
    } on ApiException catch (e) {
      emit(state.copyWith(status: FormStatus.failure, error: e.displayMessage));
    }
  }

  void submitToken() {
    if (state.token.trim().isEmpty) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Paste the reset token from your email.'));
      return;
    }
    emit(state.copyWith(status: FormStatus.initial, step: 3));
  }

  Future<void> submitNewPassword() async {
    if (state.newPassword.length < 8 || state.newPassword != state.confirmPassword) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Passwords must match and be at least 8 characters.'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      await _repository.resetPassword(email: state.email, token: state.token.trim(), newPassword: state.newPassword);
      emit(state.copyWith(status: FormStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(status: FormStatus.failure, error: e.displayMessage));
    }
  }
}
