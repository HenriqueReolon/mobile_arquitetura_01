import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  final ProductRepository repository;
  final Product? product;

  const ProductFormPage({
    super.key,
    required this.repository,
    this.product,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _imageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? 'smartphones');
    _imageController = TextEditingController(text: widget.product?.image ?? 'https://dummyjson.com/image/i/products/1/thumbnail.jpg');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newProduct = Product(
      id: widget.product?.id ?? 0,
      title: _titleController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      description: _descriptionController.text,
      category: _categoryController.text,
      image: _imageController.text,
    );

    try {
      if (widget.product == null) {
        await widget.repository.addProduct(newProduct);
      } else {
        await widget.repository.updateProduct(newProduct);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço (\$)', prefixText: '\$ '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        if (double.tryParse(value) == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(labelText: 'URL da Imagem'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        child: Text(isEditing ? 'Atualizar' : 'Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
