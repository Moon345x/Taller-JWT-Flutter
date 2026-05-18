import 'package:flutter/material.dart';

import '../models/universidad.dart';
import '../services/universidad_service.dart';

class UniversidadFormScreen extends StatefulWidget {
	const UniversidadFormScreen({super.key});

	@override
	State<UniversidadFormScreen> createState() => _UniversidadFormScreenState();
}

class _UniversidadFormScreenState extends State<UniversidadFormScreen> {
	final _formKey = GlobalKey<FormState>();

	final TextEditingController _nitController = TextEditingController();
	final TextEditingController _nombreController = TextEditingController();
	final TextEditingController _direccionController = TextEditingController();
	final TextEditingController _telefonoController = TextEditingController();
	final TextEditingController _paginaWebController = TextEditingController();

	bool _isLoading = false;

	Future<void> _saveUniversidad() async {
		if (!_formKey.currentState!.validate()) return;

		setState(() => _isLoading = true);

		try {
			final universidad = Universidad(
				id: '',
				nit: _nitController.text.trim(),
				nombre: _nombreController.text.trim(),
				direccion: _direccionController.text.trim(),
				telefono: _telefonoController.text.trim(),
				paginaWeb: _paginaWebController.text.trim(),
			);

			final errors = universidad.validate();
			if (errors.isNotEmpty) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(errors.first),
						backgroundColor: Colors.red,
					),
				);
				return;
			}

			await UniversidadService.instance.createUniversidad(universidad);

			if (!mounted) return;

			_nitController.clear();
			_nombreController.clear();
			_direccionController.clear();
			_telefonoController.clear();
			_paginaWebController.clear();

			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Universidad creada exitosamente'),
					backgroundColor: Colors.green,
				),
			);

			Navigator.pop(context);
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('Error: $e'),
					backgroundColor: Colors.red,
				),
			);
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	@override
	void dispose() {
		_nitController.dispose();
		_nombreController.dispose();
		_direccionController.dispose();
		_telefonoController.dispose();
		_paginaWebController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Nueva Universidad'),
				centerTitle: true,
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16.0),
				child: Form(
					key: _formKey,
					child: Card(
						child: Padding(
							padding: const EdgeInsets.all(16.0),
							child: Column(
								children: [
									TextFormField(
										controller: _nitController,
										decoration: const InputDecoration(
											labelText: 'NIT',
											hintText: 'Ej: 890.123.456-7',
											prefixIcon: Icon(Icons.badge),
										),
										textInputAction: TextInputAction.next,
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'El NIT es obligatorio';
											}
											return null;
										},
									),
									TextFormField(
										controller: _nombreController,
										decoration: const InputDecoration(
											labelText: 'Nombre',
											hintText: 'Ej: UCEVA',
											prefixIcon: Icon(Icons.school),
										),
										textInputAction: TextInputAction.next,
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'El nombre es obligatorio';
											}
											return null;
										},
									),
									TextFormField(
										controller: _direccionController,
										decoration: const InputDecoration(
											labelText: 'Direccion',
											hintText: 'Ej: Cra 27A #48-144',
											prefixIcon: Icon(Icons.location_on),
										),
										textInputAction: TextInputAction.next,
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'La direccion es obligatoria';
											}
											return null;
										},
									),
									TextFormField(
										controller: _telefonoController,
										decoration: const InputDecoration(
											labelText: 'Telefono',
											hintText: 'Ej: +57 602 2242202',
											prefixIcon: Icon(Icons.phone),
										),
										keyboardType: TextInputType.phone,
										textInputAction: TextInputAction.next,
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'El telefono es obligatorio';
											}
											return null;
										},
									),
									TextFormField(
										controller: _paginaWebController,
										decoration: const InputDecoration(
											labelText: 'Pagina Web',
											hintText: 'Ej: https://www.uceva.edu.co',
											prefixIcon: Icon(Icons.language),
										),
										keyboardType: TextInputType.url,
										textInputAction: TextInputAction.done,
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'La pagina web es obligatoria';
											}
											if (!Universidad.isValidUrl(value.trim())) {
												return 'La pagina web debe ser una URL valida '
														'(http:// o https://)';
											}
											return null;
										},
									),
									const SizedBox(height: 24),
									SizedBox(
										width: double.infinity,
										child: ElevatedButton(
											onPressed: _isLoading ? null : _saveUniversidad,
											style: ElevatedButton.styleFrom(
												padding: const EdgeInsets.symmetric(vertical: 16),
											),
											child: _isLoading
													? const SizedBox(
															height: 20,
															width: 20,
															child: CircularProgressIndicator(
																color: Colors.white,
																strokeWidth: 2,
															),
														)
													: const Text('Guardar Universidad'),
										),
									),
								],
							),
						),
					),
				),
			),
		);
	}
}
