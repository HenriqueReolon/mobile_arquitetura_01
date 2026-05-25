import 'package:flutter/material.dart';
import '../../core/exceptions.dart';
import '../../core/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'products_page.dart';

class LoginPage extends StatefulWidget {
  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final SessionManager sessionManager;

  const LoginPage({
    super.key,
    required this.authRepository,
    required this.productRepository,
    required this.sessionManager,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProductsPage(
            repository: widget.productRepository,
            authRepository: widget.authRepository,
            sessionManager: widget.sessionManager,
          ),
        ),
      );
    } on InvalidCredentialsException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } on ServerException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro inesperado ao realizar login');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 72, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Acesse sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o usuário';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a senha';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 12),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
