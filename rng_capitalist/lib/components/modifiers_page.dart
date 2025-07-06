// lib/components/modifiers_page.dart
import 'package:flutter/material.dart';
import '../models/dice_modifier.dart';

class ModifiersPage extends StatefulWidget {
  final List<DiceModifier> userModifiers;
  final Function(DiceModifier) onToggleModifier;
  final Function(DiceModifier) onAddModifier;
  final Function(String) onDeleteModifier;

  const ModifiersPage({
    Key? key,
    required this.userModifiers,
    required this.onToggleModifier,
    required this.onAddModifier,
    required this.onDeleteModifier,
  }) : super(key: key);

  @override
  State<ModifiersPage> createState() => _ModifiersPageState();
}

class _ModifiersPageState extends State<ModifiersPage> {
  late List<DiceModifier> allModifiers;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadModifiers();
  }

  void _loadModifiers() {
    // Get preset modifiers
    final presetModifiers = DiceModifier.getPresetModifiers();
    
    // Merge with user modifiers, preserving unlock/active states
    allModifiers = presetModifiers.map((preset) {
      final userMod = widget.userModifiers.firstWhere(
        (u) => u.id == preset.id,
        orElse: () => preset,
      );
      return preset.copyWith(
        isActive: userMod.isActive,
        isUnlocked: userMod.isUnlocked,
      );
    }).toList();
    
    // Add any custom user modifiers not in presets
    final customModifiers = widget.userModifiers
        .where((u) => !presetModifiers.any((p) => p.id == u.id))
        .toList();
    allModifiers.addAll(customModifiers);
  }

  List<DiceModifier> get filteredModifiers {
    switch (selectedFilter) {
      case 'Active':
        return allModifiers.where((m) => m.isActive).toList();
      case 'Unlocked':
        return allModifiers.where((m) => m.isUnlocked).toList();
      case 'Locked':
        return allModifiers.where((m) => !m.isUnlocked).toList();
      default:
        return allModifiers;
    }
  }

  @override
  Widget build(BuildContext context) {
    final modifiersByType = <ModifierType, List<DiceModifier>>{};
    for (var mod in filteredModifiers) {
      modifiersByType.putIfAbsent(mod.type, () => []).add(mod);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Dice Modifiers',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF323130),
                ),
              ),
              const Spacer(),
              // Filter chips
              Wrap(
                spacing: 8,
                children: ['All', 'Active', 'Unlocked', 'Locked'].map((filter) {
                  return FilterChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.purple[100],
                    checkmarkColor: Colors.purple[700],
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock modifiers by completing challenges!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Modifiers by type
          ...modifiersByType.entries.map((entry) {
            final type = entry.key;
            final modifiers = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        color: type.color,
                        margin: const EdgeInsets.only(right: 12),
                      ),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: type.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...modifiers.map((modifier) {
                    final isPreset = DiceModifier.getPresetModifiers()
                        .any((p) => p.id == modifier.id);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: modifier.isActive ? 4 : 1,
                      color: modifier.isActive 
                          ? type.color.withOpacity(0.1)
                          : modifier.isUnlocked 
                              ? null 
                              : Colors.grey[100],
                      child: Opacity(
                        opacity: modifier.isUnlocked ? 1.0 : 0.6,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: modifier.isUnlocked
                                  ? (modifier.isActive ? type.color : Colors.grey[300])
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              modifier.isUnlocked ? modifier.icon : Icons.lock,
                              color: modifier.isUnlocked
                                  ? (modifier.isActive ? Colors.white : Colors.grey[600])
                                  : Colors.grey[600],
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                modifier.name,
                                style: TextStyle(
                                  fontWeight: modifier.isActive 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  decoration: modifier.isUnlocked 
                                      ? null 
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              if (!modifier.isUnlocked && modifier.unlockCondition != null)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'LOCKED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(modifier.description),
                              if (!modifier.isUnlocked && modifier.unlockCondition != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '🔓 ${modifier.unlockCondition}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: modifier.value >= 0
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  modifier.value >= 0
                                      ? '+${modifier.value}'
                                      : modifier.value.toString(),
                                  style: TextStyle(
                                    color: modifier.value >= 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (modifier.isUnlocked)
                                Switch(
                                  value: modifier.isActive,
                                  onChanged: (value) {
                                    widget.onToggleModifier(
                                      modifier.copyWith(isActive: value)
                                    );
                                  },
                                )
                              else
                                const SizedBox(width: 52), // Space for alignment
                              if (!isPreset)
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => widget.onDeleteModifier(modifier.id),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),
          
          // Add custom modifier button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Custom Modifiers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddModifierDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Custom'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your own modifiers for special situations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModifierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final valueController = TextEditingController();
    IconData selectedIcon = Icons.star;
    ModifierType selectedType = ModifierType.general;
    
    // Capture the callback from widget
    final onAddModifier = widget.onAddModifier;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Modifier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Coffee Boost',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Caffeinated and ready to spend',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                decoration: const InputDecoration(
                  labelText: 'Modifier Value',
                  hintText: 'e.g., +2 or -1',
                  helperText: 'Range: -10 to +10',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ModifierType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: ModifierType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: type.color,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final value = int.tryParse(valueController.text) ?? 0;
              
              if (name.isNotEmpty && value >= -10 && value <= 10) {
                onAddModifier(DiceModifier(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  description: description.isEmpty ? 'Custom modifier' : description,
                  value: value.clamp(-10, 10),
                  icon: selectedIcon,
                  type: selectedType,
                  isUnlocked: true,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}