import 'package:cloud_firestore/cloud_firestore.dart';

class Universidad {
	final String id;
	final String nit;
	final String nombre;
	final String direccion;
	final String telefono;
	final String paginaWeb;

	const Universidad({
		required this.id,
		required this.nit,
		required this.nombre,
		required this.direccion,
		required this.telefono,
		required this.paginaWeb,
	});

	factory Universidad.fromFirestore(DocumentSnapshot doc) {
		final data = doc.data() as Map<String, dynamic>;
		return Universidad(
			id: doc.id,
			nit: data['nit'] ?? '',
			nombre: data['nombre'] ?? '',
			direccion: data['direccion'] ?? '',
			telefono: data['telefono'] ?? '',
			paginaWeb: data['pagina_web'] ?? '',
		);
	}

	Map<String, dynamic> toFirestore() {
		return {
			'nit': nit,
			'nombre': nombre,
			'direccion': direccion,
			'telefono': telefono,
			'pagina_web': paginaWeb,
		};
	}

	Universidad copyWith({
		String? id,
		String? nit,
		String? nombre,
		String? direccion,
		String? telefono,
		String? paginaWeb,
	}) {
		return Universidad(
			id: id ?? this.id,
			nit: nit ?? this.nit,
			nombre: nombre ?? this.nombre,
			direccion: direccion ?? this.direccion,
			telefono: telefono ?? this.telefono,
			paginaWeb: paginaWeb ?? this.paginaWeb,
		);
	}

	static bool isValidUrl(String url) {
		final uri = Uri.tryParse(url);
		return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
	}

	List<String> validate() {
		final errors = <String>[];

		if (nit.trim().isEmpty) errors.add('El NIT es obligatorio');
		if (nombre.trim().isEmpty) errors.add('El nombre es obligatorio');
		if (direccion.trim().isEmpty) errors.add('La direccion es obligatoria');
		if (telefono.trim().isEmpty) errors.add('El telefono es obligatorio');
		if (paginaWeb.trim().isEmpty) {
			errors.add('La pagina web es obligatoria');
		} else if (!isValidUrl(paginaWeb)) {
			errors.add('La pagina web debe ser una URL valida (http:// o https://)');
		}

		return errors;
	}
}
