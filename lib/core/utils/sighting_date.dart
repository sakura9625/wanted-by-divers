import 'package:cloud_firestore/cloud_firestore.dart';

/// sightingsドキュメントの日付を扱う共通ロジック。
///
/// dateはクローラー由来の文字列（ISO形式）、ユーザー投稿はTimestampで入る。
/// パースできない場合はnullを返す（呼び出し側でフォールバックする）。
DateTime? parseSightingDate(dynamic date) {
  if (date is Timestamp) return date.toDate();
  if (date is DateTime) return date;
  if (date is String) return DateTime.tryParse(date.replaceAll('/', '-'));
  return null;
}

/// 並び替え用の日付。目撃日（date）を優先し、なければ登録日時（createdAt）を使う。
/// どちらも取れない場合は最古扱いにして末尾に並べる。
DateTime sightingDate(Map<String, dynamic> s) =>
    parseSightingDate(s['date']) ??
    parseSightingDate(s['createdAt']) ??
    DateTime(2000);
