import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dicas e Novidades'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipCard(
                icon: FontAwesomeIcons.magic,
                title: 'Drinks com o que você tem em casa',
                content:
                    'Use nossa busca por ingredientes para descobrir drinks incríveis com o que você já tem em casa! Basta digitar os ingredientes em inglês e explorar as possibilidades.',
              ),
              _buildTipCard(
                icon: FontAwesomeIcons.child,
                title: 'Diversão em Família',
                content:
                    'Aproveite nossos filtros de drinks sem álcool para criar momentos especiais com as crianças. Transforme a preparação de drinks em uma atividade divertida e segura para toda família.',
              ),
              _buildTipCard(
                icon: FontAwesomeIcons.language,
                title: 'Suporte Multi-idiomas (Em breve)',
                content:
                    'Estamos desenvolvendo nossa própria API para trazer suporte completo em português, inglês e espanhol. Em breve você poderá pesquisar no seu idioma preferido!',
              ),
              _buildTipCard(
                icon: FontAwesomeIcons.starHalfAlt,
                title: 'Drinks Originais da Comunidade (Em breve)',
                content:
                    'Logo você poderá compartilhar suas criações originais com a comunidade NetDrinks! Seu drink pode se tornar o próximo favorito de milhares de pessoas.',
              ),
              _buildTipCard(
                icon: FontAwesomeIcons.trophy,
                title: 'Drinks oficiais do IBA (Em breve)',
                content:
                    'Em breve teremos as receitas oficiais da International Bartenders Association (IBA), com vídeos exclusivos. Você terá acesso às versões originais e suas variações mais populares.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon,
                    size: 24, color: const Color.fromARGB(255, 131, 4, 4)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
