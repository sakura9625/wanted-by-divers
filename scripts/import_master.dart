import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('エリアデータを投入中...');
  await importAreas(firestore);
  print('生物データを投入中...');
  await importCreatures(firestore);
  print('完了！');
}

Future<void> importAreas(FirebaseFirestore firestore) async {
  final areas = [
    {'id': 'area_001', 'nameJa': '知床', 'region': '北海道', 'sortOrder': 1},
    {'id': 'area_002', 'nameJa': '羅臼', 'region': '北海道', 'sortOrder': 2},
    {'id': 'area_003', 'nameJa': '積丹', 'region': '北海道', 'sortOrder': 3},
    {'id': 'area_004', 'nameJa': '函館', 'region': '北海道', 'sortOrder': 4},
    {'id': 'area_005', 'nameJa': '竜飛', 'region': '東北', 'sortOrder': 5},
    {'id': 'area_006', 'nameJa': '夏泊', 'region': '東北', 'sortOrder': 6},
    {'id': 'area_007', 'nameJa': '仏ヶ浦', 'region': '東北', 'sortOrder': 7},
    {'id': 'area_008', 'nameJa': '田野畑', 'region': '東北', 'sortOrder': 8},
    {'id': 'area_009', 'nameJa': '大船渡・越喜来', 'region': '東北', 'sortOrder': 9},
    {'id': 'area_010', 'nameJa': '女川・石巻', 'region': '東北', 'sortOrder': 10},
    {'id': 'area_011', 'nameJa': '男鹿', 'region': '東北', 'sortOrder': 11},
    {'id': 'area_012', 'nameJa': '庄内・加茂', 'region': '東北', 'sortOrder': 12},
    {'id': 'area_013', 'nameJa': '伊豆大島', 'region': '関東・伊豆諸島', 'sortOrder': 13},
    {'id': 'area_014', 'nameJa': '八丈島', 'region': '関東・伊豆諸島', 'sortOrder': 14},
    {'id': 'area_015', 'nameJa': '神津島', 'region': '関東・伊豆諸島', 'sortOrder': 15},
    {'id': 'area_016', 'nameJa': '三宅島', 'region': '関東・伊豆諸島', 'sortOrder': 16},
    {'id': 'area_017', 'nameJa': '父島', 'region': '関東・伊豆諸島', 'sortOrder': 17},
    {'id': 'area_018', 'nameJa': '母島', 'region': '関東・伊豆諸島', 'sortOrder': 18},
    {'id': 'area_019', 'nameJa': '熱海', 'region': '伊豆半島', 'sortOrder': 19},
    {'id': 'area_020', 'nameJa': '初島', 'region': '伊豆半島', 'sortOrder': 20},
    {'id': 'area_021', 'nameJa': '網代', 'region': '伊豆半島', 'sortOrder': 21},
    {'id': 'area_022', 'nameJa': '伊東', 'region': '伊豆半島', 'sortOrder': 22},
    {'id': 'area_023', 'nameJa': '川奈', 'region': '伊豆半島', 'sortOrder': 23},
    {'id': 'area_024', 'nameJa': '富戸', 'region': '伊豆半島', 'sortOrder': 24},
    {'id': 'area_025', 'nameJa': '伊豆海洋公園', 'region': '伊豆半島', 'sortOrder': 25},
    {'id': 'area_026', 'nameJa': '八幡野', 'region': '伊豆半島', 'sortOrder': 26},
    {'id': 'area_027', 'nameJa': '赤沢', 'region': '伊豆半島', 'sortOrder': 27},
    {'id': 'area_028', 'nameJa': '稲取', 'region': '伊豆半島', 'sortOrder': 28},
    {'id': 'area_029', 'nameJa': '菖蒲沢', 'region': '伊豆半島', 'sortOrder': 29},
    {'id': 'area_030', 'nameJa': '熱川', 'region': '伊豆半島', 'sortOrder': 30},
    {'id': 'area_031', 'nameJa': '北川', 'region': '伊豆半島', 'sortOrder': 31},
    {'id': 'area_032', 'nameJa': '大川', 'region': '伊豆半島', 'sortOrder': 32},
    {'id': 'area_033', 'nameJa': '大瀬崎', 'region': '伊豆半島', 'sortOrder': 33},
    {'id': 'area_034', 'nameJa': '井田', 'region': '伊豆半島', 'sortOrder': 34},
    {'id': 'area_035', 'nameJa': '平沢', 'region': '伊豆半島', 'sortOrder': 35},
    {'id': 'area_036', 'nameJa': '獅子浜', 'region': '伊豆半島', 'sortOrder': 36},
    {'id': 'area_037', 'nameJa': '雲見', 'region': '伊豆半島', 'sortOrder': 37},
    {'id': 'area_038', 'nameJa': '田子', 'region': '伊豆半島', 'sortOrder': 38},
    {'id': 'area_039', 'nameJa': '黄金崎', 'region': '伊豆半島', 'sortOrder': 39},
    {'id': 'area_040', 'nameJa': '安良里', 'region': '伊豆半島', 'sortOrder': 40},
    {'id': 'area_041', 'nameJa': '浮島', 'region': '伊豆半島', 'sortOrder': 41},
    {'id': 'area_042', 'nameJa': '堂ヶ島', 'region': '伊豆半島', 'sortOrder': 42},
    {'id': 'area_043', 'nameJa': '妻良', 'region': '伊豆半島', 'sortOrder': 43},
    {'id': 'area_044', 'nameJa': '中木', 'region': '伊豆半島', 'sortOrder': 44},
    {'id': 'area_045', 'nameJa': '神子元', 'region': '伊豆半島', 'sortOrder': 45},
    {'id': 'area_046', 'nameJa': '能登北部', 'region': '北陸', 'sortOrder': 46},
    {'id': 'area_047', 'nameJa': '能登南部', 'region': '北陸', 'sortOrder': 47},
    {'id': 'area_048', 'nameJa': '越前', 'region': '北陸', 'sortOrder': 48},
    {'id': 'area_049', 'nameJa': '若狭', 'region': '北陸', 'sortOrder': 49},
    {'id': 'area_050', 'nameJa': '串本', 'region': '紀伊半島', 'sortOrder': 50},
    {'id': 'area_051', 'nameJa': '古座', 'region': '紀伊半島', 'sortOrder': 51},
    {'id': 'area_052', 'nameJa': 'すさみ', 'region': '紀伊半島', 'sortOrder': 52},
    {'id': 'area_053', 'nameJa': '白浜', 'region': '紀伊半島', 'sortOrder': 53},
    {'id': 'area_054', 'nameJa': 'みなべ', 'region': '紀伊半島', 'sortOrder': 54},
    {'id': 'area_055', 'nameJa': '尾鷲', 'region': '紀伊半島', 'sortOrder': 55},
    {'id': 'area_056', 'nameJa': '柏島', 'region': '四国', 'sortOrder': 56},
    {'id': 'area_057', 'nameJa': '愛南', 'region': '四国', 'sortOrder': 57},
    {'id': 'area_058', 'nameJa': '室戸', 'region': '四国', 'sortOrder': 58},
    {'id': 'area_059', 'nameJa': '沖ノ島', 'region': '四国', 'sortOrder': 59},
    {'id': 'area_060', 'nameJa': '辰ノ口', 'region': '九州・南西諸島', 'sortOrder': 60},
    {'id': 'area_061', 'nameJa': '天草', 'region': '九州・南西諸島', 'sortOrder': 61},
    {'id': 'area_062', 'nameJa': '牛深', 'region': '九州・南西諸島', 'sortOrder': 62},
    {'id': 'area_063', 'nameJa': '甑島', 'region': '九州・南西諸島', 'sortOrder': 63},
    {'id': 'area_064', 'nameJa': '鹿児島', 'region': '九州・南西諸島', 'sortOrder': 64},
    {'id': 'area_065', 'nameJa': '屋久島', 'region': '九州・南西諸島', 'sortOrder': 65},
    {'id': 'area_066', 'nameJa': '種子島', 'region': '九州・南西諸島', 'sortOrder': 66},
    {'id': 'area_067', 'nameJa': '奄美大島', 'region': '九州・南西諸島', 'sortOrder': 67},
    {'id': 'area_068', 'nameJa': '加計呂麻島', 'region': '九州・南西諸島', 'sortOrder': 68},
    {'id': 'area_069', 'nameJa': '徳之島', 'region': '九州・南西諸島', 'sortOrder': 69},
    {'id': 'area_070', 'nameJa': '沖永良部島', 'region': '九州・南西諸島', 'sortOrder': 70},
    {'id': 'area_071', 'nameJa': '与論島', 'region': '九州・南西諸島', 'sortOrder': 71},
    {'id': 'area_072', 'nameJa': '沖縄本島 北部', 'region': '沖縄本島・周辺', 'sortOrder': 72},
    {'id': 'area_073', 'nameJa': '恩納村', 'region': '沖縄本島・周辺', 'sortOrder': 73},
    {'id': 'area_074', 'nameJa': '真栄田岬', 'region': '沖縄本島・周辺', 'sortOrder': 74},
    {'id': 'area_075', 'nameJa': '北谷', 'region': '沖縄本島・周辺', 'sortOrder': 75},
    {'id': 'area_076', 'nameJa': '宜野湾', 'region': '沖縄本島・周辺', 'sortOrder': 76},
    {'id': 'area_077', 'nameJa': '糸満', 'region': '沖縄本島・周辺', 'sortOrder': 77},
    {'id': 'area_078', 'nameJa': '粟国島', 'region': '沖縄本島・周辺', 'sortOrder': 78},
    {'id': 'area_079', 'nameJa': '久米島', 'region': '沖縄本島・周辺', 'sortOrder': 79},
    {'id': 'area_080', 'nameJa': '座間味島', 'region': '沖縄本島・周辺', 'sortOrder': 80},
    {'id': 'area_081', 'nameJa': '阿嘉島', 'region': '沖縄本島・周辺', 'sortOrder': 81},
    {'id': 'area_082', 'nameJa': '慶留間島', 'region': '沖縄本島・周辺', 'sortOrder': 82},
    {'id': 'area_083', 'nameJa': '渡嘉敷島', 'region': '沖縄本島・周辺', 'sortOrder': 83},
    {'id': 'area_084', 'nameJa': '八重干瀬', 'region': '宮古諸島', 'sortOrder': 84},
    {'id': 'area_085', 'nameJa': '伊良部・下地島', 'region': '宮古諸島', 'sortOrder': 85},
    {'id': 'area_086', 'nameJa': '宮古島', 'region': '宮古諸島', 'sortOrder': 86},
    {'id': 'area_087', 'nameJa': '石垣島 北部', 'region': '八重山諸島', 'sortOrder': 87},
    {'id': 'area_088', 'nameJa': '石垣島 川平', 'region': '八重山諸島', 'sortOrder': 88},
    {'id': 'area_089', 'nameJa': '石垣島 名蔵湾', 'region': '八重山諸島', 'sortOrder': 89},
    {'id': 'area_090', 'nameJa': '石垣島 東海岸', 'region': '八重山諸島', 'sortOrder': 90},
    {'id': 'area_091', 'nameJa': '石垣島 南部', 'region': '八重山諸島', 'sortOrder': 91},
    {'id': 'area_092', 'nameJa': '竹富島 南', 'region': '八重山諸島', 'sortOrder': 92},
    {'id': 'area_093', 'nameJa': '黒島', 'region': '八重山諸島', 'sortOrder': 93},
    {'id': 'area_094', 'nameJa': '新城島（パナリ）', 'region': '八重山諸島', 'sortOrder': 94},
    {'id': 'area_095', 'nameJa': '小浜島', 'region': '八重山諸島', 'sortOrder': 95},
    {'id': 'area_096', 'nameJa': '西表島', 'region': '八重山諸島', 'sortOrder': 96},
    {'id': 'area_097', 'nameJa': '鳩間島', 'region': '八重山諸島', 'sortOrder': 97},
    {'id': 'area_098', 'nameJa': '波照間島', 'region': '八重山諸島', 'sortOrder': 98},
    {'id': 'area_099', 'nameJa': '与那国島', 'region': '八重山諸島', 'sortOrder': 99},
  ];

  final batch = firestore.batch();
  for (final area in areas) {
    final ref = firestore.collection('areas').doc(area['id'] as String);
    batch.set(ref, {
      'nameJa': area['nameJa'],
      'region': area['region'],
      'sortOrder': area['sortOrder'],
      'isActive': true,
    });
  }
  await batch.commit();
  print('エリア ${areas.length} 件投入完了');
}

Future<void> importCreatures(FirebaseFirestore firestore) async {
  final creatures = [
    {'id': 'creature_001', 'nameJa': 'マンタ', 'nameEn': 'Manta Ray', 'category': 'ray', 'rarity': 4},
    {'id': 'creature_003', 'nameJa': 'ジンベエザメ', 'nameEn': 'Whale Shark', 'category': 'shark', 'rarity': 5},
    {'id': 'creature_004', 'nameJa': 'ハンマーヘッドシャーク', 'nameEn': 'Scalloped Hammerhead', 'category': 'shark', 'rarity': 4},
    {'id': 'creature_005', 'nameJa': 'ネムリブカ・ホワイトチップ', 'nameEn': 'Whitetip Reef Shark', 'category': 'shark', 'rarity': 2},
    {'id': 'creature_006', 'nameJa': 'グレーリーフシャーク', 'nameEn': 'Grey Reef Shark', 'category': 'shark', 'rarity': 3},
    {'id': 'creature_009', 'nameJa': 'ナポレオンフィッシュ', 'nameEn': 'Humphead Wrasse', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_010', 'nameJa': 'バラクーダ', 'nameEn': 'Barracuda', 'category': 'fish', 'rarity': 2},
    {'id': 'creature_011', 'nameJa': 'ギンガメアジ', 'nameEn': 'Bigeye Trevally', 'category': 'fish', 'rarity': 2},
    {'id': 'creature_012', 'nameJa': 'カスミアジ', 'nameEn': 'Bluefin Trevally', 'category': 'fish', 'rarity': 2},
    {'id': 'creature_013', 'nameJa': 'イソマグロ', 'nameEn': 'Dogtooth Tuna', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_014', 'nameJa': 'ロウニンアジ', 'nameEn': 'Giant Trevally', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_016', 'nameJa': 'ピグミーシーホース', 'nameEn': 'Pygmy Seahorse', 'category': 'fish', 'rarity': 5},
    {'id': 'creature_017', 'nameJa': 'ホムラハゼ', 'nameEn': 'Flaming Prawn-goby', 'category': 'fish', 'rarity': 5},
    {'id': 'creature_018', 'nameJa': 'ナカモトイロワケハゼ', 'nameEn': 'Yellownose Shrimpgoby', 'category': 'fish', 'rarity': 5},
    {'id': 'creature_019', 'nameJa': 'ニシキテグリ', 'nameEn': 'Mandarinfish', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_020', 'nameJa': 'ハナヒゲウツボ（幼魚）', 'nameEn': 'Ribbon Eel juvenile', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_022', 'nameJa': 'タコクラゲ', 'nameEn': 'Mastigias Jellyfish', 'category': 'other', 'rarity': 2},
    {'id': 'creature_023', 'nameJa': 'カニハゼ', 'nameEn': 'Zebra Dartfish', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_024', 'nameJa': 'ヤシャハゼ', 'nameEn': 'Yasha Haze', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_025', 'nameJa': 'ヒレナガネジリンボウ', 'nameEn': 'Highfin Coralgoby', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_026', 'nameJa': 'ネジリンボウ', 'nameEn': 'Twisted-jaw Shrimpgoby', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_027', 'nameJa': 'オドリハゼ', 'nameEn': 'Dancing Goby', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_031', 'nameJa': 'ミミックオクトパス', 'nameEn': 'Mimic Octopus', 'category': 'other', 'rarity': 5},
    {'id': 'creature_037', 'nameJa': 'ハナイカ', 'nameEn': 'Flamboyant Cuttlefish', 'category': 'other', 'rarity': 4},
    {'id': 'creature_039', 'nameJa': 'ニシキフウライウオ', 'nameEn': 'Ornate Ghost Pipefish', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_044', 'nameJa': 'トウアカクマノミ', 'nameEn': 'Spine-cheeked Anemonefish', 'category': 'fish', 'rarity': 2},
    {'id': 'creature_048', 'nameJa': 'イロカエルアンコウ', 'nameEn': 'Painted Frogfish', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_049', 'nameJa': 'シロボシテンジクザメ', 'nameEn': 'Zebra Shark', 'category': 'shark', 'rarity': 3},
    {'id': 'creature_051', 'nameJa': 'ツマグロ・ブラックチップ', 'nameEn': 'Blacktip Reef Shark', 'category': 'shark', 'rarity': 2},
    {'id': 'creature_054', 'nameJa': 'イタチザメ・タイガー', 'nameEn': 'Tiger Shark', 'category': 'shark', 'rarity': 5},
    {'id': 'creature_060', 'nameJa': 'ハダカハオコゼ', 'nameEn': 'Leaf Scorpionfish', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_064', 'nameJa': 'アケボノハゼ', 'nameEn': "Randall's Prawn-goby", 'category': 'fish', 'rarity': 4},
    {'id': 'creature_065', 'nameJa': 'サクラダイ', 'nameEn': 'Threadfin Anthias', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_068', 'nameJa': 'スジクロユリハゼ', 'nameEn': 'Firefish Goby', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_070', 'nameJa': 'ハナタツ', 'nameEn': 'Leafy Seahorse', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_073', 'nameJa': 'マンジュウイシモチ', 'nameEn': 'Pajama Cardinalfish', 'category': 'fish', 'rarity': 1},
    {'id': 'creature_075', 'nameJa': 'バンドウイルカ', 'nameEn': 'Bottlenose Dolphin', 'category': 'other', 'rarity': 3},
    {'id': 'creature_076', 'nameJa': 'ミナミバンドウイルカ', 'nameEn': 'Indo-Pacific Bottlenose Dolphin', 'category': 'other', 'rarity': 3},
    {'id': 'creature_077', 'nameJa': 'ザトウクジラ', 'nameEn': 'Humpback Whale', 'category': 'other', 'rarity': 5},
    {'id': 'creature_078', 'nameJa': 'マッコウクジラ', 'nameEn': 'Sperm Whale', 'category': 'other', 'rarity': 5},
    {'id': 'creature_079', 'nameJa': 'シャチ', 'nameEn': 'Orca', 'category': 'other', 'rarity': 5},
    {'id': 'creature_080', 'nameJa': 'カマイルカ', 'nameEn': 'Pacific White-sided Dolphin', 'category': 'other', 'rarity': 4},
    {'id': 'creature_083', 'nameJa': 'ゴシキエビ', 'nameEn': 'Painted Spiny Lobster', 'category': 'crustacean', 'rarity': 3},
    {'id': 'creature_086', 'nameJa': 'ホワイトソックスシュリンプ', 'nameEn': 'White-banded Cleaner Shrimp', 'category': 'crustacean', 'rarity': 3},
    {'id': 'creature_095', 'nameJa': 'チンアナゴ', 'nameEn': 'Spotted Garden Eel', 'category': 'fish', 'rarity': 2},
    {'id': 'creature_098', 'nameJa': 'モンツキカエルウオ', 'nameEn': 'Jewelled Blenny', 'category': 'fish', 'rarity': 2},
    {'id': 'creature_099', 'nameJa': 'タテジマキンチャクダイ（幼魚）', 'nameEn': 'Emperor Angelfish juvenile', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_105', 'nameJa': 'クマドリカエルアンコウ', 'nameEn': 'Clown Frogfish', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_106', 'nameJa': 'ボロカサゴ', 'nameEn': 'Rhinopias', 'category': 'fish', 'rarity': 5},
    {'id': 'creature_107', 'nameJa': 'アカグツ', 'nameEn': 'Spotfin Frogfish', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_108', 'nameJa': 'ピカチュウウミウシ', 'nameEn': 'Yellow Nudibranch', 'category': 'nudibranch', 'rarity': 2},
    {'id': 'creature_114', 'nameJa': 'ハナゴンベ', 'nameEn': 'Pseudanthias pleurotaenia', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_115', 'nameJa': 'キンチャクガニ', 'nameEn': 'Boxer Crab', 'category': 'crustacean', 'rarity': 4},
    {'id': 'creature_121', 'nameJa': 'マンボウ', 'nameEn': 'Ocean Sunfish', 'category': 'other', 'rarity': 4},
    {'id': 'creature_122', 'nameJa': 'リュウグウノツカイ', 'nameEn': 'Oarfish', 'category': 'fish', 'rarity': 5},
    {'id': 'creature_123', 'nameJa': 'クダゴンベ', 'nameEn': 'Hawkfish sp.', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_124', 'nameJa': 'フリソデエビ', 'nameEn': 'Harlequin Shrimp', 'category': 'crustacean', 'rarity': 4},
    {'id': 'creature_125', 'nameJa': 'ジョーフィッシュ', 'nameEn': 'Jawfish', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_126', 'nameJa': 'ミナミハコフグ（幼魚）', 'nameEn': 'Cube Boxfish juvenile', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_127', 'nameJa': 'マダラタルミ（幼魚）', 'nameEn': 'Humpback Grouper juvenile', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_128', 'nameJa': 'ホホスジタルミ（幼魚）', 'nameEn': 'Lined Sweetlips juvenile', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_129', 'nameJa': 'ダンゴウオ', 'nameEn': 'Snailfish', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_130', 'nameJa': 'スミレナガハナダイ', 'nameEn': 'Longfin Anthias', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_131', 'nameJa': 'アカオビハナダイ', 'nameEn': 'Redbar Anthias', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_134', 'nameJa': 'イバラタツ', 'nameEn': 'Spiny Seahorse', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_135', 'nameJa': 'オオモンカエルアンコウ', 'nameEn': 'Giant Frogfish', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_136', 'nameJa': 'クダヤギクモエビ', 'nameEn': 'Skeleton Shrimp', 'category': 'crustacean', 'rarity': 4},
    {'id': 'creature_137', 'nameJa': 'ニタリ', 'nameEn': "Bryde's Whale", 'category': 'other', 'rarity': 5},
    {'id': 'creature_138', 'nameJa': 'シコンハタタテハゼ', 'nameEn': 'Decorated Dartfish', 'category': 'fish', 'rarity': 5},
    {'id': 'creature_139', 'nameJa': 'コールマンシュリンプ', 'nameEn': "Coleman's Shrimp", 'category': 'crustacean', 'rarity': 5},
    {'id': 'creature_140', 'nameJa': 'パンダダルマハゼ', 'nameEn': 'Panda Dwarfgoby', 'category': 'fish', 'rarity': 5},
    {'id': 'creature_141', 'nameJa': 'コウリンハナダイ', 'nameEn': 'Sunrise Dottyback', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_142', 'nameJa': 'ニラミハナダイ', 'nameEn': 'Bicolor Dottyback', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_143', 'nameJa': 'ケラマハナダイ', 'nameEn': 'Kerama Anthias', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_144', 'nameJa': 'アサヒハナゴイ', 'nameEn': 'Sunrise Anthias', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_145', 'nameJa': 'カシワハナダイ', 'nameEn': 'Kashiwa Anthias', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_146', 'nameJa': 'キシマハナダイ', 'nameEn': 'Kishima Anthias', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_147', 'nameJa': 'フチドリハナダイ', 'nameEn': 'Bordered Anthias', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_148', 'nameJa': 'ミジンベニハゼ', 'nameEn': 'Trimma tevegae', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_149', 'nameJa': 'ハタタテシノビハゼ', 'nameEn': 'Stonogobiops nematodes', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_150', 'nameJa': 'キツネメネジリンボウ', 'nameEn': 'Stonogobiops sp.', 'category': 'fish', 'rarity': 4},
    {'id': 'creature_151', 'nameJa': 'アオギハゼ', 'nameEn': 'Blue-streak Goby', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_152', 'nameJa': 'オキナワベニハゼ', 'nameEn': 'Trimma okinawae', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_153', 'nameJa': 'ベニハゼ', 'nameEn': 'Trimma sp.', 'category': 'fish', 'rarity': 2},
    {'id': 'creature_154', 'nameJa': 'イトヒキベラ', 'nameEn': 'Cirrhilabrus sp.', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_155', 'nameJa': 'ニシキイトヒキベラ', 'nameEn': 'Cirrhilabrus exquisitus', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_156', 'nameJa': 'ルリイトヒキベラ', 'nameEn': 'Cirrhilabrus cyanopleura', 'category': 'fish', 'rarity': 3},
    {'id': 'creature_157', 'nameJa': 'ワンダーパス', 'nameEn': 'Wonderpus', 'category': 'other', 'rarity': 5},
  ];

  const batchSize = 400;
  for (var i = 0; i < creatures.length; i += batchSize) {
    final batch = firestore.batch();
    final end = (i + batchSize > creatures.length) ? creatures.length : i + batchSize;
    final chunk = creatures.sublist(i, end);
    for (final creature in chunk) {
      final ref = firestore.collection('creatures').doc(creature['id'] as String);
      batch.set(ref, {
        'nameJa': creature['nameJa'],
        'nameEn': creature['nameEn'],
        'category': creature['category'],
        'rarity': creature['rarity'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
  print('生物 ${creatures.length} 件投入完了');
}
