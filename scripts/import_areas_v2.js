const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

async function importAreas() {
  const areas = [
    // 北海道
    { id: 'area_001', nameJa: '知床', region: '北海道', sortOrder: 1 },
    { id: 'area_002', nameJa: '羅臼', region: '北海道', sortOrder: 2 },
    { id: 'area_003', nameJa: '積丹', region: '北海道', sortOrder: 3 },
    { id: 'area_004', nameJa: '函館', region: '北海道', sortOrder: 4 },
    // 東北
    { id: 'area_005', nameJa: '竜飛', region: '東北', sortOrder: 5 },
    { id: 'area_006', nameJa: '夏泊', region: '東北', sortOrder: 6 },
    { id: 'area_007', nameJa: '仏ヶ浦', region: '東北', sortOrder: 7 },
    { id: 'area_008', nameJa: '田野畑', region: '東北', sortOrder: 8 },
    { id: 'area_009', nameJa: '大船渡・越喜来', region: '東北', sortOrder: 9 },
    { id: 'area_010', nameJa: '女川・石巻', region: '東北', sortOrder: 10 },
    { id: 'area_011', nameJa: '男鹿', region: '東北', sortOrder: 11 },
    { id: 'area_012', nameJa: '庄内・加茂', region: '東北', sortOrder: 12 },
    // 千葉
    { id: 'area_100', nameJa: '行川', region: '千葉', sortOrder: 13 },
    { id: 'area_101', nameJa: '勝浦', region: '千葉', sortOrder: 14 },
    { id: 'area_102', nameJa: '勝山', region: '千葉', sortOrder: 15 },
    { id: 'area_103', nameJa: '沖ノ島（館山）', region: '千葉', sortOrder: 16 },
    { id: 'area_104', nameJa: '見物', region: '千葉', sortOrder: 17 },
    { id: 'area_105', nameJa: '波左間', region: '千葉', sortOrder: 18 },
    { id: 'area_106', nameJa: '坂田', region: '千葉', sortOrder: 19 },
    { id: 'area_107', nameJa: '西川名', region: '千葉', sortOrder: 20 },
    { id: 'area_108', nameJa: '伊戸', region: '千葉', sortOrder: 21 },
    // 神奈川
    { id: 'area_110', nameJa: '宮川湾', region: '神奈川', sortOrder: 22 },
    { id: 'area_111', nameJa: '城ヶ島', region: '神奈川', sortOrder: 23 },
    { id: 'area_112', nameJa: '葉山', region: '神奈川', sortOrder: 24 },
    { id: 'area_113', nameJa: '早川', region: '神奈川', sortOrder: 25 },
    { id: 'area_114', nameJa: '石橋', region: '神奈川', sortOrder: 26 },
    { id: 'area_115', nameJa: '根府川', region: '神奈川', sortOrder: 27 },
    { id: 'area_116', nameJa: '岩（真鶴）', region: '神奈川', sortOrder: 28 },
    { id: 'area_117', nameJa: '福浦', region: '神奈川', sortOrder: 29 },
    // 関東・伊豆諸島
    { id: 'area_013', nameJa: '伊豆大島', region: '関東・伊豆諸島', sortOrder: 30 },
    { id: 'area_014', nameJa: '八丈島', region: '関東・伊豆諸島', sortOrder: 31 },
    { id: 'area_015', nameJa: '神津島', region: '関東・伊豆諸島', sortOrder: 32 },
    { id: 'area_016', nameJa: '三宅島', region: '関東・伊豆諸島', sortOrder: 33 },
    { id: 'area_017', nameJa: '小笠原 父島', region: '関東・伊豆諸島', sortOrder: 34 },
    { id: 'area_018', nameJa: '小笠原 母島', region: '関東・伊豆諸島', sortOrder: 35 },
    // 東伊豆
    { id: 'area_120', nameJa: '伊豆山', region: '東伊豆', sortOrder: 36 },
    { id: 'area_019', nameJa: '熱海', region: '東伊豆', sortOrder: 37 },
    { id: 'area_020', nameJa: '初島', region: '東伊豆', sortOrder: 38 },
    { id: 'area_121', nameJa: '宇佐美', region: '東伊豆', sortOrder: 39 },
    { id: 'area_022', nameJa: '伊東', region: '東伊豆', sortOrder: 40 },
    { id: 'area_023', nameJa: '川奈', region: '東伊豆', sortOrder: 41 },
    { id: 'area_024', nameJa: '富戸', region: '東伊豆', sortOrder: 42 },
    { id: 'area_025', nameJa: '伊豆海洋公園', region: '東伊豆', sortOrder: 43 },
    { id: 'area_026', nameJa: '八幡野', region: '東伊豆', sortOrder: 44 },
    { id: 'area_027', nameJa: '赤沢', region: '東伊豆', sortOrder: 45 },
    { id: 'area_032', nameJa: '大川', region: '東伊豆', sortOrder: 46 },
    { id: 'area_031', nameJa: '北川', region: '東伊豆', sortOrder: 47 },
    { id: 'area_030', nameJa: '熱川', region: '東伊豆', sortOrder: 48 },
    { id: 'area_028', nameJa: '稲取', region: '東伊豆', sortOrder: 49 },
    { id: 'area_029', nameJa: '菖蒲沢', region: '東伊豆', sortOrder: 50 },
    // 西伊豆
    { id: 'area_033', nameJa: '大瀬崎', region: '西伊豆', sortOrder: 51 },
    { id: 'area_036', nameJa: '獅子浜', region: '西伊豆', sortOrder: 52 },
    { id: 'area_035', nameJa: '平沢', region: '西伊豆', sortOrder: 53 },
    { id: 'area_122', nameJa: '静浦', region: '西伊豆', sortOrder: 54 },
    { id: 'area_034', nameJa: '井田', region: '西伊豆', sortOrder: 55 },
    { id: 'area_123', nameJa: '土肥', region: '西伊豆', sortOrder: 56 },
    { id: 'area_040', nameJa: '安良里', region: '西伊豆', sortOrder: 57 },
    { id: 'area_039', nameJa: '黄金崎', region: '西伊豆', sortOrder: 58 },
    { id: 'area_038', nameJa: '田子', region: '西伊豆', sortOrder: 59 },
    { id: 'area_041', nameJa: '浮島', region: '西伊豆', sortOrder: 60 },
    { id: 'area_042', nameJa: '堂ヶ島', region: '西伊豆', sortOrder: 61 },
    { id: 'area_037', nameJa: '雲見', region: '西伊豆', sortOrder: 62 },
    // 南伊豆
    { id: 'area_043', nameJa: '妻良', region: '南伊豆', sortOrder: 63 },
    { id: 'area_044', nameJa: '中木', region: '南伊豆', sortOrder: 64 },
    { id: 'area_045', nameJa: '神子元', region: '南伊豆', sortOrder: 65 },
    { id: 'area_124', nameJa: '須崎・波勝崎', region: '南伊豆', sortOrder: 66 },
    // 北陸
    { id: 'area_046', nameJa: '能登北部', region: '北陸', sortOrder: 67 },
    { id: 'area_047', nameJa: '能登南部', region: '北陸', sortOrder: 68 },
    { id: 'area_048', nameJa: '越前', region: '北陸', sortOrder: 69 },
    { id: 'area_049', nameJa: '若狭', region: '北陸', sortOrder: 70 },
    // 紀伊半島
    { id: 'area_050', nameJa: '串本', region: '紀伊半島', sortOrder: 71 },
    { id: 'area_051', nameJa: '古座', region: '紀伊半島', sortOrder: 72 },
    { id: 'area_052', nameJa: 'すさみ', region: '紀伊半島', sortOrder: 73 },
    { id: 'area_053', nameJa: '白浜', region: '紀伊半島', sortOrder: 74 },
    { id: 'area_054', nameJa: 'みなべ', region: '紀伊半島', sortOrder: 75 },
    { id: 'area_055', nameJa: '尾鷲', region: '紀伊半島', sortOrder: 76 },
    // 四国
    { id: 'area_056', nameJa: '柏島', region: '四国', sortOrder: 77 },
    { id: 'area_057', nameJa: '愛南', region: '四国', sortOrder: 78 },
    { id: 'area_058', nameJa: '室戸', region: '四国', sortOrder: 79 },
    { id: 'area_059', nameJa: '沖ノ島', region: '四国', sortOrder: 80 },
    // 九州
    { id: 'area_060', nameJa: '辰ノ口', region: '九州', sortOrder: 81 },
    { id: 'area_061', nameJa: '天草', region: '九州', sortOrder: 82 },
    { id: 'area_062', nameJa: '牛深', region: '九州', sortOrder: 83 },
    { id: 'area_063', nameJa: '甑島', region: '九州', sortOrder: 84 },
    { id: 'area_064', nameJa: '鹿児島', region: '九州', sortOrder: 85 },
    // 南西諸島
    { id: 'area_065', nameJa: '屋久島', region: '南西諸島', sortOrder: 86 },
    { id: 'area_066', nameJa: '種子島', region: '南西諸島', sortOrder: 87 },
    { id: 'area_067', nameJa: '奄美大島', region: '南西諸島', sortOrder: 88 },
    { id: 'area_068', nameJa: '加計呂麻島', region: '南西諸島', sortOrder: 89 },
    { id: 'area_069', nameJa: '徳之島', region: '南西諸島', sortOrder: 90 },
    { id: 'area_070', nameJa: '沖永良部島', region: '南西諸島', sortOrder: 91 },
    { id: 'area_071', nameJa: '与論島', region: '南西諸島', sortOrder: 92 },
    // 沖縄本島
    { id: 'area_072', nameJa: '沖縄本島 北部', region: '沖縄本島', sortOrder: 93 },
    { id: 'area_073', nameJa: '恩納村', region: '沖縄本島', sortOrder: 94 },
    { id: 'area_074', nameJa: '真栄田岬', region: '沖縄本島', sortOrder: 95 },
    { id: 'area_075', nameJa: '北谷', region: '沖縄本島', sortOrder: 96 },
    { id: 'area_076', nameJa: '宜野湾', region: '沖縄本島', sortOrder: 97 },
    { id: 'area_077', nameJa: '糸満', region: '沖縄本島', sortOrder: 98 },
    // 慶良間・周辺離島
    { id: 'area_078', nameJa: '粟国島', region: '慶良間・周辺離島', sortOrder: 99 },
    { id: 'area_079', nameJa: '久米島', region: '慶良間・周辺離島', sortOrder: 100 },
    { id: 'area_080', nameJa: '座間味島', region: '慶良間・周辺離島', sortOrder: 101 },
    { id: 'area_081', nameJa: '阿嘉島', region: '慶良間・周辺離島', sortOrder: 102 },
    { id: 'area_082', nameJa: '慶留間島', region: '慶良間・周辺離島', sortOrder: 103 },
    { id: 'area_083', nameJa: '渡嘉敷島', region: '慶良間・周辺離島', sortOrder: 104 },
    // 宮古諸島
    { id: 'area_084', nameJa: '八重干瀬', region: '宮古諸島', sortOrder: 105 },
    { id: 'area_085', nameJa: '伊良部・下地島', region: '宮古諸島', sortOrder: 106 },
    { id: 'area_086', nameJa: '宮古島', region: '宮古諸島', sortOrder: 107 },
    // 八重山諸島
    { id: 'area_087', nameJa: '石垣島 北部', region: '八重山諸島', sortOrder: 108 },
    { id: 'area_088', nameJa: '石垣島 川平', region: '八重山諸島', sortOrder: 109 },
    { id: 'area_089', nameJa: '石垣島 名蔵湾', region: '八重山諸島', sortOrder: 110 },
    { id: 'area_090', nameJa: '石垣島 東海岸', region: '八重山諸島', sortOrder: 111 },
    { id: 'area_091', nameJa: '石垣島 南部', region: '八重山諸島', sortOrder: 112 },
    { id: 'area_092', nameJa: '竹富島 南', region: '八重山諸島', sortOrder: 113 },
    { id: 'area_093', nameJa: '黒島', region: '八重山諸島', sortOrder: 114 },
    { id: 'area_094', nameJa: '新城島（パナリ）', region: '八重山諸島', sortOrder: 115 },
    { id: 'area_095', nameJa: '小浜島', region: '八重山諸島', sortOrder: 116 },
    { id: 'area_096', nameJa: '西表島', region: '八重山諸島', sortOrder: 117 },
    { id: 'area_097', nameJa: '鳩間島', region: '八重山諸島', sortOrder: 118 },
    { id: 'area_098', nameJa: '波照間島', region: '八重山諸島', sortOrder: 119 },
    { id: 'area_099', nameJa: '与那国島', region: '八重山諸島', sortOrder: 120 },
  ];

  // 既存データを削除して再投入
  console.log('既存のareasコレクションを削除中...');
  const existing = await db.collection('areas').get();
  const deleteBatch = db.batch();
  existing.docs.forEach(doc => deleteBatch.delete(doc.ref));
  await deleteBatch.commit();
  console.log(`${existing.size} 件削除完了`);

  // 新規投入（500件制限のためバッチ分割）
  const batchSize = 400;
  for (let i = 0; i < areas.length; i += batchSize) {
    const batch = db.batch();
    const chunk = areas.slice(i, i + batchSize);
    for (const area of chunk) {
      const ref = db.collection('areas').doc(area.id);
      batch.set(ref, {
        nameJa: area.nameJa,
        region: area.region,
        sortOrder: area.sortOrder,
        isActive: true,
      });
    }
    await batch.commit();
  }
  console.log(`エリア ${areas.length} 件投入完了`);
}

async function main() {
  await importAreas();
  console.log('完了！');
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
