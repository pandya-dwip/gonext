import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'app/app.dart';
import 'modules/places/data/models/place_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database storage
  await Hive.initFlutter();
  Hive.registerAdapter(PlaceModelAdapter());
  await Hive.openBox<PlaceModel>('places_box');

  runApp(
    const ProviderScope(
      child: GoNextApp(),
    ),
  );
}
