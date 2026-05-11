---
name: to-anki
description: "Convert any content into Anki flashcards and add them directly via AnkiConnect. Use this skill when the user provides vocabulary pairs (any language), facts, or knowledge they want turned into flashcards for Anki. Trigger when the user says /to-anki, mentions Anki flashcards, or provides content they want to memorize."
---

# Anki Flashcard Creator

Turn the user's input into flashcards and add them directly to Anki via AnkiConnect (localhost:8765).

## Step 1: Parse the input

This handles two modes:

### Mode 1: Vocabulary / Translation Pairs

The user provides pairs of expressions - typically a foreign language and English. They may be formatted as:
- Alternating lines (foreign language on one line, English on the next, separated by blank lines)
- Separated by hyphens, colons, equals, pipes, arrows, etc.
- Numbered lists

**Front**: foreign language. **Back**: English. Use your knowledge of languages to determine which is which.

**Preserve the user's exact text.** Do not correct spelling, change capitalization, add/remove articles, or modify anything. Copy both sides exactly as written.

Example input:
```
Grazie
Thank you

Prego
You're welcome / go ahead
```

### Mode 2: Facts / Knowledge

The user provides interesting facts, statements, or knowledge they want to memorize. Transform each fact into a question/answer flashcard:
- Front: A natural question that the fact answers
- Back: The concise answer

Keep questions natural and conversational. Keep answers short and direct - just the key fact, not the full sentence restated.

## Step 2: Pick the deck

**Default deck: `1 Everything FRESH`**. Use this unless the user specifies otherwise or the context strongly suggests another deck (e.g., Italian vocab → "1 Italiano"). Don't ask - just add to the default and mention it in the report. The user will redirect if they want a different deck.

If you do need to fetch the deck list:

```bash
curl -s -4 http://127.0.0.1:8765 -d '{"action": "deckNames", "version": 6}'
```

Note: use `-4` and `127.0.0.1` to force IPv4 - another service may be listening on IPv6 port 8765.

## Step 3: Add cards via AnkiConnect

Add each card using the `addNote` action with the "Basic" model:

```bash
curl -s http://localhost:8765 -X POST -d '{
  "action": "addNote",
  "version": 6,
  "params": {
    "note": {
      "deckName": "<chosen deck>",
      "modelName": "Basic",
      "fields": {"Front": "<front text>", "Back": "<back text>"},
      "options": {"allowDuplicate": false}
    }
  }
}'
```

You can batch them using `addNotes` (plural) for efficiency:

```bash
curl -s http://localhost:8765 -X POST -d '{
  "action": "addNotes",
  "version": 6,
  "params": {
    "notes": [
      {
        "deckName": "<chosen deck>",
        "modelName": "Basic",
        "fields": {"Front": "<front>", "Back": "<back>"},
        "options": {"allowDuplicate": false}
      }
    ]
  }
}'
```

Check the response - any `null` entries in the result array mean those cards were duplicates and were skipped.

## Step 4: Report

Tell the user:
- How many cards were added
- How many were skipped as duplicates (if any)
- Which deck they went into

## Fallback

If AnkiConnect is not reachable (Anki not running), fall back to saving a CSV to `~/Downloads/anki_flashcards.csv` (two columns, no headers) and tell the user to import it manually.
