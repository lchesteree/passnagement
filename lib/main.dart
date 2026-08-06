import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

import 'module/home/home_page.dart';
import 'module/home/model/password_entry.dart';
import 'module/home/model/password_group.dart';
import 'module/setup/setup_page.dart';
import 'service/encryption_service.dart';
import 'service/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowWidth = 350.0;
  const windowHeight = 800.0;

  const WindowOptions windowOptions = WindowOptions(
    size: Size(windowWidth, windowHeight),
    minimumSize: Size(windowWidth, windowHeight),
    maximumSize: Size(windowWidth, windowHeight),
    center: false,
    alwaysOnTop: true,
    title: "Passnagement",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    Display display = await screenRetriever.getPrimaryDisplay();
    await windowManager.setPosition(
      Offset(display.size.width - windowWidth - 50, 50),
    );
    // await windowManager.setMinimizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.setPreventClose(true);
    await windowManager.show();
    await windowManager.focus();
  });

  await Hive.initFlutter();
  Hive.registerAdapter(PasswordEntryAdapter());
  Hive.registerAdapter(PasswordGroupAdapter());
  await PreferenceService.open();

  final hasKey = await EncryptionService.hasKey();
  if (hasKey) await EncryptionService.openBoxFromStorage();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(boxReady: hasKey),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.boxReady});

  final bool boxReady;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTray());
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initTray() async {
    await trayManager.setIcon('assets/icon.ico');
    await trayManager.setToolTip('Passnagement');
    final menu = Menu(
      items: [
        MenuItem(key: 'show', label: 'Show'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: 'Exit'),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  void onWindowClose() async {
    if (PreferenceService.closeToTray) {
      await windowManager.hide();
    } else {
      await trayManager.destroy();
      await windowManager.destroy();
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show') {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'exit') {
      await trayManager.destroy();
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passnagement',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF5B5BD6)),
        useMaterial3: true,
      ),
      home: widget.boxReady
          ? const HomePage(title: 'Passnagement')
          : const SetupPage(),
    );
  }
}
