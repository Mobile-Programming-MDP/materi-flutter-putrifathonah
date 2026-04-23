import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/note_service.dart';
import 'package:notes/widgets/note_dialog.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return const NoteDialog();
            },
          );
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: NoteService.getNoteList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada catatan'));
        }

        final notes = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: notes.map((document) {
            return Card(
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return NoteDialog(note: document);
                    },
                  );
                },
                child: Column(
                  children: [
                    document.imageUrl != null &&
                            document.imageUrl!.isNotEmpty &&
                            Uri.tryParse(document.imageUrl!)?.hasAbsolutePath ==
                                true
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              document.imageUrl!,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: 150,
                            ),
                          )
                        : Container(),
                    ListTile(
                      title: Text(document.title),
                      subtitle: Text(document.description),
                      trailing: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Konfirmasi Hapus'),
                                content: Text(
                                  'Yakin ingin menghapus data "${document.title}"?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Hapus'),
                                    onPressed: () async {
                                      await NoteService.deleteNote(document.id!);
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.delete),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
