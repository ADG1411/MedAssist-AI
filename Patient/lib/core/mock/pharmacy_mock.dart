class PharmacyMock {
  static const List<Map<String, dynamic>> medicines = [
    {
      'id': 'med_1',
      'name': 'Panadol Rapid',
      'genericName': 'Paracetamol 500mg',
      'brand': 'GSK',
      'brandPrice': 150,
      'genericPrice': 30,
      'isPrescriptionRequired': false,
      'dosage': '1 tablet every 6 hours',
    },
    {
      'id': 'med_2',
      'name': 'Augmentin 625 Duo',
      'genericName': 'Amoxicillin + Clavulanic Acid',
      'brand': 'GSK',
      'brandPrice': 450,
      'genericPrice': 120,
      'isPrescriptionRequired': true,
      'dosage': '1 tablet twice a day after meals',
    },
    {
      'id': 'med_3',
      'name': 'Ecosprin 75',
      'genericName': 'Aspirin 75mg',
      'brand': 'USV',
      'brandPrice': 50,
      'genericPrice': 20,
      'isPrescriptionRequired': true,
      'dosage': '1 tablet after dinner',
    },
  ];
}

