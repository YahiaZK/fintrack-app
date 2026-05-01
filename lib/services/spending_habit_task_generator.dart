import 'dart:math' as math;

import '../models/transaction_entry.dart';

class GeneratedHabitTask {
  const GeneratedHabitTask({
    required this.id,
    required this.name,
    required this.xp,
    required this.category,
    required this.habitKey,
    required this.itemLabel,
    required this.durationDays,
    required this.score,
    required this.quantity,
    required this.recentCount7,
    required this.recentCount30,
    required this.recentTotal14,
    required this.reason,
  });

  final String id;
  final String name;
  final int xp;
  final String category;
  final String habitKey;
  final String itemLabel;
  final int durationDays;
  final int score;
  final int quantity;
  final int recentCount7;
  final int recentCount30;
  final double recentTotal14;
  final String reason;
}

class SpendingHabitTaskGenerator {
  SpendingHabitTaskGenerator({DateTime Function()? now}) : _now = now;

  final DateTime Function()? _now;

  DateTime get _today => _now?.call() ?? DateTime.now();

  GeneratedHabitTask? buildTask({
    required TransactionEntry transaction,
    required List<TransactionEntry> recentTransactions,
  }) {
    if (transaction.type != TransactionType.expense) return null;

    final signature = _ItemSignature.from(transaction);
    if (signature.tokens.isEmpty && signature.category.isEmpty) return null;
    if (_excludedCategories.contains(signature.category)) return null;

    final similarHistory = recentTransactions
        .where((entry) => entry.id != transaction.id)
        .where((entry) => entry.type == TransactionType.expense)
        .where((entry) => signature.isSimilarTo(_ItemSignature.from(entry)))
        .toList();

    final now = _today;
    final similarWithCurrent = <TransactionEntry>[
      transaction,
      ...similarHistory,
    ];
    final recentCount7 = similarWithCurrent
        .where((entry) => _isOnOrAfter(entry.date, now.subtract(_sevenDays)))
        .length;
    final recentCount30 = similarWithCurrent
        .where((entry) => _isOnOrAfter(entry.date, now.subtract(_thirtyDays)))
        .length;
    final recentTotal14 = similarWithCurrent
        .where((entry) => _isOnOrAfter(entry.date, now.subtract(_fourteenDays)))
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final categoryHistory = recentTransactions
        .where((entry) => entry.type == TransactionType.expense)
        .where(
          (entry) => _normalizeCategory(entry.category) == signature.category,
        )
        .toList();
    final categoryAverage = categoryHistory.isEmpty
        ? 0.0
        : categoryHistory.fold<double>(0, (sum, entry) => sum + entry.amount) /
              categoryHistory.length;

    final quantity = _extractLeadingQuantity(transaction.name);
    final amountScore = _amountScore(transaction.amount, categoryAverage);
    final frequencyScore = _frequencyScore(recentCount7, recentCount30);
    final totalScore = _totalScore(recentTotal14);
    final quantityScore = _quantityScore(quantity);
    final categoryScore = _discretionaryCategories.contains(signature.category)
        ? 1
        : 0;
    final score =
        amountScore +
        frequencyScore +
        totalScore +
        quantityScore +
        categoryScore;
    final threshold = _essentialCategories.contains(signature.category) ? 7 : 5;

    if (score < threshold) return null;

    final itemLabel = _bestDisplayLabel(signature, similarHistory);
    final durationDays = score >= 9 ? 3 : 1;
    final xp = (40 + score * 10).clamp(60, 150).toInt();
    final habitKey = _habitKey(signature, itemLabel);

    return GeneratedHabitTask(
      id: 'habit_$habitKey',
      name: _taskName(
        itemLabel: itemLabel,
        category: signature.category,
        durationDays: durationDays,
      ),
      xp: xp,
      category: signature.category.isEmpty ? 'other' : signature.category,
      habitKey: habitKey,
      itemLabel: itemLabel,
      durationDays: durationDays,
      score: score,
      quantity: quantity,
      recentCount7: recentCount7,
      recentCount30: recentCount30,
      recentTotal14: recentTotal14,
      reason: _reason(
        amount: transaction.amount,
        quantity: quantity,
        recentCount7: recentCount7,
        recentTotal14: recentTotal14,
      ),
    );
  }

  static bool _isOnOrAfter(DateTime value, DateTime cutoff) {
    return value.isAtSameMomentAs(cutoff) || value.isAfter(cutoff);
  }

  static int _amountScore(double amount, double categoryAverage) {
    var score = 0;
    if (amount >= 150) {
      score += 4;
    } else if (amount >= 75) {
      score += 3;
    } else if (amount >= 35) {
      score += 2;
    } else if (amount >= 15) {
      score += 1;
    }

    if (categoryAverage > 0 && amount >= categoryAverage * 1.6) {
      score += 2;
    } else if (categoryAverage > 0 && amount >= categoryAverage * 1.25) {
      score += 1;
    }
    return score;
  }

  static int _frequencyScore(int count7, int count30) {
    if (count7 >= 5) return 5;
    if (count7 >= 3) return 4;
    if (count7 >= 2) return 1;
    if (count30 >= 6) return 3;
    if (count30 >= 4) return 2;
    if (count30 >= 3) return 1;
    return 0;
  }

  static int _totalScore(double total14) {
    if (total14 >= 120) return 3;
    if (total14 >= 60) return 2;
    if (total14 >= 30) return 1;
    return 0;
  }

  static int _quantityScore(int quantity) {
    if (quantity >= 10) return 4;
    if (quantity >= 5) return 2;
    if (quantity >= 3) return 1;
    return 0;
  }

  static int _extractLeadingQuantity(String text) {
    final match = RegExp(r'^\s*(\d{1,3})\b').firstMatch(text);
    if (match == null) return 1;
    final parsed = int.tryParse(match.group(1) ?? '');
    if (parsed == null || parsed < 2 || parsed > 100) return 1;
    return parsed;
  }

  static String _bestDisplayLabel(
    _ItemSignature current,
    List<TransactionEntry> similarHistory,
  ) {
    final currentLabel = current.label.isEmpty
        ? (current.category.isEmpty ? 'this item' : current.category)
        : current.label;
    if (similarHistory.isEmpty) return currentLabel;

    var bestLabel = currentLabel;
    var bestScore = 0.0;
    for (final entry in similarHistory) {
      final signature = _ItemSignature.from(entry);
      final score = current.tokenScore(signature);
      if (score > bestScore && signature.label.length >= bestLabel.length) {
        bestScore = score;
        bestLabel = signature.label;
      }
    }
    return bestLabel.isEmpty ? currentLabel : bestLabel;
  }

  static String _habitKey(_ItemSignature signature, String itemLabel) {
    final labelTokens = _tokensFor(itemLabel);
    final keyTokens = (labelTokens.isEmpty ? signature.tokens : labelTokens)
        .map(_compactSkeleton)
        .where((token) => token.isNotEmpty)
        .toList();
    final raw = '${signature.category}_${keyTokens.join('_')}';
    final cleaned = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (cleaned.isEmpty) return 'other_spending';
    return cleaned.length <= 90 ? cleaned : cleaned.substring(0, 90);
  }

  static String _taskName({
    required String itemLabel,
    required String category,
    required int durationDays,
  }) {
    final days = durationDays == 1 ? '1 day' : '$durationDays days';
    final item = itemLabel.isEmpty ? category : itemLabel;
    if (_essentialCategories.contains(category)) {
      return 'Review $item spending before paying again';
    }
    if (category == 'transport') {
      return 'Try a cheaper option than $item for $days';
    }
    return 'Avoid buying $item for $days';
  }

  static String _reason({
    required double amount,
    required int quantity,
    required int recentCount7,
    required double recentTotal14,
  }) {
    final parts = <String>[];
    if (quantity >= 3) parts.add('quantity $quantity');
    if (amount >= 35) parts.add('single spend ${amount.toStringAsFixed(2)}');
    if (recentCount7 >= 2) parts.add('$recentCount7 similar spends in 7 days');
    if (recentTotal14 >= 30) {
      parts.add('${recentTotal14.toStringAsFixed(2)} spent in 14 days');
    }
    return parts.isEmpty
        ? 'spending pattern crossed the habit threshold'
        : parts.join(', ');
  }
}

class _ItemSignature {
  const _ItemSignature({
    required this.category,
    required this.tokens,
    required this.label,
  });

  final String category;
  final List<String> tokens;
  final String label;

  factory _ItemSignature.from(TransactionEntry entry) {
    final category = _normalizeCategory(entry.category);
    var tokens = _tokensFor(entry.name);
    if (tokens.isEmpty) tokens = _tokensFor(category);
    return _ItemSignature(
      category: category,
      tokens: tokens,
      label: _labelFor(tokens, category),
    );
  }

  bool isSimilarTo(_ItemSignature other) {
    if (tokens.isEmpty || other.tokens.isEmpty) {
      return category.isNotEmpty && category == other.category;
    }
    final score = tokenScore(other);
    if (category.isNotEmpty &&
        other.category.isNotEmpty &&
        category != other.category) {
      return score >= 0.78;
    }
    return score >= 0.5 || _hasCloseToken(tokens, other.tokens);
  }

  double tokenScore(_ItemSignature other) {
    if (tokens.isEmpty || other.tokens.isEmpty) return 0;
    var matched = 0;
    for (final token in tokens) {
      if (other.tokens.any(
        (otherToken) => _tokensAreClose(token, otherToken),
      )) {
        matched++;
      }
    }
    return matched / math.max(tokens.length, other.tokens.length);
  }

  static bool _hasCloseToken(List<String> left, List<String> right) {
    for (final a in left) {
      if (a.length < 3) continue;
      for (final b in right) {
        if (b.length < 3) continue;
        if (_tokensAreClose(a, b)) return true;
      }
    }
    return false;
  }
}

const _sevenDays = Duration(days: 7);
const _fourteenDays = Duration(days: 14);
const _thirtyDays = Duration(days: 30);

const _discretionaryCategories = {
  'food',
  'shopping',
  'entertainment',
  'travel',
  'transport',
  'other',
};

const _essentialCategories = {'bills', 'health', 'education', 'home'};

const _excludedCategories = {'income', 'salary', 'savings'};

const _stopWords = {
  'a',
  'an',
  'and',
  'at',
  'bought',
  'buy',
  'for',
  'from',
  'got',
  'in',
  'new',
  'of',
  'on',
  'paid',
  'payment',
  'spent',
  'the',
  'to',
  'with',
};

String _normalizeCategory(String category) {
  return category.trim().toLowerCase();
}

List<String> _tokensFor(String text) {
  final matches = RegExp(r'[a-z0-9]+').allMatches(text.toLowerCase());
  final tokens = <String>[];
  for (final match in matches) {
    final raw = match.group(0);
    if (raw == null || raw.isEmpty) continue;
    if (RegExp(r'^\d+$').hasMatch(raw)) continue;
    if (_stopWords.contains(raw)) continue;
    final token = _singularize(raw);
    if (token.length < 2 || _stopWords.contains(token)) continue;
    tokens.add(token);
  }
  return tokens;
}

String _labelFor(List<String> tokens, String category) {
  if (tokens.isEmpty) return category;
  return tokens.take(4).join(' ');
}

String _singularize(String token) {
  if (token.length > 4 && token.endsWith('ies')) {
    return '${token.substring(0, token.length - 3)}y';
  }
  if (token.length > 4 && token.endsWith('sses')) {
    return token.substring(0, token.length - 2);
  }
  if (token.length > 3 && token.endsWith('s')) {
    return token.substring(0, token.length - 1);
  }
  return token;
}

bool _tokensAreClose(String left, String right) {
  if (left == right) return true;
  final leftSkeleton = _skeleton(left);
  final rightSkeleton = _skeleton(right);
  if (leftSkeleton.length >= 3 && leftSkeleton == rightSkeleton) return true;

  final maxLength = math.max(left.length, right.length);
  if (maxLength < 4) return false;
  final similarity = 1 - (_editDistance(left, right) / maxLength);
  return similarity >= (maxLength <= 5 ? 0.72 : 0.68);
}

String _skeleton(String token) {
  final consonants = token.replaceAll(RegExp(r'[aeiou]'), '');
  return consonants.isEmpty ? token : consonants;
}

String _compactSkeleton(String token) {
  final skeleton = _skeleton(token);
  if (skeleton.isEmpty) return skeleton;
  final buffer = StringBuffer(skeleton[0]);
  for (var i = 1; i < skeleton.length; i++) {
    if (skeleton[i] != skeleton[i - 1]) buffer.write(skeleton[i]);
  }
  return buffer.toString();
}

int _editDistance(String left, String right) {
  if (left == right) return 0;
  if (left.isEmpty) return right.length;
  if (right.isEmpty) return left.length;

  var previous = List<int>.generate(right.length + 1, (i) => i);
  for (var i = 0; i < left.length; i++) {
    final current = List<int>.filled(right.length + 1, 0);
    current[0] = i + 1;
    for (var j = 0; j < right.length; j++) {
      final cost = left.codeUnitAt(i) == right.codeUnitAt(j) ? 0 : 1;
      current[j + 1] = math.min(
        math.min(current[j] + 1, previous[j + 1] + 1),
        previous[j] + cost,
      );
    }
    previous = current;
  }
  return previous[right.length];
}
