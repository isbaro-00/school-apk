import 'package:supabase_flutter/supabase_flutter.dart';

class SuperAdminService {
  final SupabaseClient client;

  SuperAdminService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listSchools() async {
    final data = await client
        .from('schools')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listSchoolPayments() async {
    final data = await client
        .from('school_payments')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listSupportTickets() async {
    final data = await client
        .from('support_tickets')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
