import 'package:flutter/material.dart';
import 'package:smart_cabinet/screens/auth_screen.dart';
import 'package:smart_cabinet/model/app_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your account and preferences',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 28),
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'My Account',
                subtitle: 'Admin@gmail.com',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Manage Notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.phone_android_outlined,
                label: 'General',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeneralScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.help_outline,
                label: 'Help & FAQ',
                onTap: () {},
              ),
              const SizedBox(height: 36),
              Center(
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: Color(0xFF8EC5D6)),
                  ),
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Color(0xFF8EC5D6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AppData.clearAll(); // clear in-memory data
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8EC5D6),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Settings Tile ───────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F8),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: const Color(0xFF8EC5D6), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Profile Screen ───────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Admin chow');
  final _phoneCtrl = TextEditingController(text: '011-23456783');
  final _emailCtrl = TextEditingController(text: 'Admin@gmail.com');
  final _passCtrl = TextEditingController(text: '12345678');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFB),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: const Color(0xFF8EC5D6),
            ),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile saved'),
                    backgroundColor: Color(0xFF8EC5D6),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 54, color: Colors.grey[400]),
            ),
            const SizedBox(height: 30),
            _ProfileField(
              label: 'Name',
              controller: _nameCtrl,
              icon: Icons.person_outline,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _ProfileField(
              label: 'Phone Number',
              controller: _phoneCtrl,
              icon: Icons.phone_outlined,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _ProfileField(
              label: 'Email',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _ProfileField(
              label: 'Password',
              controller: _passCtrl,
              icon: Icons.lock_outline,
              obscure: true,
              enabled: _isEditing,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final bool enabled;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? const Color(0xFF8EC5D6) : Colors.transparent,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            readOnly: !enabled,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 18,
                color: enabled ? const Color(0xFF8EC5D6) : Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Notifications Screen ───────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _push = true;
  bool _expiry = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFB),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.notifications_outlined,
              size: 52,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 6),
            const Text(
              'Notification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            _ToggleTile(
              label: 'Push Notification',
              value: _push,
              onChanged: (v) => setState(() => _push = v),
            ),
            const SizedBox(height: 12),
            _ToggleTile(
              label: 'Expiry Alerts',
              value: _expiry,
              onChanged: (v) => setState(() => _expiry = v),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF8EC5D6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── General Screen ───────────────────────────

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});
  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  String? _language;
  String? _appearance;
  String? _security;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFB),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.phone_android_outlined,
              size: 52,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 6),
            const Text(
              'General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            _DropdownTile(
              label: 'Language',
              value: _language,
              options: ['English', 'Malay', 'Chinese', 'Tamil'],
              onChanged: (v) => setState(() => _language = v),
            ),
            const SizedBox(height: 12),
            _DropdownTile(
              label: 'Appearance',
              value: _appearance,
              options: ['System Default', 'Light', 'Dark'],
              onChanged: (v) => setState(() => _appearance = v),
            ),
            const SizedBox(height: 12),
            _DropdownTile(
              label: 'Security & Privacy',
              value: _security,
              options: ['Biometric', 'PIN', 'None'],
              onChanged: (v) => setState(() => _security = v),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownTile({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
