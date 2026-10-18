import {
  generateModels,
  parseEmojiTest,
  UNICODE_DATA_FILE,
  UNICODE_DATA_SOURCE,
  UNICODE_DATA_VERSION,
  validateModels,
} from "./emoji.ts";
import { serializePlist, type PlistValue } from "./plist.ts";

const sourceURL = new URL(`../data/${UNICODE_DATA_FILE}`, import.meta.url);
const assetsURL = new URL("../../../Sources/ISEmojiView/Assets/", import.meta.url);
const checkOnly = process.argv.includes("--check");

const source = await Bun.file(sourceURL).text();

if (!source.includes(`# Version: ${UNICODE_DATA_VERSION}`)) {
  throw new Error(`Expected ${UNICODE_DATA_FILE} to contain Unicode ${UNICODE_DATA_VERSION}`);
}

const entries = parseEmojiTest(source);
const models = generateModels(entries);
validateModels(entries, models);

for (const model of models) {
  const value = model.categories.map((category) => ({
    title: category.title,
    emojis: category.emojis,
  })) as PlistValue;

  const xml = serializePlist(
    value,
    `Generated from ${UNICODE_DATA_SOURCE} (Unicode ${UNICODE_DATA_VERSION}). Do not edit.`,
  );
  const outputURL = new URL(model.target.file, assetsURL);

  if (checkOnly) {
    if (!(await Bun.file(outputURL).exists())) {
      throw new Error(`Missing generated file: ${outputURL.pathname}`);
    }

    const currentXML = await Bun.file(outputURL).text();
    if (currentXML !== xml) {
      throw new Error(`Generated file is out of date: ${outputURL.pathname}`);
    }
  } else {
    await Bun.write(outputURL, xml);
  }

  const entryCount = model.categories.reduce(
    (count, category) => count + category.emojis.length,
    0,
  );

  console.log(
    `${model.target.file} (iOS ${model.target.ios}, Emoji ${model.target.emoji}): ${entryCount} entries`,
  );
}
