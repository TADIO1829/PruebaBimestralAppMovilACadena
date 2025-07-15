import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'new_visitor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final Color negroVolcan = const Color(0xFF0d0404);
  final Color marronProfundo = const Color(0xFF370b05);
  final Color naranjaFuego = const Color(0xFFe43606);
  final Color rojoVolcan = const Color(0xFFda5238);
  final Color naranjaIntenso = const Color(0xFFdc5414);

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final visitorStream = supabase.from('visitantes').stream(primaryKey: ['id']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitantes'),
        backgroundColor: naranjaFuego,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewVisitorPage()),
        ),
        backgroundColor: naranjaIntenso,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [negroVolcan, naranjaFuego.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: visitorStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }
            final visitors = snapshot.data!;
            if (visitors.isEmpty) {
              return Center(
                child: Text(
                  'No hay visitantes registrados',
                  style: TextStyle(
                    color: naranjaIntenso,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              itemCount: visitors.length,
              itemBuilder: (_, i) {
                final v = visitors[i];
                final hora = DateTime.tryParse(v['hora'] ?? '') ??
                    DateTime.now(); // formato de fecha
                final horaBonita = "${hora.day}/${hora.month} ${hora.hour}:${hora.minute.toString().padLeft(2, '0')}";
                return Card(
                  color: marronProfundo.withOpacity(0.92),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: v['foto_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              v['foto_url'],
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Icon(Icons.person, color: naranjaIntenso, size: 40),
                            ),
                          )
                        : Icon(Icons.person, color: naranjaIntenso, size: 40),
                    title: Text(
                      v['nombre'] ?? '',
                      style: TextStyle(
                        color: naranjaIntenso,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 1.1,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['motivo'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.90),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 17, color: naranjaFuego),
                            const SizedBox(width: 6),
                            Text(
                              horaBonita,
                              style: TextStyle(color: naranjaFuego.withOpacity(0.92)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
