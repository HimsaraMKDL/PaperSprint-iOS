import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ScanView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showFileImporter = false
    @State private var previewData: Data?
    @State private var recognizedText = ""
    @State private var isBusy = false
    @State private var didRecognize = false
    @State private var error: String?
    @State private var imageLabel = "Sample revision paper"
    private let worker = OCRWorker()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("From paper to readable text.").font(.largeTitle.bold())
                Text("Use Apple Vision to recognise English text from a question-paper image. Read, select or copy the output for your revision.")
                    .foregroundStyle(.secondary)
                Group {
                    if let previewData, let image = UIImage(data: previewData) {
                        Image(uiImage: image).resizable().scaledToFit()
                    } else {
                        Image("SamplePaper").resizable().scaledToFit()
                    }
                }.frame(maxHeight: 340).frame(maxWidth: .infinity)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel(imageLabel)
                Button("Recognise sample paper", systemImage: "text.viewfinder") {
                    guard let image = UIImage(named: "SamplePaper"), let data = image.pngData() else {
                        error = "The sample image is unavailable."; return
                    }
                    imageLabel = "Sample revision paper"
                    Task { await recognize(data: data) }
                }.buttonStyle(.borderedProminent).disabled(isBusy).accessibilityIdentifier("scanSample")
                ViewThatFits(in: .horizontal) {
                    HStack { photoPicker; fileButton }
                    VStack(alignment: .leading, spacing: 12) { photoPicker; fileButton }
                }
                if isBusy { ProgressView("Recognising text on this device…").accessibilityIdentifier("ocrLoading") }
                if let error {
                    Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.red).font(.subheadline)
                }
                if didRecognize && !isBusy {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Recognised text").font(.title2.bold())
                            Spacer()
                            if !recognizedText.isEmpty {
                                ShareLink(item: recognizedText) { Image(systemName: "square.and.arrow.up") }
                                    .accessibilityLabel("Share recognised text")
                            }
                        }
                        if recognizedText.isEmpty {
                            Text("No readable English text was detected. Try a sharper, well-lit image with larger text.")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(recognizedText).textSelection(.enabled).lineSpacing(5)
                                .accessibilityIdentifier("ocrText")
                            Button("Copy text", systemImage: "doc.on.doc") { UIPasteboard.general.string = recognizedText }
                                .buttonStyle(.bordered)
                        }
                    }.paperCard()
                }
                VStack(alignment: .leading, spacing: 10) {
                    Label("A small OCR study tool", systemImage: "info.circle").font(.headline)
                    Text("This extracts text only. It does not generate questions, identify correct answers, or grade scanned papers. Review the recognised text for errors.")
                    Text("The bundled sample is original practice content, not an official past paper. OCR runs on-device. Selected images and recognised text are not stored by PaperSprint.")
                }.font(.caption).foregroundStyle(.secondary).paperCard()
            }.padding(22).frame(maxWidth: 850).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("Scan a paper").navigationBarTitleDisplayMode(.inline)
            .task(id: selectedPhoto) {
                guard let selectedPhoto else { return }
                isBusy = true; error = nil; didRecognize = false
                do {
                    guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else { throw OCRError.unreadableImage }
                    try Task.checkCancellation()
                    imageLabel = "Selected paper image"
                    await recognize(data: data)
                } catch is CancellationError { isBusy = false }
                catch { self.error = error.localizedDescription; isBusy = false }
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image], allowsMultipleSelection: false) { result in
                do {
                    guard let url = try result.get().first else { return }
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    // Bound the input before reading; imported file bytes are never retained on disk.
                    let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    guard size <= 20 * 1024 * 1024 else { throw OCRError.imageTooLarge }
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    imageLabel = "Imported paper image"
                    Task { await recognize(data: data) }
                } catch { self.error = error.localizedDescription }
            }
    }
    private var photoPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Label("Choose photo", systemImage: "photo")
        }.buttonStyle(.bordered).disabled(isBusy)
    }
    private var fileButton: some View {
        Button("Import image", systemImage: "folder") { showFileImporter = true }
            .buttonStyle(.bordered).disabled(isBusy)
    }
    @MainActor private func recognize(data: Data) async {
        isBusy = true; error = nil; recognizedText = ""; didRecognize = false
        do {
            let response = try await worker.recognize(data: data)
            try Task.checkCancellation()
            previewData = response.previewData
            recognizedText = response.text
            didRecognize = true
        } catch is CancellationError { }
        catch { self.error = error.localizedDescription }
        isBusy = false
    }
}
