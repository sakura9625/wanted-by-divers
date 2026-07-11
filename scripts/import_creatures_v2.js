const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

async function importCreatures() {
  const creatures = [
    // サメ・エイ (shark_ray)
    { id: 'creature_001', nameJa: 'マンタ', nameEn: 'Manta Ray', category: 'shark_ray', rarity: 4 },
    { id: 'creature_004', nameJa: 'ハンマーヘッドシャーク', nameEn: 'Scalloped Hammerhead', category: 'shark_ray', rarity: 4 },
    { id: 'creature_005', nameJa: 'ネムリブカ・ホワイトチップ', nameEn: 'Whitetip Reef Shark', category: 'shark_ray', rarity: 2 },
    { id: 'creature_006', nameJa: 'グレーリーフシャーク', nameEn: 'Grey Reef Shark', category: 'shark_ray', rarity: 3 },
    { id: 'creature_049', nameJa: 'シロボシテンジクザメ', nameEn: 'Zebra Shark', category: 'shark_ray', rarity: 3 },
    { id: 'creature_051', nameJa: 'ツマグロ・ブラックチップ', nameEn: 'Blacktip Reef Shark', category: 'shark_ray', rarity: 2 },
    { id: 'creature_054', nameJa: 'イタチザメ・タイガー', nameEn: 'Tiger Shark', category: 'shark_ray', rarity: 5 },
    { id: 'creature_137', nameJa: 'ニタリ', nameEn: 'Longfin Mako Shark', category: 'shark_ray', rarity: 5 },

    // 大物・回遊魚 (big_fish)
    { id: 'creature_009', nameJa: 'ナポレオンフィッシュ', nameEn: 'Humphead Wrasse', category: 'big_fish', rarity: 3 },
    { id: 'creature_010', nameJa: 'バラクーダ', nameEn: 'Barracuda', category: 'big_fish', rarity: 2 },
    { id: 'creature_011', nameJa: 'ギンガメアジ', nameEn: 'Bigeye Trevally', category: 'big_fish', rarity: 2 },
    { id: 'creature_012', nameJa: 'カスミアジ', nameEn: 'Bluefin Trevally', category: 'big_fish', rarity: 2 },
    { id: 'creature_013', nameJa: 'イソマグロ', nameEn: 'Dogtooth Tuna', category: 'big_fish', rarity: 3 },
    { id: 'creature_014', nameJa: 'ロウニンアジ', nameEn: 'Giant Trevally', category: 'big_fish', rarity: 3 },
    { id: 'creature_121', nameJa: 'マンボウ', nameEn: 'Ocean Sunfish', category: 'big_fish', rarity: 4 },
    { id: 'creature_122', nameJa: 'リュウグウノツカイ', nameEn: 'Oarfish', category: 'big_fish', rarity: 5 },

    // 根魚・地形魚 (reef_fish)
    { id: 'creature_048', nameJa: 'イロカエルアンコウ', nameEn: 'Painted Frogfish', category: 'reef_fish', rarity: 3 },
    { id: 'creature_105', nameJa: 'クマドリカエルアンコウ', nameEn: 'Clown Frogfish', category: 'reef_fish', rarity: 4 },
    { id: 'creature_135', nameJa: 'オオモンカエルアンコウ', nameEn: 'Giant Frogfish', category: 'reef_fish', rarity: 3 },
    { id: 'creature_106', nameJa: 'ボロカサゴ', nameEn: 'Rhinopias', category: 'reef_fish', rarity: 5 },
    { id: 'creature_107', nameJa: 'アカグツ', nameEn: 'Spotfin Frogfish', category: 'reef_fish', rarity: 4 },
    { id: 'creature_060', nameJa: 'ハダカハオコゼ', nameEn: 'Leaf Scorpionfish', category: 'reef_fish', rarity: 4 },
    { id: 'creature_123', nameJa: 'クダゴンベ', nameEn: 'Hawkfish sp.', category: 'reef_fish', rarity: 4 },
    { id: 'creature_098', nameJa: 'モンツキカエルウオ', nameEn: 'Jewelled Blenny', category: 'reef_fish', rarity: 2 },

    // マクロ・レア (macro)
    { id: 'creature_016', nameJa: 'ピグミーシーホース', nameEn: 'Pygmy Seahorse', category: 'macro', rarity: 5 },
    { id: 'creature_019', nameJa: 'ニシキテグリ', nameEn: 'Mandarinfish', category: 'macro', rarity: 4 },
    { id: 'creature_020', nameJa: 'ハナヒゲウツボ（幼魚）', nameEn: 'Ribbon Eel juvenile', category: 'macro', rarity: 4 },
    { id: 'creature_039', nameJa: 'ニシキフウライウオ', nameEn: 'Ornate Ghost Pipefish', category: 'macro', rarity: 4 },
    { id: 'creature_070', nameJa: 'ハナタツ', nameEn: 'Leafy Seahorse', category: 'macro', rarity: 4 },
    { id: 'creature_134', nameJa: 'イバラタツ', nameEn: 'Spiny Seahorse', category: 'macro', rarity: 4 },
    { id: 'creature_125', nameJa: 'ジョーフィッシュ', nameEn: 'Jawfish', category: 'macro', rarity: 3 },
    { id: 'creature_129', nameJa: 'ダンゴウオ', nameEn: 'Snailfish', category: 'macro', rarity: 4 },
    { id: 'creature_140', nameJa: 'パンダダルマハゼ', nameEn: 'Panda Dwarfgoby', category: 'macro', rarity: 5 },

    // ハゼ系 (goby)
    { id: 'creature_017', nameJa: 'ホムラハゼ', nameEn: 'Flaming Prawn-goby', category: 'goby', rarity: 5 },
    { id: 'creature_018', nameJa: 'ナカモトイロワケハゼ', nameEn: 'Yellownose Shrimpgoby', category: 'goby', rarity: 5 },
    { id: 'creature_023', nameJa: 'カニハゼ', nameEn: 'Zebra Dartfish', category: 'goby', rarity: 3 },
    { id: 'creature_024', nameJa: 'ヤシャハゼ', nameEn: 'Yasha Haze', category: 'goby', rarity: 4 },
    { id: 'creature_025', nameJa: 'ヒレナガネジリンボウ', nameEn: 'Highfin Coralgoby', category: 'goby', rarity: 3 },
    { id: 'creature_026', nameJa: 'ネジリンボウ', nameEn: 'Twisted-jaw Shrimpgoby', category: 'goby', rarity: 3 },
    { id: 'creature_027', nameJa: 'オドリハゼ', nameEn: 'Dancing Goby', category: 'goby', rarity: 4 },
    { id: 'creature_064', nameJa: 'アケボノハゼ', nameEn: "Randall's Prawn-goby", category: 'goby', rarity: 4 },
    { id: 'creature_068', nameJa: 'スジクロユリハゼ', nameEn: 'Firefish Goby', category: 'goby', rarity: 3 },
    { id: 'creature_138', nameJa: 'シコンハタタテハゼ', nameEn: 'Decorated Dartfish', category: 'goby', rarity: 5 },
    { id: 'creature_148', nameJa: 'ミジンベニハゼ', nameEn: 'Trimma tevegae', category: 'goby', rarity: 4 },
    { id: 'creature_149', nameJa: 'ハタタテシノビハゼ', nameEn: 'Stonogobiops nematodes', category: 'goby', rarity: 4 },
    { id: 'creature_150', nameJa: 'キツネメネジリンボウ', nameEn: 'Stonogobiops sp.', category: 'goby', rarity: 4 },
    { id: 'creature_151', nameJa: 'アオギハゼ', nameEn: 'Blue-streak Goby', category: 'goby', rarity: 3 },
    { id: 'creature_152', nameJa: 'オキナワベニハゼ', nameEn: 'Trimma okinawae', category: 'goby', rarity: 3 },
    { id: 'creature_153', nameJa: 'ベニハゼ', nameEn: 'Trimma sp.', category: 'goby', rarity: 2 },

    // ハナダイ系 (anthias)
    { id: 'creature_065', nameJa: 'サクラダイ', nameEn: 'Threadfin Anthias', category: 'anthias', rarity: 3 },
    { id: 'creature_114', nameJa: 'ハナゴンベ', nameEn: 'Pseudanthias pleurotaenia', category: 'anthias', rarity: 3 },
    { id: 'creature_130', nameJa: 'スミレナガハナダイ', nameEn: 'Longfin Anthias', category: 'anthias', rarity: 4 },
    { id: 'creature_131', nameJa: 'アカオビハナダイ', nameEn: 'Redbar Anthias', category: 'anthias', rarity: 3 },
    { id: 'creature_141', nameJa: 'コウリンハナダイ', nameEn: 'Sunrise Dottyback', category: 'anthias', rarity: 4 },
    { id: 'creature_142', nameJa: 'ニラミハナダイ', nameEn: 'Bicolor Dottyback', category: 'anthias', rarity: 4 },
    { id: 'creature_143', nameJa: 'ケラマハナダイ', nameEn: 'Kerama Anthias', category: 'anthias', rarity: 3 },
    { id: 'creature_144', nameJa: 'アサヒハナゴイ', nameEn: 'Sunrise Anthias', category: 'anthias', rarity: 4 },
    { id: 'creature_145', nameJa: 'カシワハナダイ', nameEn: 'Kashiwa Anthias', category: 'anthias', rarity: 4 },
    { id: 'creature_146', nameJa: 'キシマハナダイ', nameEn: 'Kishima Anthias', category: 'anthias', rarity: 4 },
    { id: 'creature_147', nameJa: 'フチドリハナダイ', nameEn: 'Bordered Anthias', category: 'anthias', rarity: 3 },

    // その他の魚 (other_fish)
    { id: 'creature_044', nameJa: 'トウアカクマノミ', nameEn: 'Spine-cheeked Anemonefish', category: 'other_fish', rarity: 2 },
    { id: 'creature_095', nameJa: 'チンアナゴ', nameEn: 'Spotted Garden Eel', category: 'other_fish', rarity: 2 },
    { id: 'creature_099', nameJa: 'タテジマキンチャクダイ（幼魚）', nameEn: 'Emperor Angelfish juvenile', category: 'other_fish', rarity: 3 },
    { id: 'creature_100', nameJa: 'フウライチョウチョウウオ', nameEn: 'Vagabond Butterflyfish', category: 'other_fish', rarity: 1 },
    { id: 'creature_074', nameJa: 'マンジュウイシモチ', nameEn: 'Pajama Cardinalfish', category: 'other_fish', rarity: 1 },
    { id: 'creature_154', nameJa: 'イトヒキベラ', nameEn: 'Cirrhilabrus sp.', category: 'other_fish', rarity: 3 },
    { id: 'creature_155', nameJa: 'ニシキイトヒキベラ', nameEn: 'Cirrhilabrus exquisitus', category: 'other_fish', rarity: 3 },
    { id: 'creature_156', nameJa: 'ルリイトヒキベラ', nameEn: 'Cirrhilabrus cyanopleura', category: 'other_fish', rarity: 3 },
    { id: 'creature_126', nameJa: 'ミナミハコフグ（幼魚）', nameEn: 'Cube Boxfish juvenile', category: 'other_fish', rarity: 3 },
    { id: 'creature_127', nameJa: 'マダラタルミ（幼魚）', nameEn: 'Humpback Grouper juvenile', category: 'other_fish', rarity: 3 },
    { id: 'creature_128', nameJa: 'ホホスジタルミ（幼魚）', nameEn: 'Lined Sweetlips juvenile', category: 'other_fish', rarity: 3 },

    // 頭足類 (cephalopod)
    { id: 'creature_022', nameJa: 'タコクラゲ', nameEn: 'Mastigias Jellyfish', category: 'cephalopod', rarity: 2 },
    { id: 'creature_031', nameJa: 'ミミックオクトパス', nameEn: 'Mimic Octopus', category: 'cephalopod', rarity: 5 },
    { id: 'creature_037', nameJa: 'ハナイカ', nameEn: 'Flamboyant Cuttlefish', category: 'cephalopod', rarity: 4 },
    { id: 'creature_157', nameJa: 'ワンダーパス', nameEn: 'Wonderpus', category: 'cephalopod', rarity: 5 },

    // 海洋哺乳類 (mammal)
    { id: 'creature_075', nameJa: 'バンドウイルカ', nameEn: 'Bottlenose Dolphin', category: 'mammal', rarity: 3 },
    { id: 'creature_076', nameJa: 'ミナミバンドウイルカ', nameEn: 'Indo-Pacific Bottlenose Dolphin', category: 'mammal', rarity: 3 },
    { id: 'creature_077', nameJa: 'ザトウクジラ', nameEn: 'Humpback Whale', category: 'mammal', rarity: 5 },
    { id: 'creature_078', nameJa: 'マッコウクジラ', nameEn: 'Sperm Whale', category: 'mammal', rarity: 5 },
    { id: 'creature_079', nameJa: 'シャチ', nameEn: 'Orca', category: 'mammal', rarity: 5 },
    { id: 'creature_080', nameJa: 'カマイルカ', nameEn: 'Pacific White-sided Dolphin', category: 'mammal', rarity: 4 },

    // 甲殻類 (crustacean)
    { id: 'creature_083', nameJa: 'ゴシキエビ', nameEn: 'Painted Spiny Lobster', category: 'crustacean', rarity: 3 },
    { id: 'creature_086', nameJa: 'ホワイトソックスシュリンプ', nameEn: 'White-banded Cleaner Shrimp', category: 'crustacean', rarity: 3 },
    { id: 'creature_115', nameJa: 'キンチャクガニ', nameEn: 'Boxer Crab', category: 'crustacean', rarity: 4 },
    { id: 'creature_124', nameJa: 'フリソデエビ', nameEn: 'Harlequin Shrimp', category: 'crustacean', rarity: 4 },
    { id: 'creature_139', nameJa: 'コールマンシュリンプ', nameEn: "Coleman's Shrimp", category: 'crustacean', rarity: 5 },
    { id: 'creature_136', nameJa: 'クダヤギクモエビ', nameEn: 'Skeleton Shrimp', category: 'crustacean', rarity: 4 },

    // ウミウシ (nudibranch)
    { id: 'creature_108', nameJa: 'ピカチュウウミウシ', nameEn: 'Yellow Nudibranch', category: 'nudibranch', rarity: 2 },
  ];

  // 既存データ削除
  console.log('既存のcreaturesコレクションを削除中...');
  const existing = await db.collection('creatures').get();
  const deleteBatch = db.batch();
  existing.docs.forEach(doc => deleteBatch.delete(doc.ref));
  await deleteBatch.commit();
  console.log(`${existing.size} 件削除完了`);

  // 新規投入
  const batchSize = 400;
  for (let i = 0; i < creatures.length; i += batchSize) {
    const batch = db.batch();
    const chunk = creatures.slice(i, i + batchSize);
    for (const creature of chunk) {
      const ref = db.collection('creatures').doc(creature.id);
      batch.set(ref, {
        nameJa: creature.nameJa,
        nameEn: creature.nameEn,
        category: creature.category,
        rarity: creature.rarity,
        isActive: true,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
  console.log(`生物 ${creatures.length} 件投入完了`);
}

async function main() {
  await importCreatures();
  console.log('完了！');
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
