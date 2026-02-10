import 'package:flutter/material.dart';

class EnXDocCreatePage extends StatefulWidget {
  const EnXDocCreatePage({super.key});

  @override
  State<EnXDocCreatePage> createState() => _EnXDocCreatePageState();
}

class _EnXDocCreatePageState extends State<EnXDocCreatePage> {
  // Lista de itens para o scroll animado
  final List<Map<String, dynamic>> _docItems = [
    {
      'level': '1° ENX OS',
      'logo': 'assets/images/enx.png',
      'sub': 'O Sistema Primário',
      'desc': 'Núcleo operacional responsável pela criptografia EnX18, EnX32 e o algoritmo EnX609. Gestão de segurança de baixo nível.',
      'path': 'Kernel/Security/Crypt'
    },
    {
      'level': '2° DWELLERS',
      'logo': 'assets/images/dwellers.png',
      'sub': 'Gerenciador de Identidade',
      'desc': 'O "Nation" é o banco de dados central. Ele gerencia todos os IDs globais e validação de identidades.',
      'path': 'Frameworks/Dwellers/nation'
    },
    {
      'level': '3° INASX',
      'logo': 'assets/images/inasx.png',
      'sub': 'Cryptocurrency',
      'desc': 'Sistema de economia digital. Responsável pela validação do Multiverso de transações e saldo INX.',
      'path': 'Frameworks/Inasx/multiverse'
    },
    {
      'level': '3.1° MINEINASX',
      'logo': 'assets/images/miner.png',
      'sub': 'Minerador',
      'desc': 'Motor de processamento de tickets. Ciclo EnX_Low (1-3-6-9) a cada 180 segundos para validação de blocos.',
      'path': 'worker_node/logs'
    },
    {
      'level': '3.2° PIGEON',
      'logo': 'assets/images/pigeon.png',
      'sub': 'Mensageiro',
      'desc': 'Comunicação criptografada ponto-a-ponto. Autenticação temporária para máxima privacidade.',
      'path': 'Frameworks/Pigeon/mailbox'
    },
    {
      'level': '3.3° FREEMARKET',
      'logo': 'assets/images/fmarket.png',
      'sub': 'Marketplace',
      'desc': 'Ambiente descentralizado para compra e venda de ativos. Gestão de vendedores e ofertas globais.',
      'path': 'Frameworks/FreeMarket/seller'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        title: const Text('DECRYPTING DOCUMENTATION...', 
          style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Color(0xFF64FFDA))),
        backgroundColor: const Color(0xFF020817),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _docItems.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            // O delay aumenta conforme o índice para criar o efeito de escada
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: _buildAnimatedItem(_docItems[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(item['logo'], height: 45),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['level'], 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(item['sub'], 
                      style: const TextStyle(color: Color(0xFF64FFDA), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item['desc'], 
            style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFF1D2A4E)),
            ),
            child: Text(item['path'], 
              style: const TextStyle(color: Colors.yellow, fontSize: 10, fontFamily: 'monospace')),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF1D2A4E)),
        ],
      ),
    );
  }
}
