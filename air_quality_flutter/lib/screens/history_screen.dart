import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Día'),
            Tab(text: 'Semana'),
            Tab(text: 'Mes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Por ahora, las tres pestañas mostrarán el mismo contenido.
          _buildHistoryList(),
          _buildHistoryList(),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Usamos datos de ejemplo para construir la UI.
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(context, 'Ubicaciones Guardadas'),
        _buildLocationTile(
          context,
          title: 'Centro de la Ciudad',
          date: '12 de mayo de 2024',
        ),
        _buildLocationTile(
          context,
          title: 'Parque Central',
          date: '12 de mayo de 2024',
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Ubicaciones Visitadas'),
        _buildLocationTile(
          context,
          title: 'Cafetería Local',
          date: '12 de mayo de 2024',
        ),
        _buildLocationTile(
          context,
          title: 'Biblioteca',
          date: '12 de mayo de 2024',
        ),
      ],
    );
  }

  // Widget reutilizable para el encabezado de cada sección
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget reutilizable para cada elemento de la lista de ubicaciones
  Widget _buildLocationTile(BuildContext context,
      {required String title, required String date}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(Icons.location_on,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        title: Text(title),
        subtitle: Text(date, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Lógica para ver el detalle del historial (se implementará después)
        },
      ),
    );
  }
}
