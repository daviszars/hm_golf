import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hm_golf/bloc/golf_swing_bloc.dart';
import 'package:hm_golf/bloc/golf_swing_event.dart';
import 'package:hm_golf/bloc/golf_swing_state.dart';
import 'package:hm_golf/models/golf_swing.dart';

class InspectionPage extends StatelessWidget {
  const InspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GolfSwingBloc, GolfSwingState>(
      listener: (context, state) {
        if (state is GolfSwingEmpty) {
          Navigator.of(context).pop();
        }
        else if (state is GolfSwingLoading || state is GolfSwingInitial) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<GolfSwingBloc, GolfSwingState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Swing Analysis'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                if (state is GolfSwingLoaded && state.selectedSwing != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete Swing',
                    onPressed: () {
                      _showDeleteConfirmation(context, state.selectedSwing!);
                    },
                  ),
              ],
            ),

            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(GolfSwingState state) {
    if (state is GolfSwingLoaded && state.selectedSwing != null) {
      final swing = state.selectedSwing!;

      return Column(
        children: [
          _SwingInfoSection(swing: swing, state: state),

          Expanded(child: _ChartSection(swing: swing)),
        ],
      );
    }
    else {
      return const Center(child: Text('No swing selected'));
    }
  }

  void _showDeleteConfirmation(BuildContext context, GolfSwing swing) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Swing'),
          content: Text('Are you sure you want to delete "${swing.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<GolfSwingBloc>().add(DeleteSwingEvent(swing.id));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _SwingInfoSection extends StatelessWidget {
  final GolfSwing swing;
  final GolfSwingLoaded state;

  const _SwingInfoSection({required this.swing, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            swing.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Data points: ${swing.maxDataPoints}',
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: state.canGoPrevious
                    ? () {
                        context.read<GolfSwingBloc>().add(PreviousSwingEvent());
                      }
                    : null,
                child: const Text('Previous'),
              ),

              Text(
                '${state.currentIndex + 1} of ${state.swings.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              ElevatedButton(
                onPressed: state.canGoNext
                    ? () {
                        context.read<GolfSwingBloc>().add(NextSwingEvent());
                      }
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final GolfSwing swing;

  const _ChartSection({required this.swing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 24.0,
        top: 16.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wrist Movement Analysis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(width: 16, height: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Flexion/Extension'),
              const SizedBox(width: 24),

              Container(width: 16, height: 16, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Ulnar/Radial'),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: LineChart(_createChartData()),
          ),
        ],
      ),
    );
  }
  LineChartData _createChartData() {
    final flexExtData = swing.parameters.flexExtValues;
    final radUlnData = swing.parameters.radUlnValues;

    final List<FlSpot> flexExtSpots = [];
    for (int i = 0; i < flexExtData.length; i++) {
      flexExtSpots.add(FlSpot(i.toDouble(), flexExtData[i]));
    }

    final List<FlSpot> radUlnSpots = [];
    for (int i = 0; i < radUlnData.length; i++) {
      radUlnSpots.add(FlSpot(i.toDouble(), radUlnData[i]));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          if (value == 0) {
            return const FlLine(
              color: Colors.black,
              strokeWidth: 1.5,
            );
          }
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 0.5,
          );
        },
      ),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value % 100 == 0) {
                return Text(value.toInt().toString());
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),

      lineBarsData: [
        LineChartBarData(
          spots: flexExtSpots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2.0,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),

        LineChartBarData(
          spots: radUlnSpots,
          isCurved: true,
          color: Colors.red,
          barWidth: 2.0,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],

      lineTouchData: LineTouchData(
        touchSpotThreshold: 20,
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: Colors.grey.withValues(alpha: 0.5),
                    strokeWidth: 1.0,
                    dashArray: [3, 3],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color:
                            barData.color ??
                            Colors.blue,
                        strokeColor: Colors.white,
                        strokeWidth: 1,
                      );
                    },
                  ),
                );
              }).toList();
            },
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isFlexExt = spot.barIndex == 0;
              final label = isFlexExt ? 'Flex/Ext' : 'Ulnar/Radial';
              return LineTooltipItem(
                '$label\nTime: ${spot.x.toInt()}\nValue: ${spot.y.toStringAsFixed(1)}°',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
