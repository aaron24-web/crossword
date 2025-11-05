import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database_service.dart';
import '../model.dart';
import '../providers.dart';
import '../supabase_service.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final appMode = ref.watch(appModeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Azul oscuro
              Color(0xFF2563EB), // Azul medio
              Color(0xFF3B82F6), // Azul claro
              Color(0xFF60A5FA), // Azul muy claro
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¡Bienvenido!',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Ingresa tu nombre para empezar',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        Player? player;
                        final prefs = await SharedPreferences.getInstance();

                        if (appMode == AppMode.online) {
                          final dbService = DatabaseService(SupabaseService.client);
                          try {
                            player = await dbService.getPlayerByName(_nameController.text);
                            if (player == null) {
                              player = await dbService.addPlayer(_nameController.text);
                            }
                            await prefs.setInt('player_id', player.id);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error de conexión: No se pudo conectar al servidor. Intenta de nuevo más tarde.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            debugPrint('Error during online login/registration: $e');
                            return; // Stop execution if online login fails
                          }
                        } else { // AppMode.offline
                          // Create a local/guest player
                          // Using a negative ID to signify a local player, or a UUID
                          // For simplicity, let's use a fixed negative ID for now.
                          // In a real app, you might want a more robust local ID generation.
                          player = Player((b) => b
                            ..id = -1 // Special ID for local player
                            ..name = _nameController.text);
                          await prefs.setInt('player_id', player.id);
                          await prefs.setString('player_name', player.name); // Save name for local player
                        }

                        if (player != null) {
                          ref.read(playerProvider.notifier).state = player;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('JUGAR'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Modo Offline',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Switch(
                        value: appMode == AppMode.offline,
                        onChanged: (value) {
                          ref.read(appModeProvider.notifier).state = value ? AppMode.offline : AppMode.online;
                        },
                        activeColor: Colors.white,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.5),
                      ),
                    ],
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
