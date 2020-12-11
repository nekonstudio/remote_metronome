import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Role { Host, Client, None }

class RoleProvider extends StateNotifier<Role> {
  RoleProvider() : super(Role.None);

  set role(Role role) => state = role;
}

final roleProvider = StateNotifierProvider((ref) => RoleProvider());
