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
      'sub': 'Official operating system',
      'desc': 'Operating System: At a lower level, the OS kernel manages hardware resources and can utilize forward-looking cryptography to protect data in the file system. It is a dedicated, tamper-proof physical device or module specifically designed to generate, store, and manage cryptographic keys, as well as perform cryptographic operations in a secure environment. EnXcripto provides hardware-accelerated encryption and enforces strict key usage policies. They ensure that private keys never leave the secure environment, making it extremely difficult for attackers to decrypt messages or files..',
      'path': 'Kernel'
    },
    {
      'level': '2° DWELLERS',
      'logo': 'assets/images/dwellers.png',
      'sub': 'Identity Manager',
      'desc': 'An identity management system is a database that creates and stores identifying information about the people and devices that need to access the organizations data and resources EnX.',
      'path': 'System Call Interface'
    },
    {
      'level': '3° INASX',
      'logo': 'assets/images/inasx.png',
      'sub': 'Cryptocurrency',
      'desc': 'Cryptocurrency is a form of digital money or virtual asset that does not have a physical representation, such as banknotes or metal coins. They operate through a decentralized computer network, meaning they do not depend on central banks or governments for issuance or control. ',
      'path': 'User Space Wallet'
    },
    {
      'level': '3.1° MINEINASX',
      'logo': 'assets/images/logo.png',
      'sub': 'Miner',
      'desc': 'The creation of new blocks and the validation of transactions do not depend on powerful hardware, but rather on the amount of coins a user keeps "locked" on the network. How PoS works Unlike conventional mining, which requires high energy consumption and complex machines, PoS works through Staking: Validators: Instead of miners, the network uses validators, who are chosen randomly or based on their stake. Guarantee: To participate, the user must deposit a minimum amount of the native currency as collateral. If the validator acts in bad faith, they may lose this amount. Rewards: Validators receive new coins as a reward for the security service provided to the network.',
      'path': 'Proof of Stake'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        title: const Text('REQUISITOS MÍNIMOS...', 
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
