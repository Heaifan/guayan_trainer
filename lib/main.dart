import 'package:flutter/material.dart';

import 'app.dart';
import 'services/mistake_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MistakeStore.instance.all; // trigger lazy load
  runApp(const GuayanTrainerApp());
}
