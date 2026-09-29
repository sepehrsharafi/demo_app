---
version: 1
slug: "lib-app-dart"
primary_target: "lib/app.dart"
related_targets: ["lib/features"]
---

# Mother AI app (all tabs)

Scope: the whole native app (Home, Chat history, Chat, Learn, Article reader, Profile, sheets). Mode: Operate (Article reader is Read).
Audience/job: a parent asks a question about a child and gets calm guidance, told plainly whether it is home care or needs a professional.
Constraints: light theme; shadcn_ui themed, Lucide icons; demo data only; logo and Learn photos kept; hairline-separated rows, not boxed cards (user, 29 Sep 2026); topics frame a question, never write it; in-app Learn articles name no outside institution, and some Learn items are marked links to other websites (user, 29 Sep 2026, superseding the earlier no-outside-sites rule).
Memorable moment: Home opens on a lavender morning with leaves that lean in while the parent types.

## Direction contract

THESIS: Brief-pinned by the user's reference screenshot (29 Sep 2026): a soft, warm lavender companion rather than the ink "Care Signal" field. Care colours still mean care level only. Refuses boxed card stacks and tracked eyebrow labels.

OWN-WORLD: Milk ground #FFFCF9 (the brand's icon field), lavender mist wash under Home's hero with drawn botanical leaves, plum-ink text, lavender violet as Mother AI's voice (send, sparkle, active tab), five topic hues taken from the logo's gradient (rose, peach, sky, lavender, orchid) as small tinted icon squares. White composer with a hairline and one soft lavender shadow, the only resting elevation. Urbanist headlines, Geist UI, 1px warm hairlines.

STORY: The parent sees who the question is about, reads one warm question, types in their own words or starts from a topic, and can pick up yesterday's conversation or something to read for their child's age.

FIRST VIEWPORT: Home. Child switcher pill top-left on the lavender wash, leaves bleeding off the top-right. Headline "What's on your mind about Emma?" at display scale, a one-line greeting-and-promise under it, the white composer with sparkle and violet send, then "Start from a topic" tiles, then "Continue where you left off" row.

FORM: Pinned by the user's reference; no concept roll (a brief-pinned direction beats the roll). Raises over the reference: topics sit under the composer they frame; "Popular" becomes "Start from a topic" (no invented popularity); eyebrow folded into the subline; photo on the continue row replaced by the conversation's topic square and care pill (no fake imagery).

Signature interaction: the leaves sway in on arrival, lean in and breathe while the composer has focus, rustle on each keystroke, and re-tint to the child's hue when the child changes, then come to rest.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Recorded adaptations

- iOS/macOS keep the native Cupertino push; the weighted-sheet push runs elsewhere.
- Tab bar is a floating island (user, 29 Sep 2026, superseding the docked bar); the open tab is a solid violet pill with its label, same motion.
- 29 Sep 2026: splash is the centred mark on milk everywhere (no full-bleed image); Hero photos fly beneath the island; the page behind a sheet recedes as a snapshot; the headline changes only the name, which rolls letter by letter.
- Primary buttons stay ink (now plum-ink); violet is Mother AI's voice.
- A chat's child is fixed once the first question is sent.
- Supersedes (29 Sep 2026): the ink hero and circles-of-care rings on Home.
- 29 Sep 2026, low-end phone lag: fades on flat grounds use GroundVeil; sheets rise on their route clock (SheetRise); the toast is our own overlay with a cushion arrival and ease-in-out exit; attachments sit inside the composer; Learn gained search, topic filter, lead with arrow, link rows and an ask-instead empty state that pre-fills (never sends) the chat.
