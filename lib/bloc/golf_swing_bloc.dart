import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hm_golf/bloc/golf_swing_event.dart';
import 'package:hm_golf/bloc/golf_swing_state.dart';
import 'package:hm_golf/models/golf_swing.dart';

class GolfSwingBloc extends Bloc<GolfSwingEvent, GolfSwingState> {
  GolfSwingBloc() : super(GolfSwingInitial()) {
    on<LoadSwingsEvent>(_onLoadSwings);
    on<SelectSwingEvent>(_onSelectSwing);
    on<NextSwingEvent>(_onNextSwing);
    on<PreviousSwingEvent>(_onPreviousSwing);
    on<DeleteSwingEvent>(_onDeleteSwing);
  }

  Future<void> _onLoadSwings(
    LoadSwingsEvent event,
    Emitter<GolfSwingState> emit,
  ) async {
    emit(GolfSwingLoading());

    try {
      final List<String> jsonFiles = [
        '1.json',
        '2.json',
        '3.json',
        '4.json',
        '5.json',
      ];
      final List<GolfSwing> swings = [];

      for (String fileName in jsonFiles) {
        try {
          final String jsonString = await rootBundle.loadString(
            'assets/swings/$fileName',
          );

          final Map<String, dynamic> jsonData = json.decode(jsonString);

          final GolfSwing swing = GolfSwing.fromJson(jsonData, fileName);

          if (swing.hasValidData) {
            swings.add(swing);
          }
        } catch (e) {
          debugPrint('Error loading $fileName: $e');
        }
      }

      swings.sort((a, b) => a.id.compareTo(b.id));

      if (swings.isEmpty) {
        emit(const GolfSwingEmpty());
      } else {
        emit(
          GolfSwingLoaded(
            swings: swings,
            selectedSwing: swings.first,
            currentIndex: 0,
          ),
        );
      }
    } catch (e) {
      emit(GolfSwingError('Failed to load swings: $e'));
    }
  }

  void _onSelectSwing(SelectSwingEvent event, Emitter<GolfSwingState> emit) {
    final currentState = state;

    if (currentState is GolfSwingLoaded) {
      final swingIndex = currentState.swings.indexWhere(
        (swing) => swing.id == event.swingId,
      );

      if (swingIndex != -1) {
        final selectedSwing = currentState.swings[swingIndex];

        emit(
          currentState.copyWith(
            selectedSwing: selectedSwing,
            currentIndex: swingIndex,
          ),
        );
      }
    }
  }

  void _onNextSwing(NextSwingEvent event, Emitter<GolfSwingState> emit) {
    final currentState = state;

    if (currentState is GolfSwingLoaded && currentState.canGoNext) {
      final nextIndex = currentState.currentIndex + 1;
      final nextSwing = currentState.swings[nextIndex];

      emit(
        currentState.copyWith(
          selectedSwing: nextSwing,
          currentIndex: nextIndex,
        ),
      );
    }
  }

  void _onPreviousSwing(
    PreviousSwingEvent event,
    Emitter<GolfSwingState> emit,
  ) {
    final currentState = state;

    if (currentState is GolfSwingLoaded && currentState.canGoPrevious) {
      final previousIndex = currentState.currentIndex - 1;
      final previousSwing = currentState.swings[previousIndex];

      emit(
        currentState.copyWith(
          selectedSwing: previousSwing,
          currentIndex: previousIndex,
        ),
      );
    }
  }

  void _onDeleteSwing(DeleteSwingEvent event, Emitter<GolfSwingState> emit) {
    final currentState = state;

    if (currentState is GolfSwingLoaded) {
      final updatedSwings = currentState.swings
          .where((swing) => swing.id != event.swingId)
          .toList();

      if (updatedSwings.isEmpty) {
        emit(const GolfSwingEmpty());
      } else {
        int newIndex = currentState.currentIndex;

        if (newIndex >= updatedSwings.length) {
          newIndex = updatedSwings.length - 1;
        }
        emit(
          GolfSwingLoaded(
            swings: updatedSwings,
            selectedSwing: updatedSwings[newIndex],
            currentIndex: newIndex,
          ),
        );
      }
    }
  }
}
