import 'package:app_netdrinks/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class ResetPasswordModal extends StatefulWidget {
  const ResetPasswordModal({super.key});

  @override
  State<ResetPasswordModal> createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends State<ResetPasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Redefinir Senha'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'Endereço de E-mail'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Por favor, informe um email válido';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final authService = AuthService();
              final erro = await authService.redefinicaoSenha(
                  email: _emailController.text.trim());

              if (!context.mounted) return;

              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email de redefinição enviado com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(erro),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(FlutterI18n.translate(context, 'Enviar')),
        ),
      ],
    );
  }
}
