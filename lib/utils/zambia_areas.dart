class ZambiaAreas {
  static final Map<String, List<String>> areasByCity = {
    'Lusaka': [
      'Woodlands',
      'Kabulonga',
      'Ibex Hill',
      'Roma',
      'Avondale',
      'Chalala',
      'Meanwood',
      'Olympia',
      'Northmead',
      'Rhodespark',
      'Foxdale',
      'Kalingalinga',
      'Kamwala',
      'Makeni',
      'Kanyama',
    ],
    'Kitwe': [
      'Parklands',
      'Riverside',
      'Nkana East',
      'Nkana West',
      'Chachacha',
      'Buchanan',
      'Obote Avenue',
    ],
    'Ndola': [
      'Kansenshi',
      'Nkwazi',
      'Masala',
      'Hillcrest',
      'Itawa',
      'Chifubu',
    ],
    'Livingstone': [
      'Mosi-Oa-Tunya',
      'Maramba',
      'Libuyu',
      'Dambwa',
      'Sikhulu',
    ],
  };

  static List<String> getAllAreas() {
    return areasByCity.values.expand((areas) => areas).toList();
  }

  static List<String> getAreasForCity(String city) {
    return areasByCity[city] ?? [];
  }
}