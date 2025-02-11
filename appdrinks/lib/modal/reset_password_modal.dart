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
      title: Text(FlutterI18n.translate(context, 'reset_password_modal.title')),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: FlutterI18n.translate(
                context, 'reset_password_modal.email_label'),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return FlutterI18n.translate(
                  context, 'reset_password_modal.email_error');
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
          child: Text(
              FlutterI18n.translate(context, 'reset_password_modal.cancel')),
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
                  SnackBar(
                    content: Text(FlutterI18n.translate(
                        context, 'reset_password_modal.success')),
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
          child:
              Text(FlutterI18n.translate(context, 'reset_password_modal.send')),
        ),
      ],
    );
  }
}
