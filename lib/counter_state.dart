import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int count;
  final bool isMod5;

  const CounterState({
    required this.count,
    required this.isMod5,
  });

  @override
  List<Object?> get props => [count, isMod5];
}
