/// Basic text tokenizer for Firestore search
List<String> generateKeywords(String text) {
  return text.toLowerCase().split(RegExp(r'[ ,]+'));
}

/// Used for dry_plant_hire & wet_plant_hire
List<String> generatePlantKeywords(String company, String machine, String location) {
  return [
    ...generateKeywords(company),
    ...generateKeywords(machine),
    ...generateKeywords(location),
  ];
}

/// Used for labour_hire
List<String> generateLabourKeywords(String skills, String location) {
  return [
    ...generateKeywords(skills),
    ...generateKeywords(location),
  ];
}

/// Used for lump_sum_contractors
List<String> generateLumpSumKeywords(String company, String location, String category) {
  return [
    ...generateKeywords(company),
    ...generateKeywords(location),
    ...generateKeywords(category),
  ];
}
