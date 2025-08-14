import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AccessManagementScreen extends StatefulWidget {
  const AccessManagementScreen({super.key});

  @override
  State<AccessManagementScreen> createState() => _AccessManagementScreenState();
}

class _AccessManagementScreenState extends State<AccessManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Controladores para el formulario de compartir acceso
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _selectedAccessType = 'Lectura';
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 7));
  
  final List<String> _accessTypes = ['Lectura', 'Escritura', 'Administrador'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserAccesses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAccesses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getUserAccesses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar accesos: ${e.toString()}')),
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

  Future<void> _shareAccess() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final success = await userProvider.shareAccess(
          _emailController.text.trim(),
          _selectedAccessType,
          _expirationDate,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Acceso compartido correctamente')),
          );
          _emailController.clear();
          _tabController.animateTo(0); // Cambiar a la pestaña de accesos
          _loadUserAccesses();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al compartir acceso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
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
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final accesses = userProvider.userAccesses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Accesos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mis Accesos'),
            Tab(text: 'Compartir Acceso'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1: Mis Accesos
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadUserAccesses,
                  child: accesses != null && accesses.isNotEmpty
                      ? ListView.builder(
                          itemCount: accesses.length,
                          itemBuilder: (context, index) {
                            final access = accesses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: ListTile(
                                title: Text(access['name'] ?? 'Acceso ${index + 1}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tipo: ${access['type'] ?? 'No especificado'}'),
                                    if (access['expirationDate'] != null)
                                      Text('Expira: ${access['expirationDate']}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    // Confirmar eliminación
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar'),
                                        content: const Text('¿Estás seguro de que deseas revocar este acceso?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Revocar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true) {
                                      await userProvider.revokeAccess(access['id']);
                                      _loadUserAccesses();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No tienes accesos compartidos'),
                          ),
                        ),
                ),
          
          // Pestaña 2: Compartir Acceso
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compartir nuevo acceso',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email del destinatario',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Por favor ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de acceso',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedAccessType,
                    items: _accessTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedAccessType = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de expiración',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _shareAccess,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Compartir Acceso'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}