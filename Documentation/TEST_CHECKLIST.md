# PaperSprint Mac verification checklist

At packaging: source/project checks only. Xcode tests and user tests have not run in the authoring environment. Fill in actual results below.

| Test | Expected | Actual result/device/date |
| --- | --- | --- |
| Build/launch | PaperSprint scheme opens five-tab learning app | Not run |
| Subjects/lessons | 3 subjects, 6 readable lessons, 30 valid questions | Not run |
| Search | Lesson title/subject search and no-results state | Not run |
| Start quiz | Exactly 5 questions for chosen lesson | Not run |
| No selection | Check Answer disabled; cannot skip unchecked question | Not run |
| Correct/incorrect | Correct answer + explanation shown; score accurate | Not run |
| Repeat tapping | Checked answer cannot change or score twice | Not run |
| All correct | 5/5 and 100 percent | Not run |
| Mixed answers | e.g. 3/5 and 60 percent | Not run |
| All incorrect | 0/5 and 0 percent | Not run |
| Completion | One saved record for one attempt UUID | Not run |
| Try again | New attempt, reset selection/score, new saved record only on completion | Not run |
| Review | Selected/correct answers and explanations match the attempt | Not run |
| Relaunch | Completed results and answer snapshots survive normal app relaunch | Not run |
| Exit mid-quiz | Confirmation after progress; no partial result saved | Not run |
| Delete result | Cancel keeps it; confirm removes only that result | Not run |
| Delete all history | Confirmation required; lessons/preferences remain | Not run |
| Sample OCR | Real recognised text includes Swift and questions | Not run |
| Imported photo/file | Clear English image recognised; EXIF orientation handled | Not run |
| No-text image | Helpful no-readable-text state | Not run |
| Invalid/large image | Error for unreadable image or over 20 MB input | Not run |
| OCR performance | Loading state, responsive UI, record observed duration | Not run |
| Copy/share | Explicit output copy or system share sheet | Not run |
| Appearance/name | Settings survive relaunch; light/dark legible | Not run |
| Accessibility | Larger text, VoiceOver selected/correct/incorrect state, Reduce Motion | Not run |
| Device adaptation | iPhone/iPad portrait/landscape, content reachable by scroll | Not run |
| Command + U | Unit/UI/OCR/persistence/launch tests pass | Not run |

## Screenshots to collect after a successful run

1. Home subject cards and learning metrics.
2. Lesson list and readable lesson detail.
3. Quiz before checking and after correct/incorrect feedback.
4. Results with score and saved status; per-answer review.
5. History after stopping/relaunching the app.
6. Scan sample preview and actual recognised text.
7. Settings/Dark Mode and a larger-text screen.
8. Xcode test results and measured launch performance, if executed.
9. GitHub source, README and feature commit/PR.

## User evaluation

Ask consenting students to read a lesson, answer a quiz, review one mistake and recognise the sample image. Record actual participants, completion/difficulties, feedback and changes made. Do not claim an evaluation before it happens.
