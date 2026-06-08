# TODO — Future features

> All the items listed here have been **implemented**. The section is kept as a
> history; add new ideas for upcoming versions below.

## Teleprompter
- [x] **Mirror mode** (horizontal/vertical flip) for use with a teleprompter glass.
- [x] **Constant-speed autoscroll** as an alternative/complement to the voice (with speed adjustment).
- [x] **Manual scroll-speed adjustment** and margin/position of the "reading line".
- [x] **Tap a word** to manually reposition the reading point.
- [x] Word count / estimated reading time.

## Script management
- [x] **Export/share** prompts (`.md` file or system share sheet).
- [x] **Import** existing Markdown files.
- [x] **Duplicate** prompt.
- [x] Search and sorting in the list.
- [x] Folders/tags to organize prompts. _(implemented as tags + filter)_

## Editor
- [x] Side-by-side Markdown preview.
- [x] Optional extended formatting (links, code) while keeping Markdown saving.

## Quality / platform
- [x] End-to-end widget tests (with storage and voice mocks).
- [x] Dark theme for the whole app (beyond the teleprompter view).
- [x] Backup/restore of local data.
- [x] Multilingual UI (English/Italian) via `gen_l10n` internationalization.

## Future ideas
- [ ] Hierarchical folders (beyond flat tags).
- [ ] Optional cloud sync of prompts.
- [ ] Rendered Markdown preview (not just source) next to the editor.

## Known issues / possible improvements
- [ ] **Speech recognition watchdog.** Continuous dictation now self-heals when
  a session ends or hits a transient error (delayed, de-duplicated restart in
  `lib/services/speech_service.dart`). One rare case remains: the native engine
  stays in the `listening` state but stops producing results without emitting
  any error. It currently recovers within ~30s via the `pauseFor` silence
  timeout (or 5 min via `listenFor`). A watchdog timer that forces a restart
  after N seconds with no new words would make recovery near-instant.
