import { DOMParser } from "https://deno.land/x/deno_dom@v0.1.31-alpha/deno-dom-wasm.ts";

const TargetUrls = [
  "https://emojipedia.org/people/",
  "https://emojipedia.org/nature/",
  "https://emojipedia.org/food-drink/",
  "https://emojipedia.org/activity/",
  "https://emojipedia.org/travel-places/",
  "https://emojipedia.org/objects/",
  "https://emojipedia.org/symbols/",
  "https://emojipedia.org/flags/",
];

async function fetchHTML(url: string) {
  const res = await fetch(url);
  return await res.text();
}

function parseEmojis(html: string) {
  const document = new DOMParser().parseFromString(html, "text/html");
  const emojiNodeList = document?.querySelectorAll(".emoji-list li .emoji");
  const emojis: string[] = [];
  emojiNodeList?.forEach((node) => {
    emojis.push(node.textContent);
  });
  return emojis;
}

async function fetchEmojis(url: string) {
  const html = await fetchHTML(url);
  const emojis = parseEmojis(html);
  return emojis;
}

async function main() {
  const emojisList = await Promise.all(
    TargetUrls.map(async (url) => {
      return await fetchEmojis(url);
    })
  );
  Deno.writeTextFile("emojis.json", JSON.stringify(emojisList));
}

await main();
