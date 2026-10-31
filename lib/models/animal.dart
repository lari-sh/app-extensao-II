enum AnimalStatus {
  available('Disponível'),
  treatment('Em tratamento'),
  quarantine('Quarentena'),
  adopted('Adotado');

  const AnimalStatus(this.label);
  final String label;
}

class Animal {
  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.sex,
    required this.size,
    required this.age,
    this.status = AnimalStatus.available,
    this.history = '',
    this.vaccinated = false,
    this.neutered = false,
    this.vaccines = const [],
    this.deworming = const [],
    this.medications = const [],
  });
  final String id, name, species, sex, size, age, history;
  final AnimalStatus status;
  final bool vaccinated, neutered;
  final List<String> vaccines, deworming, medications;
  Animal withStatus(AnimalStatus value) => Animal(
    id: id,
    name: name,
    species: species,
    sex: sex,
    size: size,
    age: age,
    status: value,
    history: history,
    vaccinated: vaccinated,
    neutered: neutered,
    vaccines: vaccines,
    deworming: deworming,
    medications: medications,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'sex': sex,
    'size': size,
    'age': age,
    'history': history,
    'status': status.name,
    'vaccinated': vaccinated,
    'neutered': neutered,
    'vaccines': vaccines,
    'deworming': deworming,
    'medications': medications,
  };
  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
    id: json['id'] as String,
    name: json['name'] as String,
    species: json['species'] as String,
    sex: json['sex'] as String,
    size: json['size'] as String,
    age: json['age'] as String,
    history: json['history'] as String? ?? '',
    status: AnimalStatus.values.byName(json['status'] as String),
    vaccinated: json['vaccinated'] as bool? ?? false,
    neutered: json['neutered'] as bool? ?? false,
    vaccines: List<String>.from(json['vaccines'] as List? ?? []),
    deworming: List<String>.from(json['deworming'] as List? ?? []),
    medications: List<String>.from(json['medications'] as List? ?? []),
  );
}

const demoAnimals = [
  Animal(
    id: 'A0024',
    name: 'Luna',
    species: 'Cachorro',
    sex: 'Fêmea',
    size: 'Médio',
    age: '2 anos',
    vaccinated: true,
    neutered: true,
    history:
        'Carinhosa e brincalhona. Gosta de passeios e da companhia de pessoas.',
  ),
  Animal(
    id: 'A0008',
    name: 'Thor',
    species: 'Cachorro',
    sex: 'Macho',
    size: 'Grande',
    age: '4 anos',
    status: AnimalStatus.treatment,
    history:
        'Resgatado com sinais de desnutrição. Está em tratamento dermatológico. '
        'Adora caminhadas e convive bem com outros cães.',
    vaccines: ['V10 · registro demonstrativo'],
  ),
  Animal(
    id: 'A0031',
    name: 'Mia',
    species: 'Gato',
    sex: 'Fêmea',
    size: 'Pequeno',
    age: '1 ano',
    vaccinated: true,
    neutered: true,
    history:
        'Uma gatinha tranquila e curiosa, pronta para conhecer sua família.',
  ),
  Animal(
    id: 'A0003',
    name: 'Rex',
    species: 'Cachorro',
    sex: 'Macho',
    size: 'Grande',
    age: '6 anos',
    status: AnimalStatus.quarantine,
    history: 'Em observação após o resgate. Precisa de tempo e carinho.',
  ),
  Animal(
    id: 'A0042',
    name: 'Bob',
    species: 'Cachorro',
    sex: 'Macho',
    size: 'Médio',
    age: '3 anos',
    history: 'Companheiro e muito sociável.',
  ),
  Animal(
    id: 'A0017',
    name: 'Pandora',
    species: 'Gato',
    sex: 'Fêmea',
    size: 'Pequeno',
    age: '5 anos',
    status: AnimalStatus.treatment,
    history: 'Recebendo cuidados da equipe do abrigo.',
  ),
];
