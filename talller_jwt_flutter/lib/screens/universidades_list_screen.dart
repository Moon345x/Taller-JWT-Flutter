import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/universidad.dart';
import '../services/universidad_service.dart';
import 'universidad_form_screen.dart';

class UniversidadesListScreen extends StatefulWidget {
	const UniversidadesListScreen({super.key});

	@override
	State<UniversidadesListScreen> createState() => _UniversidadesListScreenState();
}

class _UniversidadesListScreenState extends State<UniversidadesListScreen> {
	Future<void> _launchUrl(String urlString, BuildContext context) async {
		try {
			final url = Uri.parse(urlString);
			if (await canLaunchUrl(url)) {
				await launchUrl(url, mode: LaunchMode.externalApplication);
			} else {
				if (!context.mounted) return;
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text('No se puede abrir la URL: $urlString'),
						backgroundColor: Colors.orange,
					),
				);
			}
		} catch (e) {
			if (!context.mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('Error al abrir URL: $e'),
					backgroundColor: Colors.red,
				),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Universidades'),
				centerTitle: true,
				backgroundColor: Theme.of(context).colorScheme.primaryContainer,
			),
			body: StreamBuilder<List<Universidad>>(
				stream: UniversidadService.instance.getUniversidades(),
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									CircularProgressIndicator(),
									SizedBox(height: 16),
									Text('Cargando universidades...'),
								],
							),
						);
					}

					if (snapshot.hasError) {
						return Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									const Icon(Icons.error_outline, size: 64, color: Colors.red),
									const SizedBox(height: 16),
									const Text('Error al cargar datos'),
									Text(
										snapshot.error.toString(),
										style: const TextStyle(fontSize: 12),
									),
									const SizedBox(height: 16),
									ElevatedButton.icon(
										onPressed: () => setState(() {}),
										icon: const Icon(Icons.refresh),
										label: const Text('Reintentar'),
									),
								],
							),
						);
					}

					final universidades = snapshot.data ?? [];
					if (universidades.isEmpty) {
						return const Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(Icons.school_outlined, size: 80, color: Colors.grey),
									SizedBox(height: 16),
									Text(
										'No hay universidades registradas',
										style: TextStyle(fontSize: 18),
									),
									SizedBox(height: 8),
									Text(
										'Presiona el boton + para agregar una',
										style: TextStyle(color: Colors.grey),
									),
								],
							),
						);
					}

					return RefreshIndicator(
						onRefresh: () async => setState(() {}),
						child: ListView.builder(
							padding: const EdgeInsets.all(8),
							itemCount: universidades.length,
							itemBuilder: (context, index) {
								final universidad = universidades[index];
								return Card(
									margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
									elevation: 2,
									child: ListTile(
										contentPadding: const EdgeInsets.all(16),
										leading: CircleAvatar(
											backgroundColor: Theme.of(context).colorScheme.primary,
											child: const Icon(Icons.school, color: Colors.white),
										),
										title: Text(
											universidad.nombre,
											style: const TextStyle(
												fontWeight: FontWeight.bold,
												fontSize: 16,
											),
										),
										subtitle: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												const SizedBox(height: 8),
												Row(
													children: [
														const Icon(Icons.badge, size: 16, color: Colors.grey),
														const SizedBox(width: 4),
														Text('NIT: ${universidad.nit}'),
													],
												),
												const SizedBox(height: 4),
												Row(
													children: [
														const Icon(
															Icons.location_on,
															size: 16,
															color: Colors.grey,
														),
														const SizedBox(width: 4),
														Expanded(child: Text(universidad.direccion)),
													],
												),
												const SizedBox(height: 4),
												Row(
													children: [
														const Icon(Icons.phone, size: 16, color: Colors.grey),
														const SizedBox(width: 4),
														Text(universidad.telefono),
													],
												),
											],
										),
										trailing: IconButton(
											icon: Icon(
												Icons.language,
												color: Theme.of(context).colorScheme.primary,
											),
											tooltip: 'Abrir pagina web',
											onPressed: () =>
													_launchUrl(universidad.paginaWeb, context),
										),
									),
								);
							},
						),
					);
				},
			),
			floatingActionButton: FloatingActionButton(
				tooltip: 'Agregar universidad',
				onPressed: () async {
					await Navigator.push(
						context,
						MaterialPageRoute(
							builder: (context) => const UniversidadFormScreen(),
						),
					);
				},
				child: const Icon(Icons.add),
			),
		);
	}
}
