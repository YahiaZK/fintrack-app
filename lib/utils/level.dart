const int xpPerLevel = 1000;

int levelFromXp(int xp) => xp ~/ xpPerLevel + 1;

int xpIntoLevel(int xp) => xp % xpPerLevel;

double progressInLevel(int xp) => xpIntoLevel(xp) / xpPerLevel;

int xpToNextLevel(int xp) => xpPerLevel - xpIntoLevel(xp);
