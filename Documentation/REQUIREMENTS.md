# PaperSprint Part A scope and assignment mapping

Implementation source of truth: the uploaded PaperSprint Full Project Summary. Assignment source: uploaded SE4041 MADD Assignment 02 brief. This matrix describes implemented source and evidence still to collect, not awarded marks.

| Requirement | Code coverage | Mac evidence needed |
| --- | --- | --- |
| Clear purpose/audience | Student revision through lessons, MCQs, feedback and saved attempts | Explain learner problem and target group |
| Three or more navigable screens | Home, lesson list/detail, quiz, results/review/history, scan/settings/help | Show navigation in demo |
| Custom SwiftUI UI | SubjectCard, AnswerOptionView, ScoreRing, PaperCard ViewModifier | Show selection/check feedback and reusable code |
| Advanced UI/adaptation | Animated selection/feedback, numeric score/progress, adaptive grid, swipe deletion, ViewThatFits | iPhone/iPad portrait/landscape and larger-text checks |
| Navigation architecture | NavigationStack inside tab navigation; protected quiz close | Demonstrate back/exit behaviour |
| Data persistence | SwiftData QuizResult with answer snapshots, explicit saves/error/retry/rollback and UUID deduplication | Complete/relaunch/review history |
| Advanced Apple framework | Real Vision OCR from sample/imported image, on-device processing and result display | Run sample and own image; explain OCRWorker |
| Branding/accessibility | PaperSprint icon, consistent indigo/teal palette, semantic fonts/colours, VoiceOver labels and text feedback | Dark Mode, Dynamic Type, Reduce Motion and VoiceOver |
| Unit/UI/performance checks | Scoring/guards/catalogue/persistence/OCR unit tests; end-to-end UI and launch metric | Run Command + U and record actual results |
| Documentation | README user guide/architecture, test checklist and AI-use record | Write final report with screenshots and actual reflections |
| Live demonstration | Bundled lessons and sample OCR; no account/backend/custom model training | Build on lab Mac and practise viva |

## Deliberate boundaries from the PaperSprint plan

- No task planner, map-based study-place finder, accounts, automatic sync or server.
- No automatic question generator, automatic scanned-answer marking or PDF parser.
- OCR is a small recognition/display feature; imported text is not silently treated as a verified quiz.
- Completed attempts persist; unfinished attempts are transient.
- Sample content is original and labelled as such, not an official past paper.
- Part B tvOS remains separate: later reuse data/scoring for 2–4 teams and remote focus. It is not in this iOS ZIP.
- Final report, acceptance results and pitch must reflect work actually tested. No invented accuracy, performance or participant metrics.
