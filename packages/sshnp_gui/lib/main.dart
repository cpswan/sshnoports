import 'dart:async';

import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sshnp_gui/src/utility/platform_utility/platform_utililty.dart';

final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

Future<void> main() async {
  // * AtEnv is an abtraction of the flutter_dotenv package used to
  // * load the environment variables set by at_app
  try {
    await AtEnv.load();
  } catch (e) {
    _logger.finer('Environment failed to load from .env: ', e);
  }

  PlatformUtility platformUtility = PlatformUtility.current();
  await platformUtility.configurePlatform();
  runApp(ProviderScope(child: platformUtility.app));
}
