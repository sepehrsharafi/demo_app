---
name: Mother AI
description: A calm companion that answers a parent's question and says plainly how much help it needs.
colors:
  ground: "#FFFCF9"
  white: "#FFFFFF"
  panel: "#F5F0F7"
  accent-fill: "#EEE7F2"
  line: "#EAE3EC"
  ink: "#1F1B3D"
  muted: "#6B6781"
  voice: "#7B57DB"
  voice-tint: "#F1EBFD"
  voice-deep: "#6A45CC"
  mist: "#F3EDFB"
  leaf: "#E9E0F9"
  destructive: "#D92D40"
  care-home: "#00A86B"
  care-home-tint: "#E2F5EC"
  care-home-deep: "#006B45"
  care-gp: "#FFA412"
  care-gp-tint: "#FFF0D9"
  care-gp-deep: "#8A5200"
  care-urgent: "#F2384A"
  care-urgent-tint: "#FFE4E7"
  care-urgent-deep: "#B0142A"
  topic-health-tint: "#FCE8EF"
  topic-health-tone: "#B8436A"
  topic-feeding-tint: "#FDEDE3"
  topic-feeding-tone: "#B45A2E"
  topic-sleep-tint: "#E7EEFB"
  topic-sleep-tone: "#3F66B8"
  topic-growth-tint: "#EFE9FC"
  topic-growth-tone: "#7050C8"
  topic-behaviour-tint: "#F6E8F8"
  topic-behaviour-tone: "#9444A8"
  child-emma: "#C23F84"
  child-emma-tint: "#FBEAF3"
  child-daniel: "#3462D6"
  child-daniel-tint: "#E8EEFD"
typography:
  display:
    fontFamily: "Urbanist, sans-serif"
    fontSize: "36px"
    fontWeight: 700
    lineHeight: 1.04
    letterSpacing: "-1.1px"
  title:
    fontFamily: "Urbanist, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.12
    letterSpacing: "-0.5px"
  section:
    fontFamily: "Geist, sans-serif"
    fontSize: "17px"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.3px"
  row-title:
    fontFamily: "Geist, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "-0.2px"
  body:
    fontFamily: "Geist, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "-0.1px"
  secondary:
    fontFamily: "Geist, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontFamily: "Geist, sans-serif"
    fontSize: "13px"
    fontWeight: 600
    lineHeight: 1.2
  figure:
    fontFamily: "Geist, sans-serif"
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.2
    fontFeature: "\"tnum\""
rounded:
  tail: "6px"
  square: "10px"
  sm: "12px"
  md: "14px"
  tile: "16px"
  thumb: "18px"
  lg: "20px"
  sheet: "24px"
  composer: "26px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  gutter: "24px"
  section: "36px"
  tab-clearance: "128px"
components:
  button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.white}"
    typography: "{typography.row-title}"
    rounded: "{rounded.md}"
    padding: "0 18px"
    height: "44px"
  button-primary-sm:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.white}"
    rounded: "{rounded.md}"
    padding: "0 14px"
    height: "36px"
  button-primary-lg:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.white}"
    rounded: "{rounded.md}"
    padding: "0 22px"
    height: "52px"
  button-outline:
    backgroundColor: "{colors.ground}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "0 22px"
    height: "52px"
  button-link:
    textColor: "{colors.voice-deep}"
    padding: "0"
    height: "32px"
  button-care-urgent:
    backgroundColor: "{colors.care-urgent-deep}"
    textColor: "{colors.white}"
    rounded: "{rounded.md}"
    height: "44px"
  button-care-gp:
    backgroundColor: "{colors.care-gp-deep}"
    textColor: "{colors.white}"
    rounded: "{rounded.md}"
    height: "44px"
  ask-composer:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.composer}"
    padding: "6px 6px 6px 18px"
    height: "56px"
  ask-composer-raised:
    backgroundColor: "{colors.white}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.composer}"
    padding: "6px 6px 6px 16px"
    height: "56px"
  send-button:
    backgroundColor: "{colors.voice}"
    textColor: "{colors.white}"
    rounded: "{rounded.pill}"
    size: "44px"
  send-button-idle:
    backgroundColor: "{colors.voice-tint}"
    textColor: "{colors.voice}"
    rounded: "{rounded.pill}"
    size: "44px"
  topic-tile:
    backgroundColor: "{colors.ground}"
    textColor: "{colors.ink}"
    rounded: "{rounded.tile}"
    padding: "5px 8px 5px 5px"
  topic-tile-selected:
    backgroundColor: "{colors.voice-tint}"
    textColor: "{colors.voice-deep}"
    rounded: "{rounded.tile}"
    padding: "5px 8px 5px 5px"
  topic-square:
    backgroundColor: "{colors.topic-health-tint}"
    textColor: "{colors.topic-health-tone}"
    rounded: "{rounded.square}"
    size: "34px"
  child-pill:
    backgroundColor: "{colors.white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
    padding: "5px 14px 5px 5px"
  search-input:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "12px 14px"
  care-strip-urgent:
    backgroundColor: "{colors.care-urgent-tint}"
    textColor: "{colors.care-urgent-deep}"
    rounded: "{rounded.sm}"
    padding: "8px 14px 8px 10px"
  care-pill-home:
    backgroundColor: "{colors.care-home-tint}"
    textColor: "{colors.care-home-deep}"
    rounded: "{rounded.pill}"
    padding: "3px 9px 3px 7px"
  question-bubble:
    backgroundColor: "{colors.mist}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.lg}"
    padding: "12px 16px"
    width: "420px"
  continue-square:
    backgroundColor: "{colors.topic-health-tint}"
    textColor: "{colors.topic-health-tone}"
    rounded: "{rounded.thumb}"
    size: "64px"
  stage-panel:
    backgroundColor: "{colors.child-emma-tint}"
    textColor: "{colors.ink}"
    rounded: "{rounded.sheet}"
    padding: "22px 22px 20px 22px"
  nav-bar:
    backgroundColor: "{colors.ground}"
    textColor: "{colors.muted}"
    height: "64px"
  nav-bar-active:
    backgroundColor: "{colors.voice}"
    textColor: "{colors.white}"
    rounded: "{rounded.pill}"
    height: "44px"
  settings-row:
    backgroundColor: "{colors.ground}"
    textColor: "{colors.ink}"
    padding: "10px 0"
    height: "52px"
  child-monogram:
    backgroundColor: "{colors.child-emma-tint}"
    textColor: "{colors.child-emma}"
    rounded: "{rounded.pill}"
    size: "36px"
---

# Design System: Mother AI

## Overview

**Creative North Star: "The Lavender Morning"**

Mother AI is a soft, warm companion. The interface is plum ink on a milk ground, the same field the app icon sits on. Lavender is Mother AI's own colour, and the lavender morning on Home is the one place it spreads into a mood. The world is set by the user's reference screenshot (29 Sep 2026) and applies to every screen. It replaces the ink "Care Signal" field, the circles-of-care rings and the cool white ground.

Home opens on that morning. A mist wash runs up under the status bar and fades into the milk ground below the composer. A sprig of drawn leaves reaches in from the trailing edge and bleeds off the top. The leaves move only when something happens. They sway in as Home appears, lean in and breathe while the composer has focus, rustle on each keystroke, and re-tint toward the child's hue when the child changes. Then they come to rest. Everything under the morning is ink on milk: open rows closed by warm hairlines, one tone panel for the child's stage, and photos only where Learn supplies them.

Warmth does not blur meaning. Green, amber and red still mean care level and nothing else. Violet is still Mother AI speaking. Each child keeps a hue of their own, and each topic carries one of the logo's soft hues (rose, peach, sky, lavender, orchid), so none of them can be mistaken for a care signal. The density is relaxed. Each screen has one obvious action, and motion is quick off the mark with a long settle and no overshoot.

**Key Characteristics:**
- Plum ink on milk, with lavender reserved for Mother AI's voice and Home's morning.
- Drawn leaves on Home's mist wash that move on events and then stop.
- Open rows with 1px warm hairlines. Lists are never boxed into cards.
- One resting shadow in the app: Home's raised composer.
- One Urbanist display headline per screen. Everything read or tapped is Geist, and numbers use tabular figures.
- One motion curve (cubic-bezier(0.16, 1, 0.3, 1)), and every animation has a reduced-motion path.

## Colors

Warm neutrals run the interface. Lavender belongs to Mother AI. Every saturated hue stands for exactly one kind of thing: a care level, a topic or a child.

### Primary
- **Plum Ink** (ink): All text, primary buttons, the profile avatar and the ground a page recedes onto behind a sheet. It holds 16.0:1 on milk and 14.3:1 on mist.

### Secondary
- **Lavender Voice** (voice): Mother AI itself. It fills the send button once there is something to send, the composer's sparkle, the typing dots, the answer step numbers, the chosen topic's square and edge, the active tab pill, switch tracks, the focus ring and the cursor. White on violet holds 4.97:1.
- **Voice Mist** (voice-tint): The idle send button (violet arrow on tint), the chosen topic tile's fill and the toast's countdown track.
- **Deep Voice** (voice-deep): Violet text on milk (6.2:1), used for "See all", the chosen topic's label (5.4:1 on voice-tint) and "your family" in the headline when no child is chosen. It is also the send button's hover fill.

### Tertiary: the care triads
Each level has three roles. The signal hue fills the 28px icon disc and the 7px dot. The tint is the strip's field. The deep shade sets text on the tint and fills the action button.
- **Jade** (care-home, care-home-tint, care-home-deep): Fine to handle at home. Deep on tint is 5.8:1.
- **Signal Amber** (care-gp, care-gp-tint, care-gp-deep): Call your GP or health visitor today. Deep on tint is 5.7:1, and white on deep is 6.4:1.
- **Signal Red** (care-urgent, care-urgent-tint, care-urgent-deep): Get urgent help now. Deep on tint is 5.9:1, and white on deep is 7.1:1.

### Topic hues
Five pairs taken from the logo's gradient: Health rose, Feeding peach, Sleep sky, Growth lavender and Behaviour orchid. The tint fills a topic's icon square, and the tone sets its Lucide icon. They mark topics only, on the topic tiles and on the "Continue where you left off" square. The tones sit between 4.1:1 and 4.9:1 on their own tints.

### Child hues
**Emma Rose** (child-emma, child-emma-tint) and **Daniel Cobalt** (child-daniel, child-daniel-tint) are the demo family's values. The rule behind them is durable: every child carries a hue and a pale tint. The tint fills their monogram and Home's stage panel. The hue sets their initial, their name in Home's headline (Emma 4.2:1 and Daniel 4.7:1 on mist, both at display size), the age in the stage panel, the panel's dots and sprig, and the "About Daniel" line in a chat header. The morning's leaves blend 6 to 8% of the hue in.

### Neutral
- **Milk Ground** (ground): Scaffold, sheets, tab bar, topic tiles and settings rows.
- **Paper White** (white): Home's raised composer and the child pill, the two things that sit on the mist. It is also the text colour on ink, violet and care-deep fills.
- **Lilac Panel** (panel): Quiet fills such as the chat composer, search, attachment tiles, the sheet close disc, the plan panel on Profile and the pressed highlight. Muted text holds 4.8:1 on it.
- **Hover Fill** (accent-fill): Hover and pressed fills on ghost and outline controls.
- **Warm Hairline** (line): Every 1px divider and border, the chat rail and the tab bar's top edge.
- **Heather Muted** (muted): Secondary text, labels, figures, placeholders, inactive tab icons and chevrons. It holds 5.3:1 on milk and 4.7:1 on mist.
- **Morning Mist** (mist): Home's wash, and the parent's own question bubble.
- **Leaf Lilac** (leaf): The pale leaves of Home's sprig. The deeper leaves and the stem use a second lilac inside the painter.
- **Alarm Red** (destructive): Only for destructive account actions (sign out). It is never a care signal.

### Named Rules
**The Triage Rule.** Green, amber and red mean care level and nothing else. They are never used for success toasts, warnings, charts, topics or decoration.

**The One Voice Rule.** Violet belongs to Mother AI and to selection. Primary buttons are plum ink, even when the action is "ask".

**The Say-It-Once Rule.** A care level appears once per answer as a single strip. In a list it shrinks to a pill with one word ("Home care", "Call GP", "Urgent").

**The Hue-Has-One-Job Rule.** A topic hue marks a topic and a child hue marks a child. Neither is borrowed for the other or for decoration.

## Typography

**Display Font:** Urbanist (bundled variable font, with sans-serif fallback)
**Body Font:** Geist (bundled with shadcn_ui, with sans-serif fallback)

**Character:** Urbanist is the brand's display voice. It is geometric, tightly tracked and heavy, and it sets headlines, titles and monogram initials only. Geist sets everything a person reads or taps, and its tabular figures keep times, ages and read lengths aligned.

### Hierarchy
- **Display** (Urbanist 700, 36px, 1.04, -1.1px): The one headline a screen opens with ("Chats", "Learn", "Profile"). Home's question is set larger on the same face (38px, 1.06, -1.3px) over two lines: "What's on your mind / about Emma?", with the name in the child's hue.
- **Title** (Urbanist 700, 24px, 1.12, -0.5px): Pushed-screen and sheet titles, article section heads, and the stage panel's "Emma at 6 months" with tabular figures. Learn's lead article title uses it at 26px.
- **Section** (Geist 600, 17px, 1.25, -0.3px): A section heading inside a screen ("Start from a topic", "Continue where you left off", "Worth reading"), in a 32px row with an optional "See all" link.
- **Row Title** (Geist 600, 16px, 1.3, -0.2px): A row's primary line. It runs at 17px on the continue row and Learn rows, 15px for the child pill, care-strip labels and article tiles, and 14px for topic tiles.
- **Body** (Geist 400, 16px, 1.5, -0.1px): Answers, bubbles, composer text and stage facts.
- **Secondary** (Geist 400, 14px, 1.4, muted): Previews, descriptions and the Home subline (15px, 1.45).
- **Label** (Geist 600, 13px, 1.2, muted): Group headings ("Children", "Notifications", "More to read"). Always sentence case.
- **Figure** (Geist 500, 13px, 1.2, muted, tabular): Times, ages and "5 min read".

### Named Rules
**The One Headline Rule.** Each screen gets exactly one display-scale line, at the top. Everything below it steps down the scale.

**The Sentence-Case Label Rule.** Labels and section heads are sentence case, never tracked capitals, and nothing sits above a headline as a kicker. The greeting goes into the subline under it.

**The Tabular Figures Rule.** Any number a parent compares (times, ages, dates, minutes, step numbers) uses tabular figures.

## Layout

Single column, centred, with a 24px side gutter. Tab screens cap their content at 560px, and chat and reading screens at 640px. On a tablet (820pt) the column stays phone-width and sits centred, while Home's mist wash and leaves run the full width. Tab screens reserve 128px of bottom clearance for the floating tab-bar island.

Home's order is fixed. Status-bar inset plus 12px, then the child pill, then 28px, then the headline, 12px, the greeting subline, 24px, the raised composer and 36px (the end of the morning). Below that come "Start from a topic" with the topic grid 14px under it, then "Continue where you left off", the child's stage panel and "Worth reading", each 36px apart. The topic grid is three across and then two, with 8px gaps, so it ends flush with the composer's edges. "Worth reading" is a pair of equal columns 12px apart.

Vertical rhythm runs on 4px steps inside blocks (4, 8, 12, 16, 20, 24) and 36px between blocks. Rows breathe with 10 to 16px of vertical padding, and settings rows have a 52px minimum. Touch targets are 44px.

Chat runs on a single vertical rail. A 1.5px hairline runs down the leading gutter, and the Mother AI mark sits on it as a node beside each answer. The parent's questions align to the trailing edge, capped at 420px. Numbered steps hold their violet number in a margin column so the text aligns. Article photos are 4:3 of the screen width, capped at 440px, so a tablet still opens on the title. The photo collapses into a plain bar with a hairline.

## Elevation & Depth

The system is flat except for one deliberate lift. Surfaces are separated by tone (milk ground, mist wash, lilac panel, a child's tint) and by 1px warm hairlines. Home's composer is the one resting shadow, because asking is the one thing Home is for. It is white on the mist, lifted by a soft lavender shadow. Everything else carries shadow only in motion. On Android, web and desktop a pushed screen slides over the last one with a soft leading-edge shadow. Modal sheets dim the page with a 32% plum scrim while the page steps back.

### Shadow Vocabulary
- **Composer lift** (`box-shadow: 0 8px 24px rgba(91,63,176,0.08), 0 1px 3px rgba(31,27,61,0.04)`): Home's raised composer only.
- **Push edge** (`box-shadow: -6px 0 24px rgba(31,27,61,0.10)`): The incoming route during the weighted-sheet push only.

### Named Rules
**The One Lift Rule.** Home's composer is the only surface that carries a shadow at rest, besides the toast, which floats over everything. Every other card, row, tile, button and sheet is flat. Shadow otherwise exists only while something moves over something else.

**The Veil Rule.** Anything that fades in or out over a flat background does it with a `GroundVeil`, a rectangle of the background's colour lifting off it, not an opacity layer. This covers sheet rows, topic tiles, chat bubbles and answers, Learn results, the placeholder, and the chat and stage-panel switches. An opacity layer renders its content into a texture of its own every frame, which is what stutters on low-end phones. Use the veil only where the background really is one colour, and match that colour (milk, white, or the composer's lilac). Decode images at the size they are drawn, never paint a full-screen fill under an opaque page, and never animate the scale of a live page full of text: snapshot it first. Every kind of drawing the transitions use (layer, clip, shadow, gradient, font, weight, size, icon) is drawn once off screen behind the splash by `MotionWarmUp`, so the first sheet of a session is as smooth as the tenth. Add anything new there.

## Shapes

Soft and rounded, never bubbly. The base radius is 14px on the shadcn theme, used by buttons, inputs, the plan panel and row ink wells. Care strips and attachment tiles step down to 12px, and topic icon squares to 10px. Topic tiles are 16px. The continue square and the "Worth reading" photos are 18px. The lead Learn photo and the question bubble are 20px, and the bubble keeps a 6px tail at its trailing bottom corner. The stage panel and sheets open at 24px, and the composer is a near-pill at 26px with 44px circular buttons inside. The child pill, care pills, monograms, the logo mark and the active-tab pill are full stadiums or circles. Borders are always 1px warm hairline.

Drawn botanicals belong to this world. They are the leaves on Home's morning and a two-leaf sprig on the stage panel at 16% of the child's hue. They are flat fills with a pale vein, never outlined, textured or gradient-shaded.

## Components

### Buttons
Solid and plain. These are shadcn buttons, themed rather than rewritten.
- **Shape:** base radius (14px).
- **Primary:** plum ink fill with a white Geist label, at heights 44 (regular, 18px sides), 36 (sm, 14px) and 52 (lg, 22px). It is the one primary action on a screen ("Ask Mother AI about this", "New chat").
- **Outline:** milk fill, hairline border and ink text, used for lower-weight choices ("Edit", "See plans", attach sources).
- **Care action:** full width inside an amber or red strip, filled with the level's deep shade and led by a Lucide `phone`.
- **Link:** "See all" in deep violet with a 16px chevron, hover to violet, at zero padding and 32px tall.
- **Icon / ghost:** 44px hit area with Lucide icons at 20 to 22px. The sheet close is a 36px panel disc with an 18px `x`.

### Ask Composer
The primary input. It is 56px minimum with a 26px radius, and one hairline on the field around it that stays the same on focus, so text never shifts. In chat it has a lilac panel fill and a placeholder that names the child ("Ask about Daniel"). On Home it is **raised**: a white fill, the composer lift, and the placeholder "Ask anything about Emma". Its leading mark is Mother AI's 20px violet `sparkles`, which turns into the chosen topic's 30px icon square. The mark scales up with a small turn on the cushion curve over 480ms and leaves in 200ms. When a topic changes the placeholder ("Tell me about Emma's growth"), the new line rises into place as the old one lifts away, over 360ms. The trailing send button is a 44px circle. It is idle as a violet arrow on voice mist at 86% scale, and it springs to full scale in solid violet once there is something to send. It stays idle while Mother AI is still answering.

### Topic Tiles
The five things a question can start from: Health, Feeding, Sleep, Growth and Behaviour (Lucide stethoscope, milk, moon, sprout, smile). They sit in an even grid, three across and then two, so both rows end flush with the composer. Each is a milk tile with a hairline edge at 16px. It holds a 34px icon square in the topic's tint with its 17px tone icon, then the name in Geist 600 14px, which scales down rather than clipping.
- **Entrance:** the first time the tiles appear, they rise from 35% of their height 45ms apart. Each is veiled in over 260ms and settles over 520ms.
- **Press:** a tile presses to 0.96.
- **Chosen:** the tile fills with voice mist, its edge turns violet, the square turns solid violet with a white icon and the label turns deep violet, over 220ms on the settle curve.
- **The chosen icon plays its own gesture** over 760ms, using transforms only: the stethoscope beats twice, the bottle tips and rights itself, the moon rocks like a cradle, the sprout grows up out of the ground, and the smile hops twice.

Choosing a topic only frames the question. The composer takes focus and its mark and placeholder change, and the parent still writes the question. Tapping the chosen tile clears it. There are no scripted symptom prompts.

### Home Morning (signature)
The mist wash (mist to 45%, then fading to milk) runs up under a dark status bar. Pulling past the top shows more mist, never a seam. The morning holds the child pill, the headline, the greeting subline ("Good afternoon. Ask in your own words, and you'll hear plainly when it needs a doctor.") and the raised composer.

**Morning leaves.** A cubic stem rises from beyond the trailing edge at 62% of the field's height and curls up and in, with six leaves in two lilacs, each with a pale milk vein. The leaves are driven by events, on one ticker:
- Home appears: they sway in for 3.5s.
- The composer gains or loses focus: 2.5s. While focused, the sprig bends up to 0.05 rad toward the composer and the leaves lean in and breathe.
- A keystroke: a rustle of energy for 1.4s.
- The child changes: the leaves re-tint toward the child's hue over 0.7s, with 3s of movement.

Then they glide to rest and the ticker stops, so an idle Home costs nothing and tests settle. Under reduced motion they hold still and re-tint instantly.

### Child Pill
Who the question is about, and the control that changes it. It is a white stadium with a hairline, holding a 34px monogram, the name in Geist 600 15px, "· 6 months" as a 14px figure and a muted chevron. With no child it reads "General question". On a change of child, the monogram turns over into the new one (scales up with a small turn on the cushion curve, 560ms). The name and the age roll to theirs letter by letter (see Headline roll), and the pill eases to its new width. In a chat the child is fixed once the first question is sent, and the header line becomes plain text.

### Headline roll (signature)
In Home's headline only the name changes with the child; "What's on your mind about" and the "?" stay put. The name rolls over 900ms. Its old letters lift out through the top of the line one after another (easeInCubic, 34% of the change each). The new letters rise in through its bottom from 16%, each tipping upright from a 0.22 rad tilt and settling on the cushion curve, in the child's hue. The width eases between the two names on settle, so the "?" slides along. The letters are painted inside the line as a window, never faded, so the change costs no opacity layer and no relayout. The morning's leaves re-tint to the new child over 1.4s on easeInOutCubic. Under reduced motion the name simply swaps.

### Rows and Lists
Rows are open, never boxed: a full-width hairline above the group, hairlines between rows and a full-width hairline closing it.
- **Continue where you left off** holds one row: a 64px topic square at 18px with a 26px tone icon, the title (Geist 600 17px), then "Today · 10:24" and the care pill, a two-line preview and a trailing chevron.
- **Chats rows** carry the child monogram, title, preview, time and care pill.
- **Learn rows** lead with an 84px photo at 14px. The title is 16.5px on two lines, then a two-line summary and a meta line: the topic's 14px tone icon and "Health · 4 min read". A muted chevron trails.
- **Settings groups** on Profile follow the same open pattern. A 13px label heading sits over a full hairline, with dividers inset 36px past a 24px icon column, 52px minimum rows, muted 20px icons, an optional muted value and an 18px chevron or a violet switch.

### Learn
Search and topics come first, then a lead, then the list.
- **Search:** the panel field at 48px, with a leading search icon and a clear button once there is text.
- **Filter:** a row of stadium chips that runs off the edge: "All", then each topic with its tint circle and tone icon. The chosen chip fills violet with a white label and scrolls fully into view.
- **Lead:** the first matching article with a photo. It is a 16:10 photo at 20px carrying its topic tag, the title (Urbanist 26), the summary, "5 min read", and a 48px voice-mist disc with a violet arrow.
- **More to read:** the Learn rows above. A search lists every match with no lead, under "N to read".
- **Links:** items on another website have no photo of their own. They show the topic's square with a white globe badge in its corner, say "Opens a website" in the meta line, trail an `arrow-up-right`, and open in the phone's in-app browser.
- **Filter changes:** new results rise 3% and are veiled in.
- **Empty:** when nothing matches, a violet sparkle square, a line that names what was looked for ("No Sleep guides on 'teething' yet") and an ink "Ask Mother AI" button. The button opens a chat with the search already in the field, focused but not sent, so the parent finishes the question. A topic frames the chat only when nothing was typed.

### Attachments
Removed on 29 September 2026. The chat model (GPT-OSS 120B on Groq) reads text only, so a photo the parent attached would never be seen. Bring the attach sheet back only with a model that can read images.

### Answers as they stream
An answer is written into the thread as it arrives, redrawn at most once a frame. Until the first words come, the three violet dots breathe. The care strip wipes in as soon as its line is known, and the text and each step rise in as they are written. Once finished, the answer is drawn still, exactly where the live one ended. When there is no answer (offline, too slow, the service busy), the answer's place holds the reason in muted body text and an outline "Try again" with a `rotate-ccw`. Answers in Arabic or Farsi read right to left.

### Stage Panel
Where the child is right now, as context rather than a question. It is a field in the child's tint at 24px radius, with a faint sprig in the corner at 16% of their hue. It holds the Title "Emma at 6 months" with the age in the hue, the line "What's typical right now" and three body facts behind 8px hue dots. It cross-fades on a change of child and disappears when there is no child.

### Worth Reading
Two articles for the child's stage. Each is a 4:3 photo at 18px radius (a Hero into the article), a two-line title in Geist 600 15px and a `book-open` with "5 min read".

### Care Strip and Care Pill
The strip sits at the top of an answer. It is the level's tint at 12px radius, with a 28px signal disc holding a white 15px Lucide icon, then the level's sentence in Geist 600 15px deep. Amber and red add the care action button. It wipes in from the leading edge over 520ms on the settle curve, and it simply appears under reduced motion. The pill is the list form: a tint stadium with a 7px signal dot and one word in Geist 600 12px deep.

### Chat Rail and Question Bubble
A 1.5px hairline rail runs down the conversation, with the Mother AI mark as a node beside each answer. The parent's question bubble is morning mist with ink body text (14.3:1). It has a 20px radius with a 6px trailing-bottom tail, is capped at 420px, and rises in from its tail corner (fade 200ms, rise 380ms on settle, scale 0.96 to 1). Answers are unboxed: the care strip first, then body text, then numbered steps with violet tabular numbers in the margin. Mother AI writing shows as three violet dots breathing.

### Navigation
The tab bar is an island floating over the bottom of the page. It is a white stadium 64px tall, capped at 460px wide, 16px in from the sides and 12px above the bottom safe area, with a hairline edge and one soft lavender shadow (`0 10px 28px rgba(59,42,122,0.12)`). Pages scroll on beneath it. It holds four Lucide tabs (house, messages-square, book-open, user-round), and only the open tab says its name: it sits in a solid violet stadium, 44px tall, with an even 10px ring of island around it, a white 22px icon and a Geist 600 label. The other tabs are muted icons, and each keeps its name as its accessible label.

Choosing a tab sends the pill across like a drop of liquid on one 560ms controller. The leading edge runs on Interval(0, 0.72, settle) and the trailing edge on Interval(0.18, 1, settle), so the pill stretches across the gap and then gathers into the new tab. A tap mid-travel relaunches it from where it is. A press scales the tab to 0.88, and a change of tab gives a selection haptic. The pill repaints inside its own boundary, so the island and its shadow are never redrawn during a switch. Reduced motion jumps straight there.

Photos flying between a list and an article (Heroes) pass beneath the island: `flyBeneathIsland` cuts the island's shape out of the photo in flight, so it never crosses over the island and then drops behind it. Pushed screens use the native Cupertino push on iOS and macOS, with its edge swipe back, and the weighted-sheet push elsewhere. Going back is one motion everywhere: the push played the other way at the same pace (340ms both ways, the settle curve mirrored on the way out, so a screen leaves as quickly as it arrived and the photo of an article flies back into its tile). The back button, the system back button and the system back gesture all pop the route and so all play it. The gesture does not steer the screen under the finger: `SheetPageTransitionsBuilder` deliberately does not handle `startBackGesture`, because a gesture that dragged the screen played a different, slower motion from the button's. Screens arrive from the trailing edge, so in Arabic and Persian they come from the left. A photo that flies between screens uses one full-size image at both ends, never a decode sized from layout, which a Hero flight would re-request at every frame.

### Languages
Seven languages: English, Persian (فارسی), Hindi (हिन्दी), Spanish (Español), Arabic (العربية), Turkish (Türkçe) and Chinese (中文). Choosing one in Profile changes the words on every screen, the direction, the type settings and the language Mother AI answers in. English sentences are their own keys (`context.tr('Add a child')`, blanks as `{name}`); the tables are `lib/core/l10n/strings_*.dart`, plural forms live under `key#one`/`key#other`, and `test/l10n_test.dart` fails if a sentence in the source is missing from any table. `dart run tool/l10n_keys.dart` prints the sentences.
- **Direction:** Arabic and Persian run right to left. Layout uses start/end everywhere, icons that point (`back`, `forward`, `out`) come from `DirectionalIcons`, pushed screens and tabs slide from the trailing edge, and the tab bar's pill is mirrored by hand.
- **Type:** the scale is drawn for Latin letters. In any other script `AppText.tune` drops the tight tracking (it would pull the joins of Arabic and Persian apart) and lifts line heights to at least 1.3.
- **Rolling names:** `RollingText` rolls Latin and Chinese names letter by letter, but rolls a word in Arabic, Persian or Devanagari as one piece, because cut into letters it stops joining.
- **Figures:** Western digits in every language.

### Sheets and Sheet Motion
shadcn bottom sheets, opened through `showAppSheet`, with a 24px top radius, 28px top padding and 24px sides. Each has a start-aligned Title and a Secondary description, and no shadow, because the scrim separates the sheet from the page. The close disc is placed 22px from the top and 20px from the edge. Facts inside a sheet are open label and value rows closed by hairlines. Actions sit in one row: outline secondary, then the ink primary expanded.

Sheets rise over 520ms on the settle curve and drop in 260ms on easeInCubic. As a sheet or dialog rises, the page under it steps back: it scales to 94%, drops 10px and rounds to a 28px corner on a plum-ink ground, then comes forward as the sheet leaves. The ink is painted only while the page is stepped back. While stepped back the page is drawn from a snapshot and its tickers pause, so the scale works on one picture instead of re-rendering every glyph at each new scale, which is what stuttered on a low-end phone. Both movements run off the route's own animation:
The medical disclaimer is one of these sheets (`showNoticeSheet`), like Language and Units; it is not a dialog. Dialogs are kept for confirming a removal.
- `SheetRise` drives the sheet's slide.
- `RecedeBehindSheets` drives the page, through the `SheetDepth` observer.
- The theme hands shadcn silent effects of the same lengths, which only time the route. shadcn's own slide started a frame or two late and drifted from the page on a slow phone.

The widget tree is the same at rest and in motion, so typed text and scroll position survive. Sheet rows cascade in 45ms apart, starting 110ms after the sheet, veiled rather than faded. A child picked in the picker applies once the sheet has left, so Home's change plays on a still page. Under reduced motion the page stays still and rows simply appear.

### Toast
The demo's notices are Mother AI speaking, drawn in the app's own overlay rather than shadcn's sonner. A new toast replaces the one showing. The card is white with a hairline at 20px radius and one soft lavender shadow, sitting above the bottom safe area or the keyboard, whichever is higher. By default that clearance is 84px, enough to clear the tab bar; a chat passes its composer's measured height, which grows with attachments waiting. It holds the 32px mark, the title (Geist 600 15px), the description and a 2px violet countdown line on a voice-mist track that runs down over 5 seconds. It always carries a visible 44px ghost `x`, and a flick down dismisses it too. A short flick eases back into place on the cushion curve over 260ms.
- **Arrival (640ms):** it rises 96px and grows from 92% at its bottom edge on the **cushion** curve (cubic-bezier(0.34, 1.32, 0.64, 1)), so it overshoots a little and comes to rest. It fades in over the first 35%, and the mark pops in on the same curve a beat later.
- **Departure (320ms):** it drops, shrinks and fades together on easeInOutCubic.

Under reduced motion it simply appears and disappears.

### Splash
One splash on every platform: the milk ground with the mark centred at a fixed size, never stretched or cropped to the screen's shape. The mark fills the middle 60% of its 1254px canvas (`assets/branding/mother_ai_splash_icon.png`), inside both the circle Android 12+ shows and the square some launchers (HyperOS) mask it to.

## Do's and Don'ts

### Do:
- **Do** use a care level's full triad together: signal for the disc or dot, tint for the field, deep for text and the action button.
- **Do** give every amber or red care level its next step as a full-width button in the level's deep shade.
- **Do** open each screen with one Urbanist display headline and set everything else in Geist.
- **Do** set times, ages, dates, read lengths and step numbers with tabular figures.
- **Do** keep rows open: full-width hairlines above and below a group, inset hairlines between rows.
- **Do** keep Home's composer the one raised surface: white on the mist, with the composer lift.
- **Do** let the morning leaves move only in response to an event, then settle and stop the ticker.
- **Do** animate on the settle curve, cubic-bezier(0.16, 1, 0.3, 1), and give every animation a reduced-motion path.
- **Do** show a child's name in their own hue wherever the name sets who a question is about.

### Don't:
- **Don't** use green, amber or red for anything but care level, including success states, warnings, topics and decoration.
- **Don't** fill primary buttons with violet. Primary is plum ink, and violet is Mother AI's voice.
- **Don't** box a list into a bordered card. That includes settings groups.
- **Don't** add a second resting shadow. Tone and hairline carry depth everywhere except the Home composer.
- **Don't** set labels in tracked capitals or put a kicker above a headline.
- **Don't** set gradient text, or use a gradient anywhere except Home's mist-to-milk wash and the logo mark.
- **Don't** set body or UI text in Urbanist, or headlines in Geist.
