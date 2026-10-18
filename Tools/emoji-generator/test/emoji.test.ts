import { describe, expect, test } from "bun:test";
import {
  generateCategories,
  generateModels,
  parseEmojiTest,
  validateModels,
} from "../src/emoji.ts";

const sample = `# group: People & Body
1F44D ; fully-qualified # 👍 E1.0 thumbs up
1F44D 1F3FB ; fully-qualified # 👍🏻 E1.0 thumbs up: light skin tone
1F44D 1F3FC ; fully-qualified # 👍🏼 E1.0 thumbs up: medium-light skin tone
1F44D 1F3FD ; fully-qualified # 👍🏽 E1.0 thumbs up: medium skin tone
1F44D 1F3FE ; fully-qualified # 👍🏾 E1.0 thumbs up: medium-dark skin tone
1F44D 1F3FF ; fully-qualified # 👍🏿 E1.0 thumbs up: dark skin tone
1F91D ; fully-qualified # 🤝 E14.0 handshake
1F91D 1F3FB ; fully-qualified # 🤝🏻 E14.0 handshake: light skin tone
1F91D 1F3FB 1F3FF ; fully-qualified # 🤝🏻🏿 E14.0 handshake: light skin tone, dark skin tone
1FAF1 1F3FB 200D 1FAF2 1F3FC ; fully-qualified # 🫱🏻‍🫲🏼 E14.0 handshake: light skin tone, medium-light skin tone

# group: Animals & Nature
1F438 ; fully-qualified # 🐸 E1.0 frog

# group: Smileys & Emotion
1FAE0 ; fully-qualified # 🫠 E14.0 melting face
1FAE9 ; fully-qualified # 🫩 E16.0 face with bags under eyes

# group: Component
1F3FB ; fully-qualified # 🏻 E1.0 light skin tone
`;

describe("parseEmojiTest", () => {
  test("maps groups, ignores components, and captures versions", () => {
    const entries = parseEmojiTest(sample);

    expect(entries).toHaveLength(13);
    expect(entries[0].category).toBe("Smileys & People");
    expect(entries[0].baseKey).toBe("👍");
    expect(entries.find((entry) => entry.sequence === "🫩")?.version).toEqual([16, 0]);
  });
});

describe("generateCategories", () => {
  test("groups skin tones and excludes multi-tone combinations", () => {
    const entries = parseEmojiTest(sample);
    const categories = generateCategories(entries, [14, 0]);
    const people = categories.find((category) => category.title === "Smileys & People");

    expect(people?.emojis).toContainEqual(["👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿"]);
    expect(people?.emojis).toContainEqual(["🤝", "🤝🏻"]);
    expect(JSON.stringify(people)).not.toContain("🤝🏻🏿");
  });

  test("keeps a representative for an emoji that only has cross-tone sequences", () => {
    const entries = parseEmojiTest(sample);
    const categories = generateCategories(entries, [14, 0]);
    const people = categories.find((category) => category.title === "Smileys & People");

    expect(people?.emojis).toContainEqual("🫱🏻‍🫲🏼");
  });

  test("filters entries newer than the target version", () => {
    const entries = parseEmojiTest(sample);
    const ios154 = generateCategories(entries, [14, 0]);
    const ios184 = generateCategories(entries, [16, 0]);

    expect(JSON.stringify(ios154)).not.toContain("🫩");
    expect(JSON.stringify(ios184)).toContain("🫩");
  });

  test("keeps every base emoji across cumulative targets", () => {
    const entries = parseEmojiTest(sample);
    const models = generateModels(entries);

    expect(() => validateModels(entries, models)).not.toThrow();
  });
});
