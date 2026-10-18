export type EmojiVersion = readonly [major: number, minor: number];

export interface Target {
  ios: string;
  emoji: string;
  file: string;
}

export interface ParsedEmoji {
  category: string;
  sequence: string;
  baseKey: string;
  tones: string[];
  version: EmojiVersion;
  order: number;
}

export interface CategoryData {
  title: string;
  emojis: Array<string | string[]>;
}

export interface EmojiModel {
  target: Target;
  categories: CategoryData[];
}

export const UNICODE_DATA_VERSION = "17.0";
export const UNICODE_DATA_FILE = "emoji-test-17.0.txt";

export const SKIN_TONES = ["🏻", "🏼", "🏽", "🏾", "🏿"] as const;

const SKIN_TONE_SET = new Set<string>(SKIN_TONES);
const VARIATION_SELECTOR_16 = "\uFE0F";

export const CATEGORY_ORDER = [
  "Smileys & People",
  "Animals & Nature",
  "Food & Drink",
  "Activity",
  "Travel & Places",
  "Objects",
  "Symbols",
  "Flags",
] as const;

export const GROUP_TO_CATEGORY: Record<string, string> = {
  "Smileys & Emotion": "Smileys & People",
  "People & Body": "Smileys & People",
  "Animals & Nature": "Animals & Nature",
  "Food & Drink": "Food & Drink",
  "Travel & Places": "Travel & Places",
  Activities: "Activity",
  Objects: "Objects",
  Symbols: "Symbols",
  Flags: "Flags",
};

export const TARGETS: Target[] = [
  { ios: "15.4", emoji: "14.0", file: "ISEmojiList_iOS15.4.plist" },
  { ios: "16.4", emoji: "15.0", file: "ISEmojiList_iOS16.4.plist" },
  { ios: "17.4", emoji: "15.1", file: "ISEmojiList_iOS17.4.plist" },
  { ios: "18.4", emoji: "16.0", file: "ISEmojiList_iOS18.4.plist" },
  { ios: "26.4", emoji: "17.0", file: "ISEmojiList.plist" },
];

export function parseVersion(value: string): EmojiVersion {
  const match = /^(\d+)\.(\d+)$/.exec(value);
  if (!match) {
    throw new Error(`Invalid emoji version: ${value}`);
  }

  return [Number(match[1]), Number(match[2])];
}

export function compareVersions(a: EmojiVersion, b: EmojiVersion): number {
  return a[0] - b[0] || a[1] - b[1];
}

export function groupingKey(sequence: string): string {
  return Array.from(sequence)
    .filter((character) => !SKIN_TONE_SET.has(character) && character !== VARIATION_SELECTOR_16)
    .join("");
}

function uniqueTones(sequence: string): string[] {
  const tones = new Set<string>();

  for (const character of sequence) {
    if (SKIN_TONE_SET.has(character)) {
      tones.add(character);
    }
  }

  return [...tones];
}

function parseEmojiVersion(comment: string): EmojiVersion {
  const match = /\bE(\d+\.\d+)\b/.exec(comment);
  if (!match) {
    throw new Error(`Missing emoji version in: ${comment}`);
  }

  return parseVersion(match[1]);
}

export function parseEmojiTest(text: string): ParsedEmoji[] {
  const entries: ParsedEmoji[] = [];
  let group: string | undefined;
  let order = 0;

  for (const line of text.split(/\r?\n/)) {
    const groupMatch = /^# group: (.+)$/.exec(line);
    if (groupMatch) {
      group = groupMatch[1].trim();
      continue;
    }

    if (line.length === 0 || line.startsWith("#")) {
      continue;
    }

    const commentIndex = line.indexOf("#");
    if (commentIndex === -1) {
      continue;
    }

    const [codePointsPart, statusPart] = line
      .slice(0, commentIndex)
      .split(";")
      .map((part) => part.trim());

    if (statusPart !== "fully-qualified") {
      continue;
    }

    if (!group) {
      throw new Error("Found an emoji before a group header");
    }

    if (group === "Component") {
      continue;
    }

    const category = GROUP_TO_CATEGORY[group];
    if (!category) {
      throw new Error(`Unmapped emoji group: ${group}`);
    }

    const codePoints = codePointsPart.split(/\s+/);
    const sequence = codePoints
      .map((codePoint) => String.fromCodePoint(Number.parseInt(codePoint, 16)))
      .join("");

    entries.push({
      category,
      sequence,
      baseKey: groupingKey(sequence),
      tones: uniqueTones(sequence),
      version: parseEmojiVersion(line.slice(commentIndex + 1)),
      order: order++,
    });
  }

  return entries;
}

function selectVariants(entries: ParsedEmoji[]): string[] {
  const uniqueSequences = new Map<string, ParsedEmoji>();

  for (const entry of entries) {
    if (!uniqueSequences.has(entry.sequence)) {
      uniqueSequences.set(entry.sequence, entry);
    }
  }

  const candidates = [...uniqueSequences.values()];
  const variants: string[] = [];
  const defaultEntry = candidates
    .filter((entry) => entry.tones.length === 0)
    .sort((a, b) => a.order - b.order)[0];

  if (defaultEntry) {
    variants.push(defaultEntry.sequence);
  }

  for (const tone of SKIN_TONES) {
    const toneEntry = candidates
      .filter((entry) => entry.tones.length === 1 && entry.tones[0] === tone)
      .sort((a, b) => a.order - b.order)[0];

    if (toneEntry && !variants.includes(toneEntry.sequence)) {
      variants.push(toneEntry.sequence);
    }
  }

  if (variants.length === 0 && candidates.length > 0) {
    variants.push(
      candidates.sort((a, b) => a.order - b.order)[0].sequence,
    );
  }

  return variants;
}

export function generateCategories(
  entries: ParsedEmoji[],
  targetVersion: EmojiVersion,
): CategoryData[] {
  const grouped = new Map<string, Map<string, ParsedEmoji[]>>();

  for (const title of CATEGORY_ORDER) {
    grouped.set(title, new Map());
  }

  for (const entry of entries) {
    if (compareVersions(entry.version, targetVersion) > 0) {
      continue;
    }

    const categoryGroups = grouped.get(entry.category);
    if (!categoryGroups) {
      throw new Error(`Unknown category: ${entry.category}`);
    }

    const groupEntries = categoryGroups.get(entry.baseKey) ?? [];
    groupEntries.push(entry);
    categoryGroups.set(entry.baseKey, groupEntries);
  }

  return CATEGORY_ORDER.map((title) => {
    const categoryGroups = grouped.get(title);
    if (!categoryGroups) {
      throw new Error(`Unknown category: ${title}`);
    }

    const items = [...categoryGroups.values()]
      .map((groupEntries) => ({
        order: Math.min(...groupEntries.map((entry) => entry.order)),
        variants: selectVariants(groupEntries),
      }))
      .filter((item) => item.variants.length > 0)
      .sort((a, b) => a.order - b.order);

    return {
      title,
      emojis: items.map((item) =>
        item.variants.length === 1 ? item.variants[0] : item.variants
      ),
    };
  });
}

export function generateModels(entries: ParsedEmoji[]): EmojiModel[] {
  return TARGETS.map((target) => ({
    target,
    categories: generateCategories(entries, parseVersion(target.emoji)),
  }));
}

function baseKeysForTarget(
  entries: ParsedEmoji[],
  targetVersion: EmojiVersion,
): Set<string> {
  return new Set(
    entries
      .filter((entry) => compareVersions(entry.version, targetVersion) <= 0)
      .map((entry) => entry.baseKey),
  );
}

export function validateModels(entries: ParsedEmoji[], models: EmojiModel[]): void {
  let previousBaseKeys = new Set<string>();

  for (const model of models) {
    const targetVersion = parseVersion(model.target.emoji);
    const baseKeys = baseKeysForTarget(entries, targetVersion);

    for (const baseKey of previousBaseKeys) {
      if (!baseKeys.has(baseKey)) {
        throw new Error(
          `${model.target.file} is missing a base emoji from an older target: ${baseKey}`,
        );
      }
    }

    if (model.categories.length !== CATEGORY_ORDER.length) {
      throw new Error(`${model.target.file} has an unexpected number of categories`);
    }

    const seenSequences = new Set<string>();
    const modelBaseKeys = new Set<string>();

    for (const category of model.categories) {
      if (!CATEGORY_ORDER.includes(category.title as (typeof CATEGORY_ORDER)[number])) {
        throw new Error(`${model.target.file} has an unknown category: ${category.title}`);
      }

      for (const item of category.emojis) {
        const variants = typeof item === "string" ? [item] : item;

        if (variants.length === 0) {
          throw new Error(`${model.target.file} contains an empty emoji entry`);
        }

        for (const sequence of variants) {
          if (seenSequences.has(sequence)) {
            throw new Error(`${model.target.file} contains a duplicate sequence: ${sequence}`);
          }
          if (sequence.length === 0) {
            throw new Error(`${model.target.file} contains an empty sequence`);
          }
          seenSequences.add(sequence);
        }

        modelBaseKeys.add(groupingKey(variants[0]));
      }
    }

    for (const baseKey of baseKeys) {
      if (!modelBaseKeys.has(baseKey)) {
        throw new Error(`${model.target.file} is missing base emoji: ${baseKey}`);
      }
    }

    previousBaseKeys = baseKeys;
  }
}
