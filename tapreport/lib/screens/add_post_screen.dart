import 'dart:convert';

import 'package:tapreport/models/post.dart';
import 'package:tapreport/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descriptionController =
      TextEditingController();

  String? _base64Image;
  String? _latitude;
  String? _longitude;
  String? _category;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  bool _isGenerating = false;

  List<String> get categories {
    return [
      'Jalan Rusak',
      'Lampu Jalan Mati',
      'Lawan Arah',
      'Merokok di Jalan',
      'Tidak Pakai Helm',
    ];
  }

  // PICK IMAGE
  Future<void> pickImageAndConvert() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  // GET LOCATION
  Future<void> _getLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Layanan lokasi dinonaktifkan."),
          ),
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Izin lokasi ditolak."),
            ),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      debugPrint("Location Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil lokasi."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  // CATEGORY
  void _showCategorySelect() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: categories.map((cat) {
            return ListTile(
              title: Text(cat),
              onTap: () {
                setState(() {
                  _category = cat;
                });

                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // IMAGE PREVIEW
  Widget _buildImagePreview() {
    if (_base64Image == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Text('Belum ada gambar dipilih'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        base64Decode(_base64Image!),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // LOCATION INFO
  Widget _buildLocationInfo() {
    if (_latitude == null || _longitude == null) {
      return const Text("Lokasi belum diambil");
    }

    return Text(
      "Lat: $_latitude\nLng: $_longitude",
      textAlign: TextAlign.center,
    );
  }

  // GENERATE DESCRIPTION WITH AI
  Future<void> _generateDescriptionWithAI() async {
    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih gambar terlebih dahulu"),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      const apiKey = 'YOUR_API_KEY';

      final url = Uri.parse(
        // disini pake api key sendiri ya, jangan lupa aktifin billing di google cloud console
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final body = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
Analisa gambar ini.

Tentukan kategori utama dari daftar berikut:
- Jalan Rusak
- Lampu Jalan Mati
- Lawan Arah
- Merokok di Jalan
- Tidak Pakai Helm

Lalu buat deskripsi singkat laporan.

Format jawaban:
Kategori: ...
Deskripsi: ...
"""
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": _base64Image,
                }
              }
            ]
          }
        ]
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final text = data['candidates'][0]['content']['parts'][0]
            ['text'];

        debugPrint(text);

        final lines = text.split('\n');

        String? category;
        String? description;

        for (var line in lines) {
          if (line.toLowerCase().contains('kategori')) {
            category =
                line.replaceAll('Kategori:', '').trim();
          }

          if (line.toLowerCase().contains('deskripsi')) {
            description =
                line.replaceAll('Deskripsi:', '').trim();
          }
        }

        setState(() {
          if (category != null && category.isNotEmpty) {
            _category = category;
          }

          if (description != null &&
              description.isNotEmpty) {
            _descriptionController.text = description;
          }
        });
      } else {
        debugPrint(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal generate deskripsi"),
          ),
        );
      }
    } catch (e) {
      debugPrint("AI Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error AI: $e"),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  // SUBMIT POST
  Future<void> _submitPost() async {
    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih gambar terlebih dahulu."),
        ),
      );
      return;
    }

    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih kategori terlebih dahulu."),
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masukkan deskripsi."),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_latitude == null || _longitude == null) {
        await _getLocation();
      }

      final userId =
          FirebaseAuth.instance.currentUser?.uid;

      final fullName =
          FirebaseAuth.instance.currentUser?.displayName;

      await PostService.addPost(
        Post(
          image: _base64Image,
          description: _descriptionController.text,
          category: _category,
          latitude: _latitude,
          longitude: _longitude,
          userId: userId,
          fullName: fullName,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Posting berhasil disimpan"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Posting gagal: $e"),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Post"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed:
                  _isSubmitting ? null : pickImageAndConvert,
              child: const Text("Pick Image"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _isGenerating
                  ? null
                  : _generateDescriptionWithAI,
              child: Text(
                _isGenerating
                    ? "Generating..."
                    : "Generate AI Description",
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed:
                  _isSubmitting ? null : _showCategorySelect,
              child: const Text("Select Category"),
            ),

            const SizedBox(height: 8),

            Text(
              _category ?? 'Belum memilih kategori',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed:
                  (_isSubmitting || _isGettingLocation)
                      ? null
                      : _getLocation,
              child: Text(
                _isGettingLocation
                    ? 'Mengambil Lokasi...'
                    : 'Get Location',
              ),
            ),

            const SizedBox(height: 8),

            _buildLocationInfo(),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed:
                  _isSubmitting ? null : _submitPost,
              child: Text(
                _isSubmitting
                    ? 'Submitting...'
                    : 'Submit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}