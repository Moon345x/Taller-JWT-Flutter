import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/universidad.dart';

class UniversidadService {
	UniversidadService._();
	static final UniversidadService instance = UniversidadService._();

	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	final String _collection = 'universidades';

	CollectionReference get _universidadesCollection =>
			_firestore.collection(_collection);

	Future<String> createUniversidad(Universidad universidad) async {
		try {
			final docRef =
					await _universidadesCollection.add(universidad.toFirestore());
			print('✅ Universidad creada con ID: ${docRef.id}');
			return docRef.id;
		} catch (error) {
			print('❌ Error al crear universidad: $error');
			rethrow;
		}
	}

	Stream<List<Universidad>> getUniversidades() {
		return _universidadesCollection
				.orderBy('nombre')
				.snapshots()
				.map(
					(snapshot) => snapshot.docs
							.map((doc) => Universidad.fromFirestore(doc))
							.toList(),
				)
				.catchError((error) {
					print('❌ Error en stream de universidades: $error');
					return <Universidad>[];
				});
	}

	Future<Universidad?> getUniversidadById(String id) async {
		try {
			final doc = await _universidadesCollection.doc(id).get();
			if (!doc.exists) {
				return null;
			}
			return Universidad.fromFirestore(doc);
		} catch (error) {
			print('❌ Error al obtener universidad: $error');
			return null;
		}
	}

	Future<void> updateUniversidad(String id, Universidad universidad) async {
		try {
			await _universidadesCollection.doc(id).update(universidad.toFirestore());
			print('✅ Universidad actualizada: $id');
		} catch (error) {
			print('❌ Error al actualizar universidad: $error');
			rethrow;
		}
	}

	Future<void> deleteUniversidad(String id) async {
		try {
			await _universidadesCollection.doc(id).delete();
			print('✅ Universidad eliminada: $id');
		} catch (error) {
			print('❌ Error al eliminar universidad: $error');
			rethrow;
		}
	}
}
