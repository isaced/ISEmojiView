# Emoji List Generator

Generates the `ISEmojiList*.plist` resources in `Sources/ISEmojiView/Assets` from Unicode emoji data.

## Data source

- `data/emoji-test-17.0.txt`
- Source: <https://unicode.org/Public/17.0.0/emoji/emoji-test.txt>
- Version: Unicode 17.0
- SHA-256: `1d8a944f88d7952f7ef7c5167fef3c67995bcae24543949710231b03a201acda`

The Unicode data is subject to the Unicode Terms of Use included in the file header.

## Targets

| iOS | Emoji | Generated file |
| --- | --- | --- |
| 15.4 | 14.0 | `ISEmojiList_iOS15.4.plist` |
| 16.4 | 15.0 | `ISEmojiList_iOS16.4.plist` |
| 17.4 | 15.1 | `ISEmojiList_iOS17.4.plist` |
| 18.4 | 16.0 | `ISEmojiList_iOS18.4.plist` |
| 26.4 | 17.0 | `ISEmojiList.plist` |

## Variant policy

Only fully-qualified sequences are used. Entries are grouped by their sequence with variation
selectors and skin-tone modifiers removed, so a base emoji and its skin-tone variants stay together.

Each group contains the default sequence plus same-tone variants (`🏻🏼🏽🏾🏿`). Combinations with
different tones for different people are intentionally omitted for now to keep the existing popover
layout usable.

## Commands

Run from this directory:

```sh
bun install
bun run generate    # regenerate the plists
bun run check       # verify the committed plists are up to date
bun run validate    # typecheck, tests, and plutil validation
```

Generated plist files must not be edited manually. Update the Unicode source file and the target
mapping in `src/emoji.ts` instead.
