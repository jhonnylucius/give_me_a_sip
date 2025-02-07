import 'dart:core';

import 'package:app_netdrinks/screens/verify_email_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> entrarUsuario(String email, String senha) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: senha);

      // Verificar se o email foi confirmado
      if (!userCredential.user!.emailVerified) {
        await _firebaseAuth.signOut();
        return 'Por favor, verifique seu email antes de fazer login.';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado.';
        case 'wrong-password':
          return 'Falha no login.';
      }
      return e.code;
    }
    return null;
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
          return 'Email já está em uso.';
        case 'invalid-email':
          return 'Dados incorretos.';
        case 'weak-password':
          return 'Dados Incorretos.';
      }
      return e.code;
    }
    return null;
  }

  Future<String?> redefinicaoSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'auth/invalid-email':
          return 'Email inválido.';
        case 'user-not-found':
          return 'Usuário não encontrado.';
      }
      return e.code;
    }
    return null;
  }

  Future<String?> deslogar() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> excluiConta({required senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: _firebaseAuth.currentUser!.email!, password: senha);
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  // Apenas adicionar este método na classe AuthService existente, mantendo todo resto
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // 1. Login Google
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          Logger().w('Usuário cancelou login Google');
          return null;
        }

        // 2. Autenticação Google
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        Logger().i('Token obtido: ${googleAuth.accessToken != null}');

        // 3. Credencial Firebase
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 4. Login Firebase
        userCredential = await _firebaseAuth.signInWithCredential(credential);
        Logger().i('Login Firebase realizado: ${userCredential.user?.uid}');

        // 5. Salvar no Firestore
        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'displayName': userCredential.user!.displayName,
            'email': userCredential.user!.email,
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
