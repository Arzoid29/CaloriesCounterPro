import SwiftUI
import PhotosUI
import SwiftData

struct MenuScannerView: View {
    @StateObject private var viewModel: MenuScannerViewModel
    @State private var showCamera = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var animateHeader = false
    @State private var showRestaurantPicker = false

    @Query(sort: \Restaurant.name, order: .forward)
    private var restaurants: [Restaurant]

    init() {
        let textRecognition = TextRecognitionService()
        let geminiService = GeminiService(apiKey: AppConfig.geminiAPIKey)
        let container = ModelContainerProvider.shared.container
        let scanHistory = ScanHistoryStore(modelContainer: container)
        let restaurantStore = RestaurantStore(modelContainer: container)
        let useCase = ScanMenuUseCase(
            textRecognition: textRecognition,
            calorieEstimation: geminiService,
            scanHistory: scanHistory,
            restaurantRepository: restaurantStore
        )
        _viewModel = StateObject(wrappedValue: MenuScannerViewModel(scanMenuUseCase: useCase))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                mainContent
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCamera) {
                CameraView(image: $capturedImage)
            }
            .onChange(of: capturedImage) { _, newImage in
                if let image = newImage {
                    Task {
                        await viewModel.processImage(image)
                        capturedImage = nil
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        capturedImage = image
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.showResults) {
                ResultsView(dishes: viewModel.dishes, restaurantName: viewModel.restaurantName) {
                    viewModel.resetScan()
                }
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateHeader = true
                }
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            heroSection
            VStack(spacing: Theme.spacingL) {
                restaurantField
                scanOptionsGrid
                if viewModel.isLoading { loadingSection }
                if let error = viewModel.errorMessage { errorSection(error) }
                if viewModel.showManualInput { manualInputSection }
                if viewModel.scanSucceeded { successSection }
            }
            .padding(.horizontal)
            .padding(.top, Theme.spacingXL)
            .padding(.bottom, Theme.spacingXXL)
        }
    }

    private var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Theme.accent.opacity(0.15),
                    Theme.accentSecondary.opacity(0.08),
                    Theme.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(spacing: Theme.spacingL) {
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.15))
                        .frame(width: 110, height: 110)
                        .scaleEffect(animateHeader ? 1.0 : 0.8)
                    Circle()
                        .fill(Theme.accent.opacity(0.08))
                        .frame(width: 140, height: 140)
                        .scaleEffect(animateHeader ? 1.0 : 0.6)
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.accentGradient)
                        .scaleEffect(animateHeader ? 1.0 : 0.5)
                }
                VStack(spacing: Theme.spacingS) {
                    Text("Calories Counter Pro")
                        .font(.title.bold())
                    Text(String(localized: "scanner.subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacingXL)
                }
                .opacity(animateHeader ? 1.0 : 0.0)
                usageIndicator
                    .opacity(animateHeader ? 1.0 : 0.0)
            }
            .padding(.top, Theme.spacingXXL)
            .padding(.bottom, Theme.spacingL)
        }
    }

    private var usageIndicator: some View {
        Group {
            if viewModel.isSubscribed {
                HStack(spacing: Theme.spacingS) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text(String(localized: "usage.premium"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, Theme.spacingM)
                .padding(.vertical, Theme.spacingS)
                .background(Color.yellow.opacity(0.15))
                .clipShape(Capsule())
            } else {
                Button {
                    viewModel.showPaywall = true
                } label: {
                    HStack(spacing: Theme.spacingS) {
                        Image(systemName: viewModel.canScan ? "sparkles" : "lock.fill")
                            .foregroundStyle(viewModel.canScan ? Theme.accent : .red)
                        if viewModel.canScan {
                            Text(String(format: NSLocalizedString("usage.remaining", comment: ""), viewModel.remainingFreeScans))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)
                        } else {
                            Text(String(localized: "usage.limit_reached"))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.red)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .padding(.horizontal, Theme.spacingM)
                    .padding(.vertical, Theme.spacingS)
                    .background(viewModel.canScan ? Theme.accentBackground : Color.red.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
    }

    private var restaurantField: some View {
        VStack(spacing: Theme.spacingS) {
            HStack(spacing: Theme.spacingM) {
                ZStack {
                    Circle()
                        .fill(Theme.accentBackground)
                        .frame(width: 36, height: 36)
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Theme.accent)
                }
                if let selected = viewModel.selectedRestaurant {
                    HStack {
                        Text(selected.name)
                            .font(.subheadline)
                        Spacer()
                        Button {
                            viewModel.selectRestaurant(nil)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                } else {
                    TextField(String(localized: "scanner.restaurant_placeholder"), text: $viewModel.restaurantName)
                        .font(.subheadline)
                }
            }
            .padding(Theme.spacingM)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.cardShadowColor, radius: 4, y: 2)
            if !restaurants.isEmpty && viewModel.selectedRestaurant == nil {
                Button {
                    showRestaurantPicker = true
                } label: {
                    HStack {
                        Image(systemName: "building.2")
                        Text(String(localized: "scanner.select_restaurant"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .font(.caption)
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, Theme.spacingM)
                    .padding(.vertical, Theme.spacingS)
                }
                .sheet(isPresented: $showRestaurantPicker) {
                    RestaurantPickerSheet(
                        restaurants: restaurants,
                        selectedRestaurant: $viewModel.selectedRestaurant
                    )
                }
            }
        }
    }

    private var scanOptionsGrid: some View {
        VStack(spacing: Theme.spacingM) {
            Button {
                showCamera = true
            } label: {
                HStack(spacing: Theme.spacingM) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "camera.fill")
                            .font(.title3)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "scanner.take_photo"))
                            .font(.headline)
                        Text(String(localized: "scanner.subtitle"))
                            .font(.caption)
                            .opacity(0.8)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .opacity(0.6)
                }
                .foregroundStyle(.white)
                .padding(Theme.spacingL)
                .frame(maxWidth: .infinity)
                .background(Theme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .shadow(color: Theme.accent.opacity(0.3), radius: 8, y: 4)
            }
            HStack(spacing: Theme.spacingM) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    VStack(spacing: Theme.spacingS) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentBackground)
                                .frame(width: 48, height: 48)
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                        }
                        Text(String(localized: "scanner.select_gallery"))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingL)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: Theme.cardShadowColor, radius: 4, y: 2)
                }
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.showManualInput.toggle()
                    }
                } label: {
                    VStack(spacing: Theme.spacingS) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentBackground)
                                .frame(width: 48, height: 48)
                            Image(systemName: "keyboard")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                        }
                        Text(String(localized: "scanner.manual_input"))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingL)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: Theme.cardShadowColor, radius: 4, y: 2)
                }
            }
        }
    }

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Theme.accent.opacity(0.2), lineWidth: 8)
                    .frame(width: 64, height: 64)
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Theme.accent)
                    .rotationEffect(.degrees(viewModel.isAnalyzing ? 360 : 0))
                    .animation(viewModel.isAnalyzing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isAnalyzing)
            }
            Text(String(localized: "scanning.loading"))
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.top, 32)
    }

    private var successSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundColor(.green)
                .transition(.scale)
                .onAppear {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            Text(String(localized: "scanning.success"))
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.top, 32)
    }

    private func errorSection(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.red)
                .onAppear {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            Text(error)
                .font(.headline)
                .foregroundColor(.red)
            Button(String(localized: "scanning.retry")) {
                viewModel.resetScan()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 32)
    }

    private var manualInputSection: some View {
        VStack(spacing: Theme.spacingM) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Theme.accentBackground)
                        .frame(width: 32, height: 32)
                    Image(systemName: "text.alignleft")
                        .font(.caption)
                        .foregroundStyle(Theme.accent)
                }
                Text(String(localized: "scanner.manual_title"))
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.showManualInput = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            TextEditor(text: $viewModel.manualMenuText)
                .frame(minHeight: 150)
                .padding(Theme.spacingM)
                .scrollContentBackground(.hidden)
                .background(Theme.tertiaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                        .stroke(Theme.border.opacity(0.5), lineWidth: 1)
                )
            Button {
                Task { await viewModel.analyzeManualText() }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text(String(localized: "scanner.analyze"))
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
            }
            .disabled(viewModel.manualMenuText.isEmpty || viewModel.isLoading)
            .opacity(viewModel.manualMenuText.isEmpty ? 0.5 : 1.0)
        }
        .padding(Theme.spacingL)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.cardShadowColor, radius: 6, y: 3)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    MenuScannerView()
}
