import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart' as yaml;
import 'package:json_annotation/json_annotation.dart';

import 'constants.dart' as constants;
import 'custom_exceptions.dart';
import 'utils.dart' as utils;

part 'flutter_launcher_icons_config.g.dart';

@JsonSerializable(
  anyMap: true,
  checked: true,
)
class FlutterLauncherIconsConfig {
  /// Generic imagepath
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// Returns true or path if android config is enabled
  final dynamic android; // path or bool

  /// Returns true or path if ios config is enabled
  final dynamic ios; // path or bool

  /// Image path specific to android
  @JsonKey(name: 'image_path_android')
  final String? imagePathAndroid;

  /// Image path specific to ios
  @JsonKey(name: 'image_path_ios')
  final String? imagePathIOS;

  /// android adaptive icon foreground image
  @JsonKey(name: 'adaptive_icon_foreground')
  final String? adaptiveIconForeground;

  /// android adaptive_icon_background image
  @JsonKey(name: 'adaptive_icon_background')
  final String? adaptiveIconBackground;

  /// Web platform config
  @JsonKey(name: 'web')
  final WebConfig? webConfig;

  const FlutterLauncherIconsConfig({
    this.imagePath,
    this.android = false,
    this.ios = false,
    this.imagePathAndroid,
    this.imagePathIOS,
    this.adaptiveIconForeground,
    this.adaptiveIconBackground,
    this.webConfig,
  });

  factory FlutterLauncherIconsConfig.fromJson(Map json) => _$FlutterLauncherIconsConfigFromJson(json);

  /// Loads flutter launcher icons configs from given [filePath]
  static FlutterLauncherIconsConfig? loadConfigFromPath(String filePath) {
    final configFile = File(filePath);
    if (!configFile.existsSync()) {
      return null;
    }
    final configContent = configFile.readAsStringSync();
    try {
      return yaml.checkedYamlDecode<FlutterLauncherIconsConfig>(
        configContent,
        (json) => FlutterLauncherIconsConfig.fromJson(json!['flutter_icons']),
      );
    } on yaml.ParsedYamlException catch (e) {
      throw InvalidConfigException(e.formattedMessage);
    } catch (e) {
      rethrow;
    }
  }

  /// Loads flutter launcher icons config from `pubspec.yaml` file
  static FlutterLauncherIconsConfig? loadConfigFromPubSpec() {
    try {
      final pubspecFile = File(constants.pubspecFilePath);
      if (!pubspecFile.existsSync()) {
        return null;
      }
      final pubspecContent = pubspecFile.readAsStringSync();
      return yaml.checkedYamlDecode<FlutterLauncherIconsConfig?>(
        pubspecContent,
        (json) {
          if (json!['flutter_icons'] == null) {
            return null;
          }
          return FlutterLauncherIconsConfig.fromJson(json['flutter_icons']);
        },
      );
    } on yaml.ParsedYamlException catch (e) {
      throw InvalidConfigException(e.formattedMessage);
    } catch (e) {
      rethrow;
    }
  }

  static FlutterLauncherIconsConfig? loadConfigFromFlavor(String flavor) {
    return FlutterLauncherIconsConfig.loadConfigFromPath(utils.flavorConfigFile(flavor));
  }

  Map<String, dynamic> toJson() => _$FlutterLauncherIconsConfigToJson(this);

  @override
  String toString() => 'FlutterLauncherIconsConfig: ${toJson()}';
}

@JsonSerializable(
  anyMap: true,
  checked: true,
)
class WebConfig {
  final bool generate;

  /// Image path for web
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// manifest.json's background_color
  @JsonKey(name: 'background_color')
  final String? backgroundColor;

  /// manifest.json's theme_color
  @JsonKey(name: 'theme_color')
  final String? themeColor;

  const WebConfig({
    this.generate = false,
    this.imagePath,
    this.backgroundColor,
    this.themeColor,
  });

  factory WebConfig.fromJson(Map json) => _$WebConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WebConfigToJson(this);

  @override
  String toString() => 'WebConfig: ${toJson()}';
}
