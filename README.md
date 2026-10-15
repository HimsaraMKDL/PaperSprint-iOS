# PaperSprint — iOS revision and MCQ practice

SE4041 MADD Assignment 02, Part A. Based on the supplied **PaperSprint Full Project Summary**: read lessons, practise multiple-choice questions, review scores and recognise text from a question-paper image using Apple Vision.

## Start on your Mac

1. Extract `PaperSprint_iOS.zip` into a **new folder**. Keep the working StudyMate planner folder as a backup.
2. Close the old Xcode project. Open **`PaperSprint.xcodeproj`** from the new `PaperSprint` folder.
3. Select the **PaperSprint** scheme and an installed **iPhone Simulator**, for example iPhone 16 Pro.
4. Press **Command + R**.
5. Press **Command + U** to run the included tests after the first successful launch.

Xcode 16.4 project format retained; iOS 17.0+, Swift 5 language mode, iPhone and iPad. An Apple signing Team is needed only for a physical device. No packages, API key, server, login, custom ML training or internet service is needed for local lessons/quizzes/sample OCR. Downloading an iCloud photo may need internet.

The project, targets, scheme, executable, display name and bundle identifiers are now PaperSprint. The existing Git history and remote `HimsaraMKDL/StudyMate-iOS` are retained so you can continue your repository. Its remote is not renamed automatically.

## Included learning content

Original English revision material, not official past-paper content or a complete SLIIT syllabus:

| Subject | Lessons | Questions |
| --- | --- | --- |
| Swift Foundations | Values, Types & Optionals; Functions, Collections & Types | 10 |
| SwiftUI Essentials | Views, Layout & Components; State, Binding & Navigation | 10 |
| iOS Development | Persistence & Data Flow; Vision OCR & App Quality | 10 |

Each lesson has readable sections and five MCQs with explanations. Change the local catalogue in `PaperSprint/Resources/SampleLessons.swift` to add your own properly sourced material. The TV prototype can later reuse the same plain data models and catalogue.

## Working flows

### Home and lessons

Home shows subjects, quiz count, overall answer accuracy, best score and the latest saved result. Start the five-question Values quiz with Quick Sprint, or choose a subject. Lessons supports title/subject search. Open a lesson, read it, then tap **Practise this lesson**.

### Practice quiz and results

Select one option and tap **Check answer**. The correct answer and an explanation appear. A checked answer cannot change or score twice. Tap Next, then See results after the last question. A full attempt saves to SwiftData with its date, subject, lesson, total/correct counts, percentage, duration and answer snapshot. If saving fails, the screen reports that it was not saved and provides Retry Saving. One attempt UUID prevents duplicate saves.

Try Again starts a new attempt. Review Answers compares your choice with the answer and explanation. Completed attempts appear in Results; search or swipe to delete with confirmation. Closing an unfinished quiz discards it. There is no resumable partial-attempt persistence.

### Small Vision OCR demonstration

Open **Scan > Recognise sample paper**. The bundled image contains original practice questions. Apple Vision's `VNRecognizeTextRequest` performs real on-device OCR; the output is not a hard-coded string. Choose Photo or Import Image to process your own paper image (English text, up to 20 MB). You can select/copy/share the recognised text.

ImageIO downsamples images to a maximum 2400px dimension and applies EXIF orientation before recognition. OCRWorker is an actor so decoding and recognition do not block the UI actor. Preview data and recognised text are transient. They are not saved by PaperSprint. OCR may make errors.

This feature **does not generate MCQs, infer answers, mark scanned papers, or accept PDFs**. Import a PNG/JPEG/other decodable image. The quiz catalogue is separate authored local content.

### Settings and accessibility

Optional name and System/Light/Dark appearance use AppStorage. Semantic fonts, adaptive layouts, reusable answer cards, accessibility labels, text answer feedback and Reduce Motion-aware transitions support accessible use. Confirm the actual layout with VoiceOver, large text and rotation using the test checklist. Delete All Quiz History requires confirmation and leaves lessons/preferences intact.

## Architecture

| Path | Responsibility |
| --- | --- |
| `PaperSprintApp.swift` | Persistent container, startup failure UI, appearance |
| `ContentView.swift` | Home/Lessons/Results/Scan/Settings NavigationStacks |
| `Models/LearningModels.swift` | Subject, Lesson, Question, AnswerRecord, persisted QuizResult and validation/scoring rules |
| `Resources/SampleLessons.swift` | Three subjects, six lessons and thirty authored MCQs |
| `Services/QuizService.swift` | Observable answer selection, one-check state machine and derived scoring |
| `Services/OCRWorker.swift` | Off-UI-actor image decoding, orientation, Vision text recognition and thumbnail response |
| `Components/LearningComponents.swift` | SubjectCard, AnswerOptionView, ScoreRing and reusable PaperCard modifier |
| `Views/HomeView.swift` | Dashboard, lesson list and lesson detail |
| `Views/QuizView.swift` | Quiz, feedback, completion and idempotent save/retry |
| `Views/ResultsView.swift` | Persistent history, detail and per-answer review |
| `Views/ScanView.swift` | Sample/Photos/Files OCR input, loading/errors, copy/share |
| `Views/SettingsView.swift` | Preferences, help and privacy |

No MapKit or task planner remains in the app. The old StudyMate database is not migrated: PaperSprint has a distinct bundle identifier and named quiz store. Your original planner remains in its own folder/app sandbox.

## Verification and tests

**The authoring environment is Linux and has no Xcode/Apple SDK/Simulator/Swift compiler.** Source syntax parsing and project/asset/archive checks were performed. These do not establish an Xcode build or runtime pass. The previous StudyMate launch does not validate this PaperSprint revision. See `Documentation/VALIDATION.md`.

Included Swift Testing coverage:

- Catalogue IDs, relationships and valid options/answer indexes.
- All-correct and all-wrong scoring; empty quiz and percentage boundaries.
- Repeated Check protection; invalid selections; unchecked-next prevention.
- SwiftData result snapshot round-trip and deletion.
- Persisted history after reopening a temporary disk store.
- Real Vision recognition on the bundled sample.

Included XCTest UI coverage: full five-question quiz/history, lesson navigation/sample OCR, launch screenshots, and an application launch performance measurement. UI tests pass `--uitesting` and use an isolated in-memory results store. Do not pass that flag when demonstrating persistence.

Run on the Mac:

```bash
xcodebuild test -project PaperSprint.xcodeproj -scheme PaperSprint -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Replace the destination with an installed Simulator if needed. Record real results in `Documentation/TEST_CHECKLIST.md`. Screenshots, acceptance results, performance measurements, final report and live demonstration must follow actual device verification.

## GitHub development

The supplied initial Git history/identity/remote are retained; implementation changes are intentionally uncommitted. From the **new PaperSprint folder**:

```bash
git status
git switch -c feature/papersprint-ios
git add .
git commit -m "Implement PaperSprint lessons quizzes history and Vision OCR"
git push -u origin feature/papersprint-ios
```

Review and merge a pull request on GitHub after successful testing. No force-push is needed. The remote's existing repository name can be renamed separately later if desired. Do not paste tokens into commands or source files.

## Assignment and documentation

This delivery implements the iOS scope from the user's PaperSprint summary. It includes code, tests, README/user guide, architecture notes, requirement mapping and AI-use record. It is **not** a completed final academic report or evidence of user testing. Part B tvOS is not implemented in this ZIP; finish and verify Part A first.

Apple Vision is the advanced Apple framework demonstration. Explain it as on-device text recognition using Apple's models, not as a custom trained model. Rubric interpretation/marks remain with the lecturer; do not guarantee a score from source implementation alone.

## Sources

- Apple SwiftUI: https://developer.apple.com/documentation/swiftui
- Apple SwiftData: https://developer.apple.com/documentation/swiftdata/modelcontainer
- Apple Vision text recognition: https://developer.apple.com/documentation/vision/recognizing-text-in-images
- Apple PhotosPicker: https://developer.apple.com/documentation/photosui/photospicker
- Apple ImageIO: https://developer.apple.com/documentation/imageio
- Apple SF Symbols: https://developer.apple.com/sf-symbols/

Lesson/MCQ content, sample revision image and vector app icon were authored for this project with disclosed AI assistance. No official exam paper or third-party image dataset is bundled.
