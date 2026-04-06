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

## Step 2: Ask which deck

Use the AnkiConnect API to fetch available decks:

```bash
curl -s http://localhost:8765 -X POST -d '{"action": "deckNames", "version": 6}'
```

Then ask the user which deck to add the cards to. Show them the list. If the context makes it obvious (e.g., Italian vocab probably goes in "Italiano"), suggest the deck but still confirm.

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
