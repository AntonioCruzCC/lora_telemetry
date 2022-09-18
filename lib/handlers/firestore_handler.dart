import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lora_telemetry/controllers/district.dart';
import 'package:lora_telemetry/controllers/power_meter.dart';

import 'filter_handler.dart';

class FirestoreHandler {
  static final FirestoreHandler _firestoreSingleton =
      FirestoreHandler._internal();

  late FirebaseFirestore db;
  late CollectionReference<PowerMeter> powerMetersRef;
  late CollectionReference<District> districtsRef;

  factory FirestoreHandler() {
    return _firestoreSingleton;
  }

  FirestoreHandler._internal() {
    db = FirebaseFirestore.instance;

    powerMetersRef = db.collection('PowerMeters').withConverter<PowerMeter>(
          fromFirestore: (snapshot, _) =>
              PowerMeter.fromJson(snapshot.id, snapshot.data()!),
          toFirestore: (powerMeter, _) => powerMeter.toJson(),
        );

    districtsRef = db.collection('Districts').withConverter<District>(
        fromFirestore: (snapshot, options) =>
            District.fromJson(snapshot.id, snapshot.data()!),
        toFirestore: (district, _) => district.toJson());
  }

  Future<Set<Marker>> getFilteredMeters() async {
    QuerySnapshot<PowerMeter> querySnapshot = await powerMetersRef
        .where(
          'District',
          isEqualTo: db
              .collection('Districts')
              .doc(FilterHandler.selectedDistrict?.id),
        )
        .get();
    return querySnapshot.docs
        .map(
          (QueryDocumentSnapshot<PowerMeter> powerMeterDoc) => Marker(
            markerId: MarkerId(powerMeterDoc.data().id),
            position: powerMeterDoc.data().geolocation,
          ),
        )
        .toSet();
  }

  Future<List<District>> getAllDistricts() async {
    QuerySnapshot<District> querySnapshot = await districtsRef.get();
    return querySnapshot.docs
        .map(
            (QueryDocumentSnapshot<District> districtDoc) => districtDoc.data())
        .toList();
  }
}
