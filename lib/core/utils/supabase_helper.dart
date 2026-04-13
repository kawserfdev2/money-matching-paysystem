import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/injection.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';

class SupabaseHelper {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Returns a query builder with the `brand_id` filter automatically applied if impersonating.
  static PostgrestFilterBuilder<List<Map<String, dynamic>>> queryFiltered(
    String table, [
    String columns = '*',
    String brandColumn = 'brand_id',
  ]) {
    var query = _supabase.from(table).select(columns);
    final authBloc = getIt<AuthBloc>();
    final state = authBloc.state;
    if (state is Authenticated &&
        state.isImpersonating &&
        state.impersonatedBrandId != null) {
      return query.eq(brandColumn, state.impersonatedBrandId!);
    }
    return query; // Note: In supabase 2.0+ .select() returns a FilterBuilder, so this works natively.
  }

  /// Appends `brand_id` to the JSON if the user is impersonating, ensuring that
  /// Superadmins with RLS bypass do not insert their own UID instead of the merchant's.
  static Map<String, dynamic> injectBrandId(Map<String, dynamic> json) {
    final authBloc = getIt<AuthBloc>();
    final state = authBloc.state;
    if (state is Authenticated &&
        state.isImpersonating &&
        state.impersonatedBrandId != null) {
      json['brand_id'] = state.impersonatedBrandId!;
    }
    return json;
  }

  /// Returns a stream builder with the `brand_id` filter automatically applied if impersonating.
  static SupabaseStreamBuilder streamFiltered(
    String table,
    List<String> primaryKey,
  ) {
    var stream = _supabase.from(table).stream(primaryKey: primaryKey);
    final authBloc = getIt<AuthBloc>();
    final state = authBloc.state;
    if (state is Authenticated &&
        state.isImpersonating &&
        state.impersonatedBrandId != null) {
      return stream.eq('brand_id', state.impersonatedBrandId!);
    }
    return stream;
  }
}
