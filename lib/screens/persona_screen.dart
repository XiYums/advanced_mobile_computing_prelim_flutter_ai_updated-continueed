import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../design_system.dart';
import '../models/persona.dart';
import '../models/expert.dart';
import '../providers/persona_provider.dart';

class PersonaScreen extends StatefulWidget {
  const PersonaScreen({super.key});

  @override
  State<PersonaScreen> createState() => _PersonaScreenState();
}

class _PersonaScreenState extends State<PersonaScreen> {
  static const _iconOptions = [
    Icons.person,
    Icons.school,
    Icons.psychology,
    Icons.music_note,
    Icons.fitness_center,
    Icons.create,
    Icons.palette,
    Icons.sports,
    Icons.restaurant,
    Icons.business,
  ];

  void _showEditDialog({Persona? p}) {
    final nameController = TextEditingController(text: p?.name ?? '');
    final promptController = TextEditingController(text: p?.prompt ?? '');
    late int selectedIcon = p?.iconCodePoint ?? _iconOptions.first.codePoint;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(p == null ? 'Create Persona' : 'Edit Persona'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 16),
                TextField(
                  controller: promptController,
                  decoration: const InputDecoration(labelText: 'System Prompt'),
                  maxLines: 6,
                ),
                const SizedBox(height: 16),
                Text('Choose an icon:', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconOptions.map((icon) {
                    final isSelected = selectedIcon == icon.codePoint;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon.codePoint),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.muted,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final prompt = promptController.text.trim();
                if (name.isEmpty || prompt.isEmpty) return;
                final provider = Provider.of<PersonaProvider>(context, listen: false);
                if (p == null) {
                  await provider.addPersona(name, prompt, iconCodePoint: selectedIcon);
                } else {
                  await provider.updatePersona(Persona(id: p.id, name: name, prompt: prompt, iconCodePoint: selectedIcon));
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Personas', style: AppTextStyles.h2),
        actions: [
          IconButton(onPressed: () => _showEditDialog(), icon: const Icon(Icons.add)),
        ],
      ),
      body: Consumer<PersonaProvider>(builder: (context, provider, child) {
        final list = provider.personas;
        if (list.isEmpty) {
          return Center(
            child: Text('No personas yet. Tap + to create one.', style: AppTextStyles.body),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final p = list[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(IconData(p.iconCodePoint, fontFamily: 'MaterialIcons'))),
                title: Text(p.name, style: AppTextStyles.bodyLarge),
                subtitle: Text(
                  p.prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      _showEditDialog(p: p);
                    } else if (v == 'delete') {
                      await Provider.of<PersonaProvider>(context, listen: false).removePersona(p.id);
                    } else if (v == 'use') {
                      // create an Expert and route to chat with systemPrompt
                      final expert = Expert(name: p.name, icon: IconData(p.iconCodePoint, fontFamily: 'MaterialIcons'));
                      context.push('/chat', extra: {'expert': expert, 'systemPrompt': p.prompt});
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'use', child: Text('Use Persona')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
