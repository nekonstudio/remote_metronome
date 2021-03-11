// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metronome_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetronomeSettingsAdapter extends TypeAdapter<MetronomeSettings> {
  @override
  final int typeId = 0;

  @override
  MetronomeSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MetronomeSettings(
      tempo: fields[0] as int,
      beatsPerBar: fields[1] as int,
      clicksPerBeat: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MetronomeSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tempo)
      ..writeByte(1)
      ..write(obj.beatsPerBar)
      ..writeByte(2)
      ..write(obj.clicksPerBeat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetronomeSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
