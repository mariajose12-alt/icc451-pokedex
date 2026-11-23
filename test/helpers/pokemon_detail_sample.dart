// Respuesta de ejemplo con la forma de la consulta (Bulbasaur).
Map<String, dynamic> sampleDetail() {
  return <String, dynamic>{
    'base': <dynamic>[
      <String, dynamic>{
        'id': 1,
        'name': 'bulbasaur',
        'height': 7,
        'weight': 69,
        'pokemonsprites': <dynamic>[
          <String, dynamic>{'artwork': 'a1.png', 'sprite': 's1.png'},
        ],
        'pokemontypes': <dynamic>[
          <String, dynamic>{
            'slot': 1,
            'type': <String, dynamic>{'id': 12, 'name': 'grass'},
          },
          <String, dynamic>{
            'slot': 2,
            'type': <String, dynamic>{'id': 4, 'name': 'poison'},
          },
        ],
        'pokemonstats': <dynamic>[
          for (var statId = 1; statId <= 6; statId++)
            <String, dynamic>{
              'base_stat': 40 + statId,
              'stat': <String, dynamic>{'id': statId},
            },
        ],
        'pokemonspecy': <String, dynamic>{'id': 1, 'generation_id': 1},
        'pokemonabilities': <dynamic>[
          <String, dynamic>{
            'is_hidden': false,
            'ability': <String, dynamic>{
              'id': 65,
              'name': 'overgrow',
              'abilitynames': <dynamic>[
                <String, dynamic>{'language_id': 7, 'name': 'Espesura'},
                <String, dynamic>{'language_id': 9, 'name': 'Overgrow'},
              ],
              'abilityeffecttexts': <dynamic>[
                <String, dynamic>{'short_effect': 'Boosts grass moves.'},
              ],
            },
          },
          <String, dynamic>{
            'is_hidden': true,
            'ability': <String, dynamic>{
              'id': 34,
              'name': 'chlorophyll',
              'abilitynames': <dynamic>[
                <String, dynamic>{'language_id': 9, 'name': 'Chlorophyll'},
              ],
              'abilityeffecttexts': <dynamic>[],
            },
          },
        ],
      },
    ],
    'species': <dynamic>[
      <String, dynamic>{
        'pokemonegggroups': <dynamic>[
          <String, dynamic>{
            'egggroup': <String, dynamic>{'name': 'monster'},
          },
          <String, dynamic>{
            'egggroup': <String, dynamic>{'name': 'plant'},
          },
        ],
        'evolutionchain': <String, dynamic>{
          'id': 1,
          'pokemonspecies': <dynamic>[
            <String, dynamic>{
              'id': 1,
              'name': 'bulbasaur',
              'evolves_from_species_id': null,
              'pokemonevolutions': <dynamic>[],
            },
            <String, dynamic>{
              'id': 2,
              'name': 'ivysaur',
              'evolves_from_species_id': 1,
              'pokemonevolutions': <dynamic>[
                <String, dynamic>{
                  'min_level': 16,
                  'min_happiness': null,
                  // PokeAPI manda '' cuando no hay condición de hora.
                  'time_of_day': '',
                  'evolutiontrigger': <String, dynamic>{'name': 'level-up'},
                  'item': null,
                },
              ],
            },
          ],
        },
      },
    ],
    'forms': <dynamic>[
      <String, dynamic>{
        'id': 1,
        'name': 'bulbasaur',
        'is_default': true,
        'pokemontypes': <dynamic>[
          <String, dynamic>{
            'slot': 1,
            'type': <String, dynamic>{'id': 12},
          },
        ],
        'pokemonsprites': <dynamic>[
          <String, dynamic>{
            'sprite': 's.png',
            'shiny': 'sh.png',
            'artwork': 'a.png',
            'artwork_shiny': 'ash.png',
          },
        ],
      },
    ],
    'moves': <dynamic>[
      <String, dynamic>{
        'level': 1,
        'move': <String, dynamic>{'id': 33, 'name': 'tackle'},
        'movelearnmethod': <String, dynamic>{'id': 1},
        'versiongroup': <String, dynamic>{'id': 1, 'name': 'red-blue'},
      },
      <String, dynamic>{
        'level': 0,
        'move': <String, dynamic>{'id': 14, 'name': 'swords-dance'},
        'movelearnmethod': <String, dynamic>{'id': 4},
        'versiongroup': <String, dynamic>{'id': 1, 'name': 'red-blue'},
      },
    ],
  };
}
