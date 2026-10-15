# Open the correct PaperSprint project

1. Keep the existing working StudyMate folder. Extract this ZIP to a **different location**.
2. Close the old Xcode project.
3. Open `PaperSprint/PaperSprint.xcodeproj` from this extraction.
4. Choose **PaperSprint > iPhone 16 Pro** (or another installed iPhone Simulator).
5. Press **Command + R**.

The correct app says **PaperSprint** and has Home, Lessons, Results, Scan and Settings tabs. It does not show task deadlines or study maps.

First demo:

- Home > Start a quick sprint.
- Select one option > Check answer > read feedback > Next question.
- Finish all five questions > See results > confirm Saved to your results.
- Done > Results > open the attempt > Review answers.
- Stop and relaunch normally; verify history remains.
- Scan > Recognise sample paper > inspect the recognised text.

Use Command + U to execute included tests. Do not add `--uitesting` to a normal run; that flag intentionally disables disk persistence for isolated tests.

The project has been syntax/project-checked here but not built with Xcode. Send the first full compiler error with its file/line if one appears. For an actual device, choose your own signing Team. Simulator does not require a Team.

The original Git history and remote are retained, pointing to your existing StudyMate-iOS repository. Develop and test from this new PaperSprint folder; README has feature-branch push steps. No token is included in this ZIP.
