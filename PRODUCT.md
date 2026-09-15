# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Users

Mothers and other primary caregivers of infants, toddlers, and young children who have a question or concern about their child and want a quick, understandable answer. They are not necessarily in crisis — the job spans everyday parenting questions (sleep, nutrition, behavior, milestones) as well as moments of worry (symptoms, whether something needs a doctor).

## Product Purpose

Mother AI is an AI-native mobile companion that lets a parent ask a question in natural language and get calm, understandable guidance back — on child health, growth/development, sleep, nutrition, parenting, behavior, everyday childcare, and when something warrants professional medical attention. Success is the core loop working with minimal friction: open the app, ask, receive useful guidance, feel more confident. It is a real product being built toward launch, not a demo.

## Positioning

Mother AI is not a healthcare-dashboard app and not a generic AI chatbot. It sits between a premium wellness app, a modern AI product, and maternal warmth — a calm, intelligent companion rather than a clinical tool. Its durable mechanism a neighboring chatbot can't just copy: Learn content is not autonomously AI-generated — it is meant to originate from credible medical/public-health sources (WHO, UNICEF, CDC, NHS, American Academy of Pediatrics, relevant Ministry of Health guidance, etc.), pass editorial/medical review, then get simplified into Mother AI's voice with source citations preserved. That curated, traceable knowledge base is intended to eventually also ground the chat itself (retrieval/RAG), rather than the chat answering from an ungrounded model alone. Chat is personalized, in-the-moment assistance; Learn is structured, trusted education; the product continually loops a user from one to the other ("Ask Mother AI about this" from an article).

## Operating Context

Native mobile app (iOS and Android). The MVP is deliberately small and centers on one journey — open app → ask a question → receive an answer — and deliberately avoids trackers, dashboards, and multi-module menus until that core loop is validated. MVP surface scope: Splash, two-screen onboarding, Home, Chat, Learn/Articles, Article detail, Profile/settings, and optionally a separate conversation-history screen (kept out of the main Chat screen so it doesn't compete with the AI greeting).

## Capabilities and Constraints

- Chat is the center of the product; every other surface supports it rather than competing with it (a stated product principle, not just a layout preference).
- The AI must clearly distinguish general guidance from situations that need professional or emergency care. A medical disclaimer already exists in the app copy ("Mother AI offers general parenting guidance and is not a medical service...") and is a durable constraint, not incidental copy.
- Learn articles must remain traceable to credible medical/public-health sources rather than being purely AI-generated; this is a trust/compliance constraint on the Learn feature, not just an editorial preference.
- Child profiles: multiple children per account. Fields under consideration — name/nickname, date of birth/age, sex (where medically relevant), allergies, conditions, medications, notes. For MVP, collect the minimum necessary and expand progressively rather than front-loading a medical-intake-style form.
- Conversation history is wanted but must stay out of the main Chat screen (e.g., a history entry point in the Chat header or a separate screen) so it doesn't clutter the primary ask-a-question flow.
- "Mother AI Plus" is a named subscription concept in the current build (unlimited chats, deeper answers, no ads) — pricing and entitlements are not yet confirmed product facts.

## Brand Commitments

- Name: **Mother AI**.
- Logo: an abstract mother-and-child symbol — organic curved silhouette, mother-surrounding-child form, lavender/peach/pink/pale-blue gradient, soft and elegant. Kept relatively small and not repeated large on every screen (the user already sees it on splash/onboarding).
- Recurring decorative phrases used sparingly as emotional accents, never as functional UI copy: "Care, guidance, and support for mothers and children," "Small steps. Brighter tomorrows.," "Real answers. Kinder days. Brighter tomorrows."

## Evidence on Hand

None of the current on-screen content is confirmed real evidence — it is placeholder/reference data written during earlier build-out and should not be treated as fact by future work:
- The account name "Sarah Mitchell," her email, and "Member since March 2026" are placeholders, not a real user.
- The sample chat conversations, article bylines/sources, and the "Mother AI Plus" plan copy are illustrative, not confirmed claims, pricing, or partnerships.
- No medical-review partnership, editorial process, or specific source-citation format has actually been confirmed yet, even though sourcing from credible bodies (WHO, UNICEF, CDC, NHS, AAP, etc.) is the intended model for Learn content. Future work must not fabricate specific partners, reviewers, or citations beyond what's confirmed.

## Product Principles

1. **AI-first, one core loop.** The chat is the product; ask → answer is the loop everything else must serve rather than dilute.
2. **One obvious primary action per screen.** Home asks; Chat continues a conversation; Learn surfaces something to read; an Article offers to read then optionally ask the AI; Profile manages preferences. Screens should not present several equal-weight competing actions.
3. **Guidance vs. professional care, always distinguished.** General guidance and "this needs a doctor" must never blur together, given the health-adjacent subject matter.
4. **Trustworthy, traceable content.** Learn material is sourced from credible medical/public-health bodies and editorially reviewed, not simply generated and published; that traceability is core to the product's trust position, not a nice-to-have.
5. **Deliberately small MVP.** Resist adding modules, trackers, or dashboards before the core ask-and-answer loop is validated; minimize friction around that loop above all else.

## Accessibility & Inclusion

No specific accessibility standard has been confirmed. Plain-language, understandable explanations (as opposed to clinical jargon) are a stated product goal for how the AI communicates, distinct from any formal accessibility requirement.
