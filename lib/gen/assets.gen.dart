/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/OFL.txt
  String get ofl => 'assets/fonts/OFL.txt';

  /// File path: assets/fonts/PoppinsMedium.ttf
  String get poppinsMedium => 'assets/fonts/PoppinsMedium.ttf';

  /// File path: assets/fonts/PoppinsRegular.ttf
  String get poppinsRegular => 'assets/fonts/PoppinsRegular.ttf';

  /// File path: assets/fonts/PoppinsSemiBold.ttf
  String get poppinsSemiBold => 'assets/fonts/PoppinsSemiBold.ttf';

  /// List of all assets
  List<String> get values =>
      [ofl, poppinsMedium, poppinsRegular, poppinsSemiBold];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/ic_dashboard.svg
  SvgGenImage get icDashboard =>
      const SvgGenImage('assets/icons/ic_dashboard.svg');

  /// File path: assets/icons/ic_home.svg
  SvgGenImage get icHome => const SvgGenImage('assets/icons/ic_home.svg');

  /// File path: assets/icons/ic_ingredient.svg
  SvgGenImage get icIngredient =>
      const SvgGenImage('assets/icons/ic_ingredient.svg');

  /// File path: assets/icons/ic_login.svg
  SvgGenImage get icLogin => const SvgGenImage('assets/icons/ic_login.svg');

  /// File path: assets/icons/ic_logout.svg
  SvgGenImage get icLogout => const SvgGenImage('assets/icons/ic_logout.svg');

  /// File path: assets/icons/ic_meal.svg
  SvgGenImage get icMeal => const SvgGenImage('assets/icons/ic_meal.svg');

  /// File path: assets/icons/ic_plan.svg
  SvgGenImage get icPlan => const SvgGenImage('assets/icons/ic_plan.svg');

  /// File path: assets/icons/ic_recipe.svg
  SvgGenImage get icRecipe => const SvgGenImage('assets/icons/ic_recipe.svg');

  /// File path: assets/icons/ic_settings.svg
  SvgGenImage get icSettings =>
      const SvgGenImage('assets/icons/ic_settings.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
        icDashboard,
        icHome,
        icIngredient,
        icLogin,
        icLogout,
        icMeal,
        icPlan,
        icRecipe,
        icSettings
      ];
}

class $AssetsLanguageGen {
  const $AssetsLanguageGen();

  /// File path: assets/language/english.json
  String get english => 'assets/language/english.json';

  /// File path: assets/language/hindi.json
  String get hindi => 'assets/language/hindi.json';

  /// File path: assets/language/tamil.json
  String get tamil => 'assets/language/tamil.json';

  /// List of all assets
  List<String> get values => [english, hindi, tamil];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsLanguageGen language = $AssetsLanguageGen();
}

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
