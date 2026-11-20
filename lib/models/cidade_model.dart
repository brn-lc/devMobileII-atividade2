class Cidade {
  final int id;
  final String nome;
  final String uf;

  Cidade({
    required this.id,
    required this.nome,
    required this.uf,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'uf': uf,
      };

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? 'Desconhecida',
      uf: json['uf'] as String? ?? '--',
    );
  }
}
