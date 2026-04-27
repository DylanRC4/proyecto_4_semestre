/// Fuente de datos remota de perfiles (Supabase).
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDatasource {
  final SupabaseClient _client;

  ProfileRemoteDatasource(this._client);

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  Future<void> updateProfile(String userId, {String? fullName, String? phone}) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }
  }

  Future<List<Map<String, dynamic>>> getAllProfiles() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}