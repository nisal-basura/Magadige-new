import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/form_status.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class AchievementsState extends Equatable {
  final FormStatus status;
  final UserModel? user;
  final List<BadgeModel> badges;

  const AchievementsState({this.status = FormStatus.initial, this.user, this.badges = const []});

  int get earnedCount => badges.where((b) => b.earned).length;

  List<BadgeModel> get earnedSortedByDate {
    final earned = badges.where((b) => b.earned && b.earnedDate != null).toList();
    earned.sort((a, b) => b.earnedDate!.compareTo(a.earnedDate!));
    return earned;
  }

  AchievementsState copyWith({FormStatus? status, UserModel? user, List<BadgeModel>? badges}) {
    return AchievementsState(status: status ?? this.status, user: user ?? this.user, badges: badges ?? this.badges);
  }

  @override
  List<Object?> get props => [status, user, badges];
}

class AchievementsCubit extends Cubit<AchievementsState> {
  final UserRepository _repository;

  AchievementsCubit(this._repository) : super(const AchievementsState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: FormStatus.submitting));
    final results = await Future.wait([_repository.getCurrentUser(), _repository.getBadges()]);
    emit(state.copyWith(status: FormStatus.success, user: results[0] as UserModel, badges: results[1] as List<BadgeModel>));
  }
}
