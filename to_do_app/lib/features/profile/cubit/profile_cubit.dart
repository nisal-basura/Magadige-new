import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/dream_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/dream_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ProfileState extends Equatable {
  final FormStatus status;
  final UserModel? user;
  final List<BadgeModel> badges;
  final int completedTasks;
  final int dreamsInMotion;

  const ProfileState({
    this.status = FormStatus.initial,
    this.user,
    this.badges = const [],
    this.completedTasks = 0,
    this.dreamsInMotion = 0,
  });

  ProfileState copyWith({FormStatus? status, UserModel? user, List<BadgeModel>? badges, int? completedTasks, int? dreamsInMotion}) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      badges: badges ?? this.badges,
      completedTasks: completedTasks ?? this.completedTasks,
      dreamsInMotion: dreamsInMotion ?? this.dreamsInMotion,
    );
  }

  @override
  List<Object?> get props => [status, user, badges, completedTasks, dreamsInMotion];
}

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository _userRepository;
  final TaskRepository _taskRepository;
  final DreamRepository _dreamRepository;

  ProfileCubit(this._userRepository, this._taskRepository, this._dreamRepository) : super(const ProfileState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final results = await Future.wait([
      _userRepository.getCurrentUser(),
      _userRepository.getBadges(),
      _taskRepository.fetchTasks(),
      _dreamRepository.fetchDreams(),
    ]);
    final tasks = results[2] as List<TaskModel>;
    final dreams = results[3] as List<DreamModel>;
    emit(state.copyWith(
      status: FormStatus.success,
      user: results[0] as UserModel,
      badges: results[1] as List<BadgeModel>,
      completedTasks: tasks.where((t) => t.status == TaskStatus.completed).length,
      dreamsInMotion: dreams.length,
    ));
  }
}
