import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewVisitorPage extends StatefulWidget {
  const NewVisitorPage({super.key});

  @override
  State<NewVisitorPage> createState() => _NewVisitorPageState();
}

class _NewVisitorPageState extends State<NewVisitorPage> {
  final nameController = TextEditingController();
  final reasonController = TextEditingController();
  File? imageFile;
  Uint8List? compressedBytes;
  bool loading = false;

  // Paleta volcánica
  final Color negroVolcan = const Color(0xFF0d0404);
  final Color marronProfundo = const Color(0xFF370b05);
  final Color naranjaFuego = const Color(0xFFe43606);
  final Color rojoVolcan = const Color(0xFFda5238);
  final Color naranjaIntenso = const Color(0xFFdc5414);

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      imageFile = File(picked.path);

      final processed = await processImage(imageFile!);
      if (processed != null) {
        setState(() {
          compressedBytes = processed;
        });
      } else {
        setState(() {
          compressedBytes = null;
          imageFile = null;
        });
      }
    }
  }

  Future<void> pickGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);

      final processed = await processImage(imageFile!);
      if (processed != null) {
        setState(() {
          compressedBytes = processed;
        });
      } else {
        setState(() {
          compressedBytes = null;
          imageFile = null;
        });
      }
    }
  }

  Future<Uint8List?> processImage(File file) async {
    try {
      final originalBytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo leer la imagen.')),
        );
        return null;
      }

      img.Image resized = img.copyResize(
        originalImage,
        width: originalImage.width > 1024 ? 1024 : originalImage.width,
        height: originalImage.height > 1024 ? 1024 : originalImage.height,
      );

      List<int> jpgBytes = img.encodeJpg(resized, quality: 85);

      if (jpgBytes.length > 2 * 1024 * 1024) {
        jpgBytes = img.encodeJpg(resized, quality: 70);
      }

      if (jpgBytes.length > 2 * 1024 * 1024) {
        resized = img.copyResize(resized, width: 512, height: 512);
        jpgBytes = img.encodeJpg(resized, quality: 60);
      }

      if (jpgBytes.length > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La imagen es demasiado grande incluso tras comprimirse. Usa otra foto.")),
        );
        return null;
      }

      return Uint8List.fromList(jpgBytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar imagen: $e")),
      );
      return null;
    }
  }

  Future<void> saveVisitor() async {
    if (nameController.text.isEmpty || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }

    setState(() => loading = true);
    final supabase = Supabase.instance.client;

    String? imageUrl;
    if (compressedBytes != null) {
      try {
        final fileName = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('visitantes').uploadBinary(fileName, compressedBytes!);
        final publicUrl = supabase.storage.from('visitantes').getPublicUrl(fileName);
        imageUrl = publicUrl;
      } catch (e) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al subir imagen: $e")));
        return;
      }
    }

    try {
      await supabase.from('visitantes').insert({
        'nombre': nameController.text,
        'motivo': reasonController.text,
        'hora': DateTime.now().toIso8601String(),
        'foto_url': imageUrl,
      });

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar datos: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo visitante'),
        backgroundColor: naranjaFuego,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [negroVolcan, naranjaFuego],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: marronProfundo.withOpacity(0.90),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 14,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Registrar visitante",
                      style: TextStyle(
                        fontSize: 20,
                        color: naranjaFuego,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: naranjaIntenso),
                        prefixIcon: Icon(Icons.person, color: naranjaIntenso),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: rojoVolcan.withOpacity(0.38), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: naranjaFuego, width: 1.8),
                        ),
                        filled: true,
                        fillColor: negroVolcan.withOpacity(0.20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: reasonController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Motivo',
                        labelStyle: TextStyle(color: naranjaIntenso),
                        prefixIcon: Icon(Icons.info_outline, color: naranjaIntenso),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: rojoVolcan.withOpacity(0.38), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: naranjaFuego, width: 1.8),
                        ),
                        filled: true,
                        fillColor: negroVolcan.withOpacity(0.20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Botón cámara pequeño
                        IconButton(
                          icon: Icon(Icons.camera_alt, color: naranjaFuego, size: 28),
                          onPressed: pickImage,
                          tooltip: 'Tomar foto',
                          splashRadius: 22,
                        ),
                        // Botón galería pequeño
                        IconButton(
                          icon: Icon(Icons.photo_library_outlined, color: naranjaIntenso, size: 25),
                          onPressed: pickGallery,
                          tooltip: 'Elegir de galería',
                          splashRadius: 20,
                        ),
                        const SizedBox(width: 10),
                        compressedBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  compressedBytes!,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Text('No hay imagen', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 26),
                    loading
                        ? const CircularProgressIndicator(color: Colors.orange)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: saveVisitor,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: naranjaIntenso,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                elevation: 4,
                              ),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
