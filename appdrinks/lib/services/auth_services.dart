import 'dart:core';

import 'package:app_netdrinks/screens/verify_email_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Logger logger = Logger();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<String?> entrarUsuario(String email, String senha) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: senha);

      // Verificar se o email foi confirmado
      if (!userCredential.user!.emailVerified) {
        await _firebaseAuth.signOut();
        return FlutterI18n.translate(
            Get.context!, 'auth_services.verify_email_before_login');
      }

      // Atualizar lastLogin
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      logger.i('Login bem sucedido para: ${userCredential.user?.email}');
      return null; // Retorna null para indicar sucesso
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.user_not_found');
        case 'wrong-password':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.login_failed');
      }
      return e.code;
    }
  }

  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required BuildContext context,
  }) async {
    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);

      // Atualizar displayName e aguardar
      await userCredential.user!.updateDisplayName(nome);

      // Enviar email de verificação
      await userCredential.user!.sendEmailVerification();

      // Forçar reload para garantir atualização
      await userCredential.user!.reload();

      // Salvar no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'displayName': nome,
        'email': email,
      });

      // Recarregar usuário atual
      await FirebaseAuth.instance.currentUser?.reload();

      // Redirecionar para a tela de verificação de email
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyEmailScreen(user: userCredential.user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.email_already_in_use');
        case 'invalid-email':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.invalid_data');
        case 'weak-password':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.invalid_data');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> redefinicaoSenha({required String email}) async {
    try {
      logger.i('Tentando enviar email de redefinição para: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      logger.i('Email de redefinição enviado com sucesso para: $email');
      return null;
    } on FirebaseAuthException catch (e) {
      logger.e('Erro ao enviar email de redefinição: ${e.code}', error: e);
      switch (e.code) {
        case 'invalid-email':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.invalid_email');
        case 'user-not-found':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.user_not_found');
        case 'too-many-requests':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.too_many_requests');
        default:
          return FlutterI18n.translate(
              Get.context!, 'auth_services.reset_email_error');
      }
    }
  }

  Future<String?> deslogar() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> excluiConta({required String? senha}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return FlutterI18n.translate(
            Get.context!, 'auth_services.user_not_found');
      }

      // Verifica se é login do Google
      bool isGoogleUser = user.providerData
          .any((userInfo) => userInfo.providerId == 'google.com');

      if (isGoogleUser && senha == null) {
        // Se for usuário Google sem senha, solicita reautenticação via Google
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          return FlutterI18n.translate(
              Get.context!, 'auth_services.user_cancelled');
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Reautentica com Google
        await user.reauthenticateWithCredential(credential);
      } else {
        // Reautentica com email/senha
        if (senha == null) {
          return FlutterI18n.translate(
              Get.context!, 'auth_services.password_required');
        }

        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: senha,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Deleta a conta
      await user.delete();
      logger.i('Conta excluída com sucesso');
      return null;
    } on FirebaseAuthException catch (e) {
      logger.e('Erro ao excluir conta: ${e.code}', error: e);
      switch (e.code) {
        case 'requires-recent-login':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.recent_login_required');
        case 'wrong-password':
          return FlutterI18n.translate(
              Get.context!, 'auth_services.wrong_password');
        default:
          return FlutterI18n.translate(
              Get.context!, 'auth_services.incorrect_data');
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          Logger().w('Usuário cancelou login Google');
          return null;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        Logger().i('Token obtido: ${googleAuth.accessToken != null}');
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _firebaseAuth.signInWithCredential(credential);
        Logger().i('Login Firebase realizado: ${userCredential.user?.uid}');
        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'displayName': userCredential.user!.displayName ?? '',
            'email': userCredential.user!.email ?? '',
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          Logger().i('Dados salvos no Firestore');
        }
      }
      return userCredential;
    } catch (e) {
      Logger().e('Erro no login com Google: $e');
      return null;
    }
  }
}
