class MoveModel {
  final String moveset;
  final String nameMove;
  final String startup;
  final String hitProperties;
  final String damage;
  final String onBlock;
  final String onHit;
  final String onCH;
  final String states;
  final String notes;

  const MoveModel({
    required this.moveset,
    required this.nameMove,
    required this.startup,
    required this.hitProperties,
    required this.damage,
    required this.onBlock,
    required this.onHit,
    required this.onCH,
    required this.states,
    required this.notes,
  });

  factory MoveModel.fromJson(Map<String, dynamic> json) {
    return MoveModel(
      moveset: json['moveset']?.toString() ?? '-',
      nameMove: json['name_move']?.toString() ?? '',
      startup: json['startup']?.toString() ?? '-',
      hitProperties: json['hit_properties']?.toString() ?? '-',
      damage: json['damage']?.toString() ?? '-',
      onBlock: json['on_block']?.toString() ?? '-',
      onHit: json['on_hit']?.toString() ?? '-',
      onCH: json['on_CH']?.toString() ?? '-',
      states: json['states']?.toString() ?? '-',
      notes: json['notes']?.toString() ?? '',
    );
  }
}
