import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:arcade_manager/main.dart' as app;

// Comprehensive bidirectional sync test
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bidirectional Real-time Sync Tests', () {
    late FirebaseFirestore firestore;
    late String testStoreCode;

    setUp(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCvB9azStlcC_af6iZSC8uH9eeJgfqGoNI",
          authDomain: "playcontrol-53ec1.firebaseapp.com",
          projectId: "playcontrol-53ec1",
          storageBucket: "playcontrol-53ec1.firebasestorage.app",
          messagingSenderId: "624369480168",
          appId: "1:624369480168:web:eb31a36bfe9070763cf45d",
        ),
      );
      
      firestore = FirebaseFirestore.instance;
      testStoreCode = 'TEST_SYNC_${DateTime.now().millisecondsSinceEpoch}';
    });

    test('Owner and Worker can see same devices in real-time', () async {
      // 1. Create a test device
      final deviceRef = firestore
          .collection('stores')
          .doc(testStoreCode)
          .collection('devices')
          .doc('test_device_1');
      
      await deviceRef.set({
        'name': 'Test Device 1',
        'singleRate': 40.0,
        'multiRate': 70.0,
        'matchSingleRate': 5.0,
        'matchMultiRate': 8.0,
        'isBusy': false,
      });

      // 2. Start a session from Owner perspective
      await deviceRef.update({
        'session': {
          'startedAt': DateTime.now().toIso8601String(),
          'mode': 'single',
          'customer': 'Test Customer',
          'customDurationMinutes': null,
          'orders': [],
        },
        'isBusy': true,
      });

      // 3. Verify Worker can see the session
      final deviceSnapshot = await deviceRef.get();
      final deviceData = deviceSnapshot.data();
      
      expect(deviceData, isNotNull);
      expect(deviceData!['isBusy'], isTrue);
      expect(deviceData['session'], isNotNull);
      
      // 4. End session from Worker perspective
      await deviceRef.update({
        'session': FieldValue.delete(),
        'isBusy': false,
      });

      // 5. Verify Owner can see the session ended
      final finalSnapshot = await deviceRef.get();
      final finalData = finalSnapshot.data();
      
      expect(finalData, isNotNull);
      expect(finalData!['isBusy'], isFalse);
      expect(finalData['session'], isNull);
      
      // Cleanup
      await deviceRef.delete();
    });

    test('Owner and Worker can see same invoices in real-time', () async {
      // 1. Create an invoice from Worker
      final invoiceRef = firestore
          .collection('stores')
          .doc(testStoreCode)
          .collection('invoices')
          .doc('test_invoice_1');
      
      final testInvoice = {
        'id': 'test_invoice_1',
        'deviceName': 'Test Device 1',
        'customer': 'Test Customer',
        'from': DateTime.now().toIso8601String(),
        'to': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'billedMinutes': 60,
        'timeCost': 40.0,
        'cafeCost': 0.0,
        'discount': 0.0,
        'total': 40.0,
        'staffName': 'Test Worker',
        'mode': 'single',
        'cafeLines': [],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'Test Worker',
      };
      
      await invoiceRef.set(testInvoice);

      // 2. Verify Owner can see the invoice
      final invoiceSnapshot = await invoiceRef.get();
      final invoiceData = invoiceSnapshot.data();
      
      expect(invoiceData, isNotNull);
      expect(invoiceData!['createdBy'], 'Test Worker');
      expect(invoiceData['total'], 40.0);
      
      // 3. Create another invoice from Owner
      final ownerInvoiceRef = firestore
          .collection('stores')
          .doc(testStoreCode)
          .collection('invoices')
          .doc('test_invoice_2');
      
      final ownerInvoice = {
        'id': 'test_invoice_2',
        'deviceName': 'Test Device 2',
        'customer': 'Test Customer 2',
        'from': DateTime.now().toIso8601String(),
        'to': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        'billedMinutes': 120,
        'timeCost': 80.0,
        'cafeCost': 20.0,
        'discount': 0.0,
        'total': 100.0,
        'staffName': 'Owner',
        'mode': 'multi',
        'cafeLines': [],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'Owner',
      };
      
      await ownerInvoiceRef.set(ownerInvoice);

      // 4. Verify Worker can see both invoices
      final allInvoices = await firestore
          .collection('stores')
          .doc(testStoreCode)
          .collection('invoices')
          .get();
      
      expect(allInvoices.docs.length, 2);
      
      // Verify both invoices are visible regardless of who created them
      final invoiceIds = allInvoices.docs.map((doc) => doc.id).toSet();
      expect(invoiceIds, contains('test_invoice_1'));
      expect(invoiceIds, contains('test_invoice_2'));
      
      // Cleanup
      await invoiceRef.delete();
      await ownerInvoiceRef.delete();
    });

    test('Real-time session sync between Owner and Worker', () async {
      // 1. Set up device
      final deviceRef = firestore
          .collection('stores')
          .doc(testStoreCode)
          .collection('devices')
          .doc('sync_test_device');
      
      await deviceRef.set({
        'name': 'Sync Test Device',
        'singleRate': 40.0,
        'multiRate': 70.0,
        'matchSingleRate': 5.0,
        'matchMultiRate': 8.0,
        'isBusy': false,
      });

      // 2. Create real-time listener (simulating Owner)
      final ownerSessionUpdates = <Map<String, dynamic>>[];
      final ownerSubscription = deviceRef.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          ownerSessionUpdates.add(snapshot.data()!);
        }
      });

      // 3. Start session from Worker
      await Future.delayed(const Duration(milliseconds: 100));
      await deviceRef.update({
        'session': {
          'startedAt': DateTime.now().toIso8601String(),
          'mode': 'single',
          'customer': 'Worker Customer',
          'customDurationMinutes': null,
          'orders': [],
        },
        'isBusy': true,
      });

      // 4. Wait for Owner to receive update
      await Future.delayed(const Duration(seconds: 2));
      
      // 5. Verify Owner received the session update
      expect(ownerSessionUpdates.length, greaterThan(0));
      final lastOwnerUpdate = ownerSessionUpdates.last;
      expect(lastOwnerUpdate['isBusy'], isTrue);
      expect(lastOwnerUpdate['session'], isNotNull);

      // 6. End session from Owner
      await deviceRef.update({
        'session': FieldValue.delete(),
        'isBusy': false,
      });

      // 7. Wait for Worker to receive update (simulated by checking Firestore)
      await Future.delayed(const Duration(seconds: 2));
      
      // 8. Verify session ended in Firestore
      final finalSnapshot = await deviceRef.get();
      expect(finalSnapshot.data()!['isBusy'], isFalse);
      expect(finalSnapshot.data()!['session'], isNull);

      // Cleanup
      await ownerSubscription.cancel();
      await deviceRef.delete();
    });

    tearDown(() async {
      // Cleanup test data
      final storeRef = firestore.collection('stores').doc(testStoreCode);
      final devices = await storeRef.collection('devices').get();
      for (final doc in devices.docs) {
        await doc.reference.delete();
      }
      final invoices = await storeRef.collection('invoices').get();
      for (final doc in invoices.docs) {
        await doc.reference.delete();
      }
    });
  });
}