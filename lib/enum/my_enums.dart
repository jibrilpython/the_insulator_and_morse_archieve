enum HardwareCategory {
  glassInsulator('Glass Insulator'),
  porcelainInsulator('Porcelain Insulator'),
  telegraphKey('Telegraph Key'),
  sounder('Sounder / Relay'),
  lightningArrestor('Lightning Arrestor'),
  cableSplice('Cable Splice / Accessory'),
  other('Other');

  const HardwareCategory(this.label);
  final String label;
}

enum ConditionState {
  mint('Mint / Museum Quality'),
  excellent('Excellent — No Damage'),
  good('Good — Minor Wear'),
  fair('Fair — Base Flakes / Wire Rub'),
  poor('Poor — Heavy Damage'),
  unknown('Condition Unknown');

  const ConditionState(this.label);
  final String label;
}
