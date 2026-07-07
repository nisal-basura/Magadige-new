import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/category_repository.dart';

class CategoriesState extends Equatable {
  final FormStatus status;
  final List<CategoryModel> categories;

  const CategoriesState({this.status = FormStatus.initial, this.categories = const []});

  CategoriesState copyWith({FormStatus? status, List<CategoryModel>? categories}) =>
      CategoriesState(status: status ?? this.status, categories: categories ?? this.categories);

  @override
  List<Object?> get props => [status, categories];
}

/// App-wide category catalog, loaded once at startup (mirrors `ThemeCubit` in
/// spirit) — every task references a category by id, and the create/edit
/// task form needs the full list to populate its picker.
/// Deliberately does *not* load in its constructor — every task-scoped
/// endpoint requires auth, so loading eagerly at app startup (before the
/// session is known) would just 401. `MagadigeApp` triggers [load] once
/// [SessionCubit] reports `authenticated`.
class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepository _repository;

  CategoriesCubit(this._repository) : super(const CategoriesState());

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      final categories = await _repository.fetchCategories();
      emit(state.copyWith(status: FormStatus.success, categories: categories));
    } catch (_) {
      emit(state.copyWith(status: FormStatus.failure));
    }
  }
}
