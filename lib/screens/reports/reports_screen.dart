import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/animal_provider.dart';
import '../../providers/milk_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/health_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsProvider);
    final milkAsync = ref.watch(milkRecordsProvider);
    final salesAsync = ref.watch(salesProvider);
    final feedsAsync = ref.watch(feedsProvider);
    final upcomingAsync = ref.watch(upcomingAppointmentsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            const Text(
              'Farm Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                // Total Animals
                animalsAsync.when(
                  data: (animals) => _buildOverviewCard(
                    title: 'Total Animals',
                    value: '${animals.length}',
                    subtitle:
                        '${animals.where((a) => a.isPregnant).length} pregnant',
                    icon: Icons.pets,
                    color: Colors.brown,
                  ),
                  loading: () => _buildOverviewCard(
                    title: 'Total Animals',
                    value: '...',
                    subtitle: '',
                    icon: Icons.pets,
                    color: Colors.brown,
                  ),
                  error: (_, _) => _buildOverviewCard(
                    title: 'Total Animals',
                    value: '0',
                    subtitle: '',
                    icon: Icons.pets,
                    color: Colors.brown,
                  ),
                ),

                // Total Milk
                milkAsync.when(
                  data: (records) {
                    final total = records.fold(
                        0.0, (sum, r) => sum + r.totalAmount);
                    return _buildOverviewCard(
                      title: 'Total Milk',
                      value: '${total.toStringAsFixed(1)} L',
                      subtitle: '${records.length} records',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                    );
                  },
                  loading: () => _buildOverviewCard(
                    title: 'Total Milk',
                    value: '...',
                    subtitle: '',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                  error: (_, _) => _buildOverviewCard(
                    title: 'Total Milk',
                    value: '0 L',
                    subtitle: '',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                ),

                // Total Income
                salesAsync.when(
                  data: (sales) {
                    final total = sales.fold(
                        0.0, (sum, s) => sum + s.totalAmount);
                    final paid = sales
                        .where((s) => s.paymentStatus == 'Paid')
                        .fold(0.0, (sum, s) => sum + s.totalAmount);
                    return _buildOverviewCard(
                      title: 'Total Income',
                      value: '₹${total.toStringAsFixed(0)}',
                      subtitle:
                          '₹${paid.toStringAsFixed(0)} received',
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    );
                  },
                  loading: () => _buildOverviewCard(
                    title: 'Total Income',
                    value: '...',
                    subtitle: '',
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                  ),
                  error: (_, _) => _buildOverviewCard(
                    title: 'Total Income',
                    value: '₹0',
                    subtitle: '',
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                  ),
                ),

                // Feed Cost
                feedsAsync.when(
                  data: (feeds) {
                    final total = feeds.fold(
                        0.0, (sum, f) => sum + f.totalCost);
                    final lowStock =
                        feeds.where((f) => f.isLowStock).length;
                    return _buildOverviewCard(
                      title: 'Feed Cost',
                      value: '₹${total.toStringAsFixed(0)}',
                      subtitle: '$lowStock low stock',
                      icon: Icons.grass,
                      color: Colors.orange,
                    );
                  },
                  loading: () => _buildOverviewCard(
                    title: 'Feed Cost',
                    value: '...',
                    subtitle: '',
                    icon: Icons.grass,
                    color: Colors.orange,
                  ),
                  error: (_, _) => _buildOverviewCard(
                    title: 'Feed Cost',
                    value: '₹0',
                    subtitle: '',
                    icon: Icons.grass,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly Milk Chart
            milkAsync.when(
              data: (records) {
                if (records.isEmpty) return const SizedBox();
                return _buildMilkChart(records);
              },
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),

            // Monthly Income Chart
            salesAsync.when(
              data: (sales) {
                if (sales.isEmpty) return const SizedBox();
                return _buildIncomeChart(sales);
              },
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),

            // Animal Summary
            animalsAsync.when(
              data: (animals) {
                if (animals.isEmpty) return const SizedBox();
                return _buildAnimalSummary(animals);
              },
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),

            // Upcoming Appointments
            upcomingAsync.when(
              data: (upcoming) {
                if (upcoming.isEmpty) return const SizedBox();
                return _buildUpcomingAppointments(upcoming);
              },
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Monthly Milk Chart
  Widget _buildMilkChart(List<dynamic> records) {
    final Map<String, double> monthlyData = {};
    for (final record in records) {
      final key = DateFormat('MMM').format(record.date);
      monthlyData[key] = (monthlyData[key] ?? 0) + record.totalAmount;
    }

    final entries = monthlyData.entries.toList();
    if (entries.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Milk Production',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: entries
                            .map((e) => e.value)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < entries.length) {
                              return Text(
                                entries[index].key,
                                style:
                                    const TextStyle(fontSize: 11),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: entries
                        .asMap()
                        .entries
                        .map((e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.value,
                                  color: Colors.blue,
                                  width: 20,
                                  borderRadius:
                                      const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Monthly Milk Production (Litres)',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Monthly Income Chart
  Widget _buildIncomeChart(List<dynamic> sales) {
    final Map<String, double> monthlyData = {};
    for (final sale in sales) {
      final key = DateFormat('MMM').format(sale.date);
      monthlyData[key] =
          (monthlyData[key] ?? 0) + sale.totalAmount;
    }

    final entries = monthlyData.entries.toList();
    if (entries.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sales Income',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(enabled: true),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) => Text(
                            '₹${value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < entries.length) {
                              return Text(
                                entries[index].key,
                                style:
                                    const TextStyle(fontSize: 11),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: entries
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value.value))
                            .toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green
                              .withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Monthly Sales Income (₹)',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Animal Summary
  Widget _buildAnimalSummary(List<dynamic> animals) {
    final cows =
        animals.where((a) => a.animalType == 'Cow').length;
    final buffalos =
        animals.where((a) => a.animalType == 'Buffalo').length;
    final pregnant =
        animals.where((a) => a.isPregnant).length;
    final females =
        animals.where((a) => a.gender == 'Female').length;
    final males =
        animals.where((a) => a.gender == 'Male').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animal Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('🐄 Cows', '$cows',
                      Colors.brown),
                  _summaryItem('🐃 Buffalos', '$buffalos',
                      Colors.grey),
                  _summaryItem('🤰 Pregnant', '$pregnant',
                      Colors.pink),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem(
                      '♀ Female', '$females', Colors.purple),
                  _summaryItem(
                      '♂ Male', '$males', Colors.blue),
                  _summaryItem('📊 Total',
                      '${animals.length}', Colors.green),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _summaryItem(
      String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Upcoming appointments
  Widget _buildUpcomingAppointments(List<dynamic> upcoming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcoming.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = upcoming[index];
              return ListTile(
                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event,
                      color: Colors.red),
                ),
                title: Text(
                  record.animalName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${record.recordType} — ${record.medicationName}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd MMM').format(
                          record.nextAppointmentDate!),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${record.daysUntilAppointment} days',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}