import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:abrigo_dos_anjos/data/services/session_storage_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

class MemorySessionStorage extends LocalStorage {
  String? value;
  bool fail = false;
  int writes = 0;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => value != null;
  @override
  Future<String?> accessToken() async => value;
  @override
  Future<void> persistSession(String data) async {
    if (fail) throw StateError('private storage');
    writes++;
    value = data;
  }

  @override
  Future<void> removePersistedSession() async {
    if (fail) throw StateError('private storage');
    value = null;
  }
}

class DelayedSessionStorage extends MemorySessionStorage {
  final started = Completer<void>(), release = Completer<void>();
  @override
  Future<void> persistSession(String value) async {
    if (value == 'refresh') {
      started.complete();
      await release.future;
    }
    await super.persistSession(value);
  }
}

class InitializationFailureStorage extends MemorySessionStorage {
  @override
  Future<void> initialize() async => throw StateError('private');
}

void main() {
  test(
    'initialization and serialized disk failures fail closed without poisoning later reads',
    () async {
      final broken = SessionStorageService(
        InitializationFailureStorage(),
        readPreference: () async => true,
        writePreference: (_) async {},
      );
      await expectLater(broken.initialize(), throwsStateError);
      expect(await broken.prepareSignIn(true), isA<Failure>());
      for (final remove in [false, true]) {
        final disk = MemorySessionStorage();
        final storage = SessionStorageService(
          disk,
          readPreference: () async => true,
          writePreference: (_) async {},
        );
        await storage.initialize();
        disk.fail = true;
        await expectLater(
          remove
              ? storage.removePersistedSession()
              : storage.persistSession('private'),
          throwsStateError,
        );
        disk.fail = false;
        expect(await storage.accessToken(), isNull);
        expect(await storage.hasAccessToken(), isFalse);
      }
    },
  );
  test(
    'new sign-in invalidates a queued older ticket before persistence',
    () async {
      final ready = Completer<bool?>();
      final storage = SessionStorageService(
        MemorySessionStorage(),
        readPreference: () => ready.future,
        writePreference: (_) async {},
      );
      final first = storage.prepareSignIn(true);
      final second = storage.prepareSignIn(false);
      ready.complete(true);
      expect(await first, isA<Failure>());
      expect(await second, isA<Success>());
    },
  );

  test(
    'unchecked choice erases previous session and ignores SDK refresh writes',
    () async {
      final disk = MemorySessionStorage()..value = 'old';
      bool? preference;
      final storage = SessionStorageService(
        disk,
        readPreference: () async => preference,
        writePreference: (v) async {
          preference = v;
        },
      );
      await storage.initialize();
      final ticket = (await storage.prepareSignIn(false) as Success<int>).value;
      expect(disk.value, isNull);
      await storage.persistSession('refresh');
      await storage.confirmSignIn(ticket, 'new');
      expect(await storage.accessToken(), isNull);
      expect(disk.value, isNull);
      expect(preference, isFalse);
    },
  );
  test(
    'checked login persists only its confirmed session and restores after recreation',
    () async {
      final disk = MemorySessionStorage();
      bool? preference;
      SessionStorageService make() => SessionStorageService(
        disk,
        readPreference: () async => preference,
        writePreference: (v) async {
          preference = v;
        },
      );
      final storage = make();
      await storage.initialize();
      final ticket = (await storage.prepareSignIn(true) as Success<int>).value;
      await storage.persistSession('unconfirmed');
      expect(disk.value, isNull);
      expect(
        await storage.confirmSignIn(ticket, 'confirmed'),
        isA<Success<Unit>>(),
      );
      final restarted = make();
      await restarted.initialize();
      expect(await restarted.hasAccessToken(), isTrue);
      expect(await restarted.accessToken(), 'confirmed');
    },
  );
  test(
    'logout invalidates pending login and preserves PKCE data outside session store',
    () async {
      final disk = MemorySessionStorage();
      final storage = SessionStorageService(
        disk,
        readPreference: () async => true,
        writePreference: (_) async {},
      );
      await storage.initialize();
      final first = (await storage.prepareSignIn(true) as Success<int>).value;
      await storage.removePersistedSession();
      expect(await storage.confirmSignIn(first, 'late'), isA<Failure<Unit>>());
      expect(disk.value, isNull);
    },
  );
  test('preference failure fails closed before authentication', () async {
    final disk = MemorySessionStorage()..value = 'old';
    final storage = SessionStorageService(
      disk,
      readPreference: () async => true,
      writePreference: (_) async => throw StateError('private'),
    );
    await storage.initialize();
    expect(await storage.prepareSignIn(true), isA<Failure<int>>());
    expect(await storage.hasAccessToken(), isFalse);
  });
  test(
    'failed durable write is not reported as successful persistent login',
    () async {
      final disk = MemorySessionStorage();
      final storage = SessionStorageService(
        disk,
        readPreference: () async => true,
        writePreference: (_) async {},
      );
      await storage.initialize();
      final ticket = (await storage.prepareSignIn(true) as Success<int>).value;
      disk.fail = true;
      expect(
        await storage.confirmSignIn(ticket, 'secret'),
        isA<Failure<Unit>>(),
      );
      expect(await storage.hasAccessToken(), isFalse);
    },
  );
  test('newer persistence choice invalidates old login receipt', () async {
    final storage = SessionStorageService(
      MemorySessionStorage(),
      readPreference: () async => true,
      writePreference: (_) async {},
    );
    await storage.initialize();
    final first = (await storage.prepareSignIn(true) as Success<int>).value;
    final second = (await storage.prepareSignIn(false) as Success<int>).value;
    expect(await storage.confirmSignIn(first, 'old'), isA<Failure<Unit>>());
    expect(
      await storage.confirmSignIn(second, 'current'),
      isA<Success<Unit>>(),
    );
    expect(await storage.hasAccessToken(), isFalse);
  });
  test('unchecked policy clears legacy token on initialization', () async {
    final disk = MemorySessionStorage()..value = 'old';
    final storage = SessionStorageService(
      disk,
      readPreference: () async => false,
      writePreference: (_) async {},
    );
    await storage.initialize();
    expect(disk.value, isNull);
    expect(await storage.hasAccessToken(), isFalse);
  });
  test('queued refresh cannot survive a newer unchecked choice', () async {
    final disk = DelayedSessionStorage();
    final storage = SessionStorageService(
      disk,
      readPreference: () async => true,
      writePreference: (_) async {},
    );
    await storage.initialize();
    final ticket = (await storage.prepareSignIn(true) as Success<int>).value;
    await storage.confirmSignIn(ticket, 'old');
    final writing = storage.persistSession('refresh');
    await disk.started.future;
    final changed = storage.prepareSignIn(false);
    await storage.persistSession('late-refresh');
    disk.release.complete();
    await writing;
    await changed;
    expect(disk.value, isNull);
    expect(await storage.hasAccessToken(), isFalse);
  });
  test(
    'session cleanup preserves the SDK PKCE verifier in native preference storage',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final previous = SharedPreferencesAsyncPlatform.instance;
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
      final pkce = SharedPreferencesGotrueAsyncStorage();
      await pkce.setItem(
        key: 'test-pkce-verifier',
        value: 'test-operation-code',
      );
      final storage = SessionStorageService.forUrl(
        Uri.parse('https://example.test'),
      );
      await storage.initialize();
      await storage.prepareSignIn(false);
      await storage.removePersistedSession();
      expect(
        await pkce.getItem(key: 'test-pkce-verifier'),
        'test-operation-code',
      );
      await pkce.removeItem(key: 'test-pkce-verifier');
    },
  );
}
