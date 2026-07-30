import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

final selectedCustomerProvider = StateProvider<Customer?>((ref) => null);
