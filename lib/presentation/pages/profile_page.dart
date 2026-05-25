import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final UserProfile profile;
  ProfileSuccess(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfilePage extends StatefulWidget {
  final AuthRepository authRepository;

  const ProfilePage({super.key, required this.authRepository});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileState _state = ProfileLoading();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _state = ProfileLoading());
    try {
      final profile = await widget.authRepository.getCurrentUser();
      if (mounted) {
        setState(() => _state = ProfileSuccess(profile));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = ProfileError(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: switch (_state) {
        ProfileLoading() => const Center(child: CircularProgressIndicator()),
        ProfileError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadProfile,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ProfileSuccess(:final profile) => _ProfileContent(profile: profile),
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  profile.image.isNotEmpty ? NetworkImage(profile.image) : null,
              child: profile.image.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              '@${profile.username}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: const Icon(Icons.shield_outlined, size: 16),
              label: Text(profile.role.toUpperCase()),
              backgroundColor: Colors.blue.shade50,
            ),
          ),
          const SizedBox(height: 24),
          _Section(title: 'Contato', children: [
            _InfoTile(icon: Icons.email_outlined, label: 'Email', value: profile.email),
            _InfoTile(icon: Icons.phone_outlined, label: 'Telefone', value: profile.phone),
          ]),
          _Section(title: 'Pessoal', children: [
            _InfoTile(icon: Icons.cake_outlined, label: 'Nascimento', value: '${profile.birthDate}  (${profile.age} anos)'),
            _InfoTile(icon: Icons.wc_outlined, label: 'Gênero', value: profile.gender),
            _InfoTile(icon: Icons.bloodtype_outlined, label: 'Tipo sanguíneo', value: profile.bloodGroup),
            _InfoTile(icon: Icons.straighten, label: 'Altura / Peso', value: '${profile.height} cm  •  ${profile.weight} kg'),
            _InfoTile(icon: Icons.remove_red_eye_outlined, label: 'Cor dos olhos', value: profile.eyeColor),
          ]),
          _Section(title: 'Endereço', children: [
            _InfoTile(
              icon: Icons.location_on_outlined,
              label: 'Cidade / País',
              value: [profile.city, profile.country]
                  .where((e) => e != null && e.isNotEmpty)
                  .join(', '),
            ),
          ]),
          _Section(title: 'Trabalho e Educação', children: [
            _InfoTile(icon: Icons.school_outlined, label: 'Universidade', value: profile.university),
            _InfoTile(icon: Icons.work_outline, label: 'Empresa', value: profile.companyName ?? '-'),
            _InfoTile(icon: Icons.badge_outlined, label: 'Cargo', value: profile.companyTitle ?? '-'),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '-' : value;
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(display, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      dense: false,
    );
  }
}
