import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhonicsPage extends StatelessWidget {
  const PhonicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // 원하는 로직
            print('뒤로가기 누름');

            // 실제 뒤로 가기
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text(
              '파닉스 학습',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (value) {
              if (value == '파닉스') {
                Navigator.pushNamed(context, '/phonics');
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(value: '파닉스', child: Text('파닉스')),
                ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.popUntil(context, (route) {
                  return route.settings.name == '/vocab_list'; // 특정 route 이름 기준
                });
              },
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'MOBIDIC',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Phonics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: Text(
                  '파닉스는 알파벳의 소리 규칙을 익히는 학습입니다.\n소리와 단어의 연결을 통해 영어 읽기 능력을 키워보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              _buildButton(
                context,
                '단모음',
                Colors.green,
                '난이도: 하',
                const ShortVowelPage(),
              ),
              const SizedBox(height: 24),
              _buildButton(
                context,
                '중모음',
                Colors.blue,
                '난이도: 중',
                const LongVowelPage(),
              ),
              const SizedBox(height: 24),
              _buildButton(
                context,
                '이중모음',
                Colors.red,
                '난이도: 상',
                const DiphthongPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    Color color,
    String subtitle,
    Widget page,
  ) {
    return SizedBox(
      width: 280,
      height: 80,
      child: ElevatedButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------ 단모음 ------------------------

class ShortVowelPage extends StatelessWidget {
  const ShortVowelPage({super.key});

  @override
  Widget build(BuildContext context) {
    const shortVowels = [
      '[æ] 애: ant, cap, bag, bat, lamb, pan, tap, can, nap',
      '[e] 에: egg, bed, bell, belt, pet, red, wet, ten, jet, hen, neck, pen',
      '[i] 이: pig, big, dig, sing, ink, spin, ring, bin, hit, kick, king',
      '[ɑ] 아: hot, doll, mop, pot, top, pop, hop, dolphin, box, clock',
      '[ʌ] 어: sun, run, tub, gum, mud, hug, nut, bus, cup, drum, duck',
    ];

    return _buildListScreen(context, '단모음', shortVowels);
  }
}

// ------------------------ 장모음 ------------------------

class LongVowelPage extends StatelessWidget {
  const LongVowelPage({super.key});

  @override
  Widget build(BuildContext context) {
    const longVowels = [
      '[ei] 에이: cake, bake, race, face, hate, late, name, game, vase, plate',
      '[i:] 이~: he, she, me, be, see, tree, key, we, these',
      '[ai] 아이: bike, kite, line, mine, fine, nine, site, time, dive, white',
      '[ou] 오우: home, hole, joke, pole, smoke, nose, rope, rose, stone, phone',
      '[ju] 유: cube, tube, fuse, cute, mute, use, music, human',
    ];

    return _buildListScreen(context, '중모음', longVowels);
  }
}

// ------------------------ 이중모음 ------------------------

class DiphthongPage extends StatelessWidget {
  const DiphthongPage({super.key});

  @override
  Widget build(BuildContext context) {
    const diphthongs = [
      'oo [우 우:]: book, spoon, cook, moon, school, tooth, pool, good, look',
      'ee, ea [이:]: meet, feet, see, sleep, tree, meat, read, eat, jeans, beach',
      'ou, ow [아우]: found, blouse, count, ground, mouse, brown, clown, down, loud, house',
      'oi, oy [오이]: oil, boil, coin, spoil, boy, toy, joy, join, point',
      'au, aw [오:]: audio, auto, fault, saw, paw, straw, dawn, draw, yawn',
      'oa, ow [오우]: boat, coat, road, soap, grow, pillow, slow, window, snow',
      'ai, ay [에이]: rain, mail, train, nail, day, say, bay, play, gray',
      'ew [우:, 유:]: crew, grew, flew, chew / few, dew, new, stew, nephew',
      'ie [아이]: die, lie, pie, tie, cried, fried',
      'ar [아-ㄹ]: far, arm, farm, star, park, card, yard, car, hard',
      'er [어-ㄹ]: water, paper, flower, letter, teacher, winter, butter',
      'ir [어-ㄹ]: bird, girl, shirt, skirt, first, third',
      'or [오-ㄹ,어-ㄹ]: short, fork, corn, pork, born, storm / doctor, visitor, actor',
      'ur [어-ㄹ]: hurt, fur, purple, nurse, turtle, church',
    ];

    return _buildListScreen(context, '이중모음', diphthongs);
  }
}

// ------------------------ 공통 단어 목록 UI ------------------------

Widget _buildListScreen(
  BuildContext context,
  String title,
  List<String> items,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    body: SafeArea(
      bottom: false,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final parts = item.split(':');
          final sound = parts[0].trim();
          final examples = parts.length > 1 ? parts[1].trim() : '';
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.blue.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sound,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  examples,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
