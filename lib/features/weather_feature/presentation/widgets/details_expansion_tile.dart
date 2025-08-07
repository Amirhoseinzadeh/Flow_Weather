import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DetailsExpansionTile extends StatefulWidget {
  final Widget child;

  const DetailsExpansionTile({
    super.key,
    required this.child,
  });

  @override
  DetailsExpansionTileState createState() => DetailsExpansionTileState();
}

class DetailsExpansionTileState extends State<DetailsExpansionTile> {
  late bool _isExpanded;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<HomeBloc>().state;
    _isExpanded = state.isDetailsExpanded; // همگام‌سازی با وضعیت Bloc
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.1),
          const Text(
            'جزئیات',
            style: TextStyle(
              fontFamily: "entezar",
              fontSize: 22,
              color: Colors.orangeAccent,
            ),
          ).animate(
            target: _isExpanded ? 1 : 0,
            effects: [
              ScaleEffect(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 400),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white70,
            size: 26,
          ),
        ],
      ),
      trailing: const SizedBox.shrink(),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (isExpanded) {
        setState(() {
          _isExpanded = isExpanded;
        });
        // context.read<HomeBloc>().add(ToggleDetailsExpansion(isExpanded));
      },
      children: [
        widget.child,
      ],
    );
  }
}