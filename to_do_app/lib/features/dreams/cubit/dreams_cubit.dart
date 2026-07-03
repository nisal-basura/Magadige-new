import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/dream_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/dream_repository.dart';
import '../../../data/repositories/task_repository.dart';

class DreamsState extends Equatable {
  final FormStatus status;
  final List<DreamModel> dreams;
  final List<TaskModel> tasks;

  const DreamsState({this.status = FormStatus.initial, this.dreams = const [], this.tasks = const []});

  List<TaskModel> relatedTasks(DreamModel dream) => tasks.where((t) => dream.relatedTaskIds.contains(t.id)).toList();

  DreamsState copyWith({FormStatus? status, List<DreamModel>? dreams, List<TaskModel>? tasks}) {
    return DreamsState(status: status ?? this.status, dreams: dreams ?? this.dreams, tasks: tasks ?? this.tasks);
  }

  @override
  List<Object?> get props => [status, dreams, tasks];
}

class DreamsCubit extends Cubit<DreamsState> {
  final DreamRepository _dreamRepository;
  final TaskRepository _taskRepository;

  DreamsCubit(this._dreamRepository, this._taskRepository) : super(const DreamsState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final results = await Future.wait([_dreamRepository.fetchDreams(), _taskRepository.fetchTasks()]);
    emit(state.copyWith(status: FormStatus.success, dreams: results[0] as List<DreamModel>, tasks: results[1] as List<TaskModel>));
  }

  Future<void> addDream(DreamModel dream) async {
    await _dreamRepository.createDream(dream);
    emit(state.copyWith(dreams: [...state.dreams, dream]));
  }

  Future<void> bumpProgress(DreamModel dream, {int by = 10}) async {
    final updated = dream.copyWith(progress: (dream.progress + by).clamp(0, 100));
    await _dreamRepository.updateDream(updated);
    emit(state.copyWith(dreams: state.dreams.map((d) => d.id == updated.id ? updated : d).toList()));
  }

  Future<void> deleteDream(DreamModel dream) async {
    await _dreamRepository.deleteDream(dream.id);
    emit(state.copyWith(dreams: state.dreams.where((d) => d.id != dream.id).toList()));
  }
}
