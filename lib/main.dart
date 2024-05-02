import 'package:ephemeral_state_management/counter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(
      const CounterState(
        count: 0,
        isMod5: true,
      ),
    );
    return LocalStateScope(
      state: state,
      child: const _Contents(),
    );
  }
}

class _Contents extends StatelessWidget {
  const _Contents();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Column(
          children: [
            _CountText(),
            Gap(16),
            _Mod5Text(),
            Gap(16),
            _Mod5TextModified(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => LocalStateScope.of<CounterState>(context)!.update(
          (state) {
            final newCount = state.count + 1;
            return CounterState(count: newCount, isMod5: newCount % 5 == 0);
          },
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CountText extends HookWidget {
  const _CountText();

  @override
  Widget build(BuildContext context) {
    final state = useScopedState<CounterState>();
    debugPrint('build _CountText');
    return Text('count: ${state.count}');
  }
}

class _Mod5Text extends HookWidget {
  const _Mod5Text();

  @override
  Widget build(BuildContext context) {
    final isMod5 = useSelectScoped<CounterState, bool>((state) => state.isMod5);
    debugPrint('build _Mod5Text');
    return Text('isMod5: $isMod5');
  }
}

class _Mod5TextModified extends HookWidget {
  const _Mod5TextModified();

  @override
  Widget build(BuildContext context) {
    final isMod5 = useSelectScoped<CounterState, bool>((state) => state.isMod5);
    debugPrint('build _Mod5TextModified');
    return Text(isMod5 ? 'is mod 5' : 'not mod 5');
  }
}

State useScopedState<State>() {
  final context = useContext();
  final scope = LocalStateScope.of<State>(context);
  if (scope == null) {
    throw StateError('No LocalStateScope found in the widget tree.');
  }

  final state = scope.state;
  return useValueListenable(state);
}

Selected useSelectScoped<State, Selected>(
  Selected Function(State state) selector,
) {
  final context = useContext();
  final scope = LocalStateScope.of<State>(context);
  if (scope == null) {
    throw StateError('No LocalStateScope found in the widget tree.');
  }

  return useListenableSelector(scope.state, () => selector(scope.state.value));
}

class LocalStateScope<State> extends InheritedWidget {
  const LocalStateScope({
    super.key,
    required this.state,
    required super.child,
  });

  final ValueNotifier<State> state;

  static LocalStateScope<State>? of<State>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LocalStateScope<State>>();

  void update(State Function(State state) updater) {
    state.value = updater(state.value);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
