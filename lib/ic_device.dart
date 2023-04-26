class ICDevice {
  String name;
  String macAddr;

//<editor-fold desc="Data Methods">
  ICDevice({
    required this.name,
    required this.macAddr,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ICDevice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          macAddr == other.macAddr);

  @override
  int get hashCode => name.hashCode ^ macAddr.hashCode;

  @override
  String toString() {
    return 'ICDeviceInfo{' + ' name: $name,' + ' macAddr: $macAddr,' + '}';
  }

  ICDevice copyWith({
    String? name,
    String? macAddr,
  }) {
    return ICDevice(
      name: name ?? this.name,
      macAddr: macAddr ?? this.macAddr,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'macAddr': this.macAddr,
    };
  }

  factory ICDevice.fromMap(Map<String, dynamic> map) {
    return ICDevice(
      name: map['name'] as String,
      macAddr: map['macAddr'] as String,
    );
  }

//</editor-fold>
}
