import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getUserProfile();
      await userProvider.getUserAccesses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final accesses = userProvider.userAccesses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IDLink Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Perfil del usuario
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mi Perfil',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (user != null) ...[  
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(user.name),
                                subtitle: const Text('Nombre'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.email),
                                title: Text(user.email),
                                subtitle: const Text('Email'),
                              ),
                            ] else ...[  
                              const Text('No se pudo cargar la información del usuario'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Accesos del usuario
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Mis Accesos',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Compartir'),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/access_management');
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (accesses != null && accesses.isNotEmpty) ...[  
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: accesses.length,
                                itemBuilder: (context, index) {
                                  final access = accesses[index];
                                  return ListTile(
                                    title: Text(access['name'] ?? 'Acceso ${index + 1}'),
                                    subtitle: Text(access['type'] ?? 'Tipo no especificado'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        // Lógica para revocar acceso
                                        await userProvider.revokeAccess(access['id']);
                                        _loadUserData();
                                      },
                                    ),
                                  );
                                },
                              ),
                            ] else ...[  
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No tienes accesos compartidos'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Escanear QR'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/qr_scanner');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.security),
                            label: const Text('Mis Accesos'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/access_management');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}