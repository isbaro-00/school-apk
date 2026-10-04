import 'package:flutter/material.dart';
import 'super_admin_service.dart';

class SchoolsScreen extends StatelessWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SuperAdminService();

    return Scaffold(
      appBar: AppBar(title: const Text('Schools')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.listSchools(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final row = rows[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.business),
                  ),
                  title: Text('${row['name'] ?? 'School'}'),
                  subtitle: Text(
                    'Code: ${row['school_code'] ?? '-'}\n'
                    'Status: ${row['status'] ?? '-'}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
