import * as _ from "https://deno.land/x/lodash@4.17.15-es/lodash.js";

const emojisJson = await Deno.readTextFile("emojis.json");
const emojis = JSON.parse(emojisJson) as [string[]];

const emojiList: string[] = [].concat(...emojis);
console.log(emojiList.length);

const emojiTones = emojiList.map((emoji) => {
  const emojiTone = emoji + "🏿";
  const log = `emoji: ${emoji}|${emojiTone}, length: ${emoji.length}|${emojiTone.length}, char: ${
    Array(emoji)?.length
  }|${Array(emojiTone).length}`;
  return log;
});

// json pretty
await Deno.writeTextFile("log.txt", JSON.stringify(emojiTones, null, 2));
