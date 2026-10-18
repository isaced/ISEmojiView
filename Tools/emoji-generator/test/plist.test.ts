import { describe, expect, test } from "bun:test";
import { serializePlist } from "../src/plist.ts";

describe("serializePlist", () => {
  test("escapes XML characters in strings", () => {
    const xml = serializePlist({
      title: "Smileys & People <Flags>",
      emojis: ["😀"],
    });

    expect(xml).toContain("<string>Smileys &amp; People &lt;Flags&gt;</string>");
  });

  test("serializes nested variant arrays", () => {
    const xml = serializePlist([
      {
        title: "Smileys & People",
        emojis: ["👋", ["👋", "👋🏻", "👋🏿"]],
      },
    ]);

    expect(xml).toContain("<string>👋</string>");
    expect(xml).toContain("<string>👋🏻</string>");
    expect(xml).toContain("<string>👋🏿</string>");
    expect(xml).toContain("</array>");
    expect(xml).toContain("</plist>");
  });
});
