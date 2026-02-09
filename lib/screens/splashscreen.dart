import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class EnXSplashScreen extends StatefulWidget {
  const EnXSplashScreen({super.key});

  @override
  State<EnXSplashScreen> createState() => _EnXSplashScreenState();
}

class _EnXSplashScreenState extends State<EnXSplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    _bootSystem();
  }

  Future<void> _bootSystem() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/into.mp3'));
    } catch (e) {
      debugPrint("Erro ao carregar áudio: $e");
    }

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showMenu = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF0A192F), 
              Color(0xFF020817), 
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                width: _showMenu ? 280 : 150,
                height: _showMenu ? 280 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64FFDA).withOpacity(0.05),
                      blurRadius: 100,
                      spreadRadius: _showMenu ? 50 : 20,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutQuart,
                      margin: EdgeInsets.only(bottom: _showMenu ? 50 : 0),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 190,
                          height: 190,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _showMenu ? 1.0 : 0.0,
                      child: _showMenu
                          ? Column(
                              children: [
                                _buildMenuButton(
                                  context,
                                  "INICIAR MINERAÇÃO", 
                                  '/initiation',
                                  const Color(0xFF1D2A4E).withOpacity(0.8),
                                ),
                                const SizedBox(height: 15),
                                _buildMenuButton(
                                  context,
                                  "CRIAR INASX",       
                                  'com.inasx.app',    
                                  Colors.transparent,
                                  showBorder: true,
                                ),
                                const SizedBox(height: 60),
                                Text(
                                  "ENX OS • MINE INASX v1.0", 
                                  style: TextStyle(
                                    color: const Color(0xFF64FFDA).withOpacity(0.2),
                                    fontSize: 7,
                                    fontFamily: 'monospace', // Atualizado
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, String route, Color bgColor, {bool showBorder = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (route == 'com.inasx.app') {
             debugPrint("Redirecionando para registro externo...");
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: showBorder ? const BorderSide(color: Color(0xFF1D2A4E)) : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'monospace', // Atualizado
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
