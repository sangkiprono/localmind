import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryBloc>()..add(const LoadCategories()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: false,
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(child: Text('No categories yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(category.colorValue),
                    radius: 14,
                  ),
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, category),
                  ),
                  onTap: () => _showCategoryForm(context, category: category),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _BottomNav(selectedIndex: 1),
    );
  }

  void _showCategoryForm(BuildContext context, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: _CategoryForm(category: category),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete ' + category.name + '? Reminders in this category will not be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategory(category.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CategoryForm extends StatefulWidget {
  final Category? category;
  const _CategoryForm({this.category});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  final List<Color> _colors = [
    Colors.blue, Colors.green, Colors.red, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedColor = Color(widget.category!.colorValue);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;
    if (widget.category == null) {
      context.read<CategoryBloc>().add(CreateCategory(Category(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        colorValue: _selectedColor.value,
        createdAt: DateTime.now(),
      )));
    } else {
      context.read<CategoryBloc>().add(UpdateCategory(Category(
        id: widget.category!.id,
        name: _nameController.text.trim(),
        colorValue: _selectedColor.value,
        createdAt: widget.category!.createdAt,
      )));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.category == null ? 'New Category' : 'Edit Category',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          const Text('Color'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _colors.map((color) => GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: CircleAvatar(
                backgroundColor: color,
                radius: 18,
                child: _selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  const _BottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0: Navigator.pushReplacementNamed(context, '/reminders'); break;
          case 1: break;
          case 2: Navigator.pushReplacementNamed(context, '/analytics'); break;
          case 3: Navigator.pushReplacementNamed(context, '/settings'); break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Reminders'),
        NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Analytics'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}