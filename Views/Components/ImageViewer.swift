// ImageViewer.swift
import SwiftUI
import Photos

struct ImageViewer: View {
    let url: URL?
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var loadedImage: UIImage?
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .onAppear {
                            // Convert SwiftUI Image to UIImage for saving
                            Task {
                                if let url = url,
                                   let data = try? Data(contentsOf: url),
                                   let uiImage = UIImage(data: data) {
                                    loadedImage = uiImage
                                }
                            }
                        }
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1), 4)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    if scale < 1 {
                                        withAnimation {
                                            scale = 1
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                    if scale <= 1 {
                                        withAnimation {
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation {
                                if scale > 1 {
                                    scale = 1
                                    offset = .zero
                                } else {
                                    scale = 2
                                }
                            }
                        }
                        .contextMenu {
                            Button {
                                saveImage()
                            } label: {
                                Label("Save Image", systemImage: "square.and.arrow.down")
                            }
                            
                            Button {
                                copyImage()
                            } label: {
                                Label("Copy Image", systemImage: "doc.on.doc")
                            }
                            
                            ShareLink(item: url ?? URL(string: "")!) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                case .failure(_):
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text("Failed to load image")
                            .foregroundColor(.white)
                    }
                case .empty:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                @unknown default:
                    EmptyView()
                }
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .alert("Save Image", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveAlertMessage)
        }
    }
    
    private func saveImage() {
        guard let image = loadedImage else {
            saveAlertMessage = "Image not loaded yet"
            showSaveAlert = true
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            saveAlertMessage = "Image saved to Photos"
                            HapticManager.shared.successFeedback()
                        } else {
                            saveAlertMessage = "Failed to save image: \(error?.localizedDescription ?? "Unknown error")"
                            HapticManager.shared.errorFeedback()
                        }
                        showSaveAlert = true
                    }
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    saveAlertMessage = "Please allow access to Photos in Settings"
                    showSaveAlert = true
                    HapticManager.shared.errorFeedback()
                }
            case .notDetermined:
                // Request permission again
                PHPhotoLibrary.requestAuthorization { _ in
                    saveImage()
                }
            case .limited:
                // Still can save with limited access
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, _ in
                    DispatchQueue.main.async {
                        saveAlertMessage = success ? "Image saved to Photos" : "Failed to save image"
                        showSaveAlert = true
                        if success {
                            HapticManager.shared.successFeedback()
                        } else {
                            HapticManager.shared.errorFeedback()
                        }
                    }
                }
            @unknown default:
                break
            }
        }
    }
    
    private func copyImage() {
        guard let image = loadedImage else {
            saveAlertMessage = "Image not loaded yet"
            showSaveAlert = true
            return
        }
        
        UIPasteboard.general.image = image
        saveAlertMessage = "Image copied to clipboard"
        showSaveAlert = true
        HapticManager.shared.successFeedback()
    }
}
