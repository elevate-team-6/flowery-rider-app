// ---------------------------------------------------------------------------
// TEAM INSTRUCTIONS - HOW TO ADD NEW ASSETS:
// 1. Add the asset to 'assets/icons/'.
// 2. Add the asset name to the appropriate class below.
// 3. Use lowerCamelCase for variable names.
// 4. Always use the path constants (_iconsPath).
// ---------------------------------------------------------------------------

abstract class AppIcons {
  static const String _iconsPath = 'assets/icons/';

  // Example: static const String yourIcon = '${_iconsPath}icon_name.svg';
  static const String flowerAppIcon = '${_iconsPath}flower_app_icon.svg';
  static const String home = '${_iconsPath}home_icon.svg';
  static const String categories = '${_iconsPath}category_icon.svg';
  static const String cart = '${_iconsPath}cart_icon.svg';
  static const String profile = '${_iconsPath}profile_icon.svg';
  static const String location = '${_iconsPath}location_icon.svg';
  static const String arrowRight = '${_iconsPath}arrow-right.png';
  static const String delete = '${_iconsPath}delete.png';
  static const String search = '${_iconsPath}search_icon.svg';
  static const String filtration = '${_iconsPath}filtration_icon.svg';
  static const String sort = '${_iconsPath}sort_icon.svg';
  static const String bell = '${_iconsPath}bell_icon.svg';
  static const String language = '${_iconsPath}language_icon.svg';
  static const String orders = '${_iconsPath}orders_icon.svg';
  static const String logout = '${_iconsPath}logout_icon.svg';
  static const String time = '${_iconsPath}time.svg';
  static const String submitIcon = '${_iconsPath}submit_bg_icon.svg';
  static const String success = '${_iconsPath}success_icon.svg';
}

abstract class AppImages {
  static const String _imagesPath = 'assets/images/';

  // Example: static const String yourIcon = '${_imagesPath}image_name.svg';
  static const String imageDefault = '${_imagesPath}Image_default.png';
  static const String appImage = '${_imagesPath}app_image.svg';
  static const String defaultImage = '${_imagesPath}Image_default.png';
  static const String scooterBody = '${_imagesPath}scooter_body.png';
  static const String flowerWheel = '${_imagesPath}flower_wheel.png';
}

abstract class AppLottie {
  static const String _lottiePath = 'assets/lottie_files/';

  static const String flowerLoading = '${_lottiePath}flower_loading.json';
  static const String onboardingAnimation =
      '${_lottiePath}onboarding_animation.json';
  static const String empty = '${_lottiePath}empty.json';
}

abstract class AppJson {
  static const String countryPath = 'assets/json/country.json';
}
