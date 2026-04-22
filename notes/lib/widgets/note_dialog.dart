import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/note_service.dart';

class NoteDialog extends StatefulWidget {
  final Note? note;
  const NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Ubah ke tipe File? agar sinkron dengan fungsi pickImage
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Jika sedang edit (note tidak null), isi controller-nya
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      // Catatan: imageUrl dari database berbentuk String, tidak bisa langsung masuk ke File _imageFile
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      content: SingleChildScrollView( // Tambahkan ini agar tidak overflow jika keyboard muncul
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Title: ', textAlign: TextAlign.start),
            TextField(
              controller: _titleController,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('Description: '),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: null,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('Image: '),
            ),
            
            // Logika Preview Gambar
            Container(
              height: 150, // Beri tinggi agar tidak error di dalam Column
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : (widget.note?.imageUrl != null && widget.note!.imageUrl!.isNotEmpty
                      ? Image.network(widget.note!.imageUrl!, fit: BoxFit.cover)
                      : const Center(child: Text("No Image Selected"))),
            ),
            
            TextButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
          ],
        ),
      ),
      actions: [
        // Tombol Cancel
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        
        // Tombol Add atau Update
        ElevatedButton(
          onPressed: () async {
            String? imageUrl;
            
            // Jika ada file baru yang dipilih, upload dulu
            if (_imageFile != null) {
              imageUrl = await NoteService.uploadImage(_imageFile!);
            } else {
              // Jika tidak pilih baru, gunakan yang lama (jika ada)
              imageUrl = widget.note?.imageUrl;
            }

            Note note = Note(
              id: widget.note?.id,
              title: _titleController.text,
              description: _descriptionController.text,
              imageUrl: imageUrl,
              createdAt: widget.note?.createdAt,
            );

            if (widget.note == null) {
              await NoteService.addNote(note);
            } else {
              await NoteService.updateNote(note);
            }
            
            if (mounted) Navigator.of(context).pop();
          },
          child: Text(widget.note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}