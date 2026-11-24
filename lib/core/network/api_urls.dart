class ApiUrls {
  ApiUrls._();

  static const String profileList = 'v1/profile/list/';

  // Module Banner endpoints
  static const String moduleBannerList = 'v1/module/banner/list/';
  static const String moduleBannerCreate = 'v1/module/banner/create/';
  static String moduleBannerDetail(int id) => 'v1/module/banner/$id/';

  // Module Ads endpoints
  static const String moduleAdsList = 'v1/module/ads/list/';
  static const String moduleAdsCreate = 'v1/module/ads/create/';
  static String moduleAdsDetail(int id) => 'v1/module/ads/$id/';

  // Module endpoints
  static const String moduleList = 'v1/module/modules/list/';
  static const String moduleCreate = 'v1/module/modules/create/';
  static String moduleDetail(int id) => 'v1/module/modules/$id/';
}