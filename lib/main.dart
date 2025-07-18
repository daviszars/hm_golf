import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hm_golf/bloc/golf_swing_bloc.dart';
import 'package:hm_golf/bloc/golf_swing_event.dart';
import 'package:hm_golf/pages/home_page.dart';

void main() {
  runApp(const HMGolfApp());
}

class HMGolfApp extends StatelessWidget {
  const HMGolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return BlocProvider<GolfSwingBloc>(
      create: (context) {
        final bloc = GolfSwingBloc();
        bloc.add(LoadSwingsEvent());
        return bloc;
      },

      child: MaterialApp(
        title: 'Golf Swing Analysis',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
