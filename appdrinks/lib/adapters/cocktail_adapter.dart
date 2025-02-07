import 'package:app_netdrinks/models/cocktail.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class CocktailAdapter extends TypeAdapter<Cocktail> {
  @override
  final int typeId = 0;

  @override
  Cocktail read(BinaryReader reader) {
    return Cocktail.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, Cocktail obj) {
    writer.writeMap(obj.toJson());
  }
}
