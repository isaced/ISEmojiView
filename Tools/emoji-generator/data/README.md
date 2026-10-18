# Unicode Emoji Test Data

`emoji-test-17.0.txt` is an unmodified copy of:

- Source: <https://unicode.org/Public/17.0.0/emoji/emoji-test.txt>
- Unicode version: 17.0
- File date: 2025-08-04
- SHA-256: `1d8a944f88d7952f7ef7c5167fef3c67995bcae24543949710231b03a201acda`

The file header contains the Unicode copyright and Terms of Use. The generated plist files
derive from this data.

To update the emoji data:

1. Download a new `emoji-test.txt` from Unicode and replace this file, keeping the version in the
   file name.
2. Update `UNICODE_DATA_VERSION`, `UNICODE_DATA_FILE`, and `UNICODE_DATA_SOURCE` in `src/emoji.ts`.
3. Update the iOS target mapping in `TARGETS`.
4. Run `bun run generate` and `bun run validate`.
