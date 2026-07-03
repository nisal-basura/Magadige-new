import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordState extends Equatable {
  final int step; // 1 = email, 2 = otp, 3 = new password
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;
  final FormStatus status;
  final String? error;

  const ForgotPasswordState({
    this.step = 1,
    this.email = '',
    this.otp = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.status = FormStatus.initial,
    this.error,
  });

  ForgotPasswordState copyWith({
    int? step,
    String? email,
    String? otp,
    String? newPassword,
    String? confirmPassword,
    FormStatus? status,
    String? error,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [step, email, otp, newPassword, confirmPassword, status, error];
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _repository;

  ForgotPasswordCubit(this._repository) : super(const ForgotPasswordState());

  void emailChanged(String v) => emit(state.copyWith(email: v));

  void otpChanged(String v) => emit(state.copyWith(otp: v));

  void newPasswordChanged(String v) => emit(state.copyWith(newPassword: v));

  void confirmPasswordChanged(String v) => emit(state.copyWith(confirmPassword: v));

  Future<void> submitEmail() async {
    if (!state.email.contains('@')) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Enter a valid email address.'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    await _repository.requestPasswordReset(state.email);
    emit(state.copyWith(status: FormStatus.initial, step: 2));
  }

  Future<void> submitOtp() async {
    if (state.otp.trim().length != 4) {
      emit(state.copyWith(status: FormStatus.failure, error: 'Enter the 4-digit code.'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    final ok = await _repository.verifyOtp(email: state.email, otp: state.otp);
    if (ok) {
      emit(state.copyWith(status: FormStatus.initial, step: 3));
    } else {
      emit(state.copyWith(status: FormStatus.failure, error: 'That code doesn\'t look right.'));
    }
  }

  Future<void> submitNewPassword() async {
    if (state.newPassword.length < 6 || state.newPassword != state.confirmPassword) {
      emit(state.copyWith(status: FormStatus.failure, error: "Passwords must match and be at least 6 characters."));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    await _repository.resetPassword(email: state.email, newPassword: state.newPassword);
    emit(state.copyWith(status: FormStatus.success));
  }
}
