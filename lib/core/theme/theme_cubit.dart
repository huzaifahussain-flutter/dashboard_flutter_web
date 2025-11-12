import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final bool isDark;
  const ThemeState({required this.isDark});

  ThemeState copyWith({bool? isDark}) => ThemeState(isDark: isDark ?? this.isDark);

  @override
  List<Object?> get props => [isDark];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(isDark: false));

  void toggleTheme() => emit(state.copyWith(isDark: !state.isDark));
}
