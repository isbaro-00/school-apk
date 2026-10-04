import 'package:flutter/material.dart';
import 'super_admin_service.dart';
import 'schools_screen.dart';
import 'school_payments_screen.dart';
import 'support_tickets_screen.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SuperAdminService();

    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.listSchools(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final schools = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Platform Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Registered schools: ${schools.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ActionCard(
                title: 'Schools',
                icon: Icons.business_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SchoolsScreen(),
                  ),
                ),
              ),
              _ActionCard(
                title: 'School Payments',
                icon: Icons.payments_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SchoolPaymentsScreen(),
                  ),
                ),
              ),
              _ActionCard(
                title: 'Support Tickets',
                icon: Icons.support_agent_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportTicketsScreen(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
