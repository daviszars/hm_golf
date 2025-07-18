import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hm_golf/bloc/golf_swing_bloc.dart';
import 'package:hm_golf/bloc/golf_swing_event.dart';
import 'package:hm_golf/bloc/golf_swing_state.dart';
import 'package:hm_golf/models/golf_swing.dart';
import 'package:hm_golf/pages/inspection_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golf Swings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: BlocBuilder<GolfSwingBloc, GolfSwingState>(
        builder: (context, state) {
          if (state is GolfSwingInitial || state is GolfSwingLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading golf swings...'),
                ],
              ),
            );
          } else if (state is GolfSwingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GolfSwingBloc>().add(LoadSwingsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is GolfSwingEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No swings available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (state is GolfSwingLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.swings.length,
              itemBuilder: (context, index) {
                final swing = state.swings[index];
                return _SwingListItem(swing: swing);
              },
            );
          }
          else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}

class _SwingListItem extends StatelessWidget {
  final GolfSwing swing;

  const _SwingListItem({required this.swing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(
          swing.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Data points: ${swing.maxDataPoints}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.read<GolfSwingBloc>().add(SelectSwingEvent(swing.id));
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const InspectionPage()),
          );
        },
      ),
    );
  }
}
