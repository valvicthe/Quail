import UIKit
import AVFoundation
import MediaPlayer

// MARK: - Core Audio Track Architecture
struct TrackMetadata {
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let fileType: String
    let bitRate: String
    let frequency: String
}

// MARK: - Ultimate Music Client Interface
class QuailPlayerViewController: UIViewController {
    
    // System Engines
    private let audioSession = AVAudioSession.sharedInstance()
    private var isPlaying = false
    private var playbackTimer: Timer?
    private var currentPlayTime: TimeInterval = 0
    
    // Sample Premium Audio Metadata Container
    private let activeTrack = TrackMetadata(
        title: "Quail Melodies (Cloud Mix)",
        artist: "The Quail Developer",
        album: "Windows Compilations, Vol. 1",
        duration: 222.0, // 3 minutes, 42 seconds
        fileType: "FLAC (Lossless Mastering)",
        bitRate: "1411 kbps",
        frequency: "48.0 kHz / 24-bit"
    )
    
    // MARK: - Premium UI Components
    private let GlassBackdropView = UIView()
    private let AlbumArtContainer = UIView()
    private let SongTitleLabel = UILabel()
    private let ArtistAlbumLabel = UILabel()
    
    // Metadata Quality Badge Matrix
    private let LosslessBadge = UILabel()
    private let BitrateBadge = UILabel()
    
    // Media Playback Controls
    private let TimelineSlider = UISlider()
    private let TimeElapsedLabel = UILabel()
    private let TimeRemainingLabel = UILabel()
    private let PlayPauseButton = UIButton(type: .system)
    private let ForwardButton = UIButton(type: .system)
    private let RewindButton = UIButton(type: .system)
    
    // High-Fidelity Audio Controls
    private let EqSectionTitle = UILabel()
    private var EqFaders: [UISlider] = []
    private let EqFrequencies = ["60Hz", "230Hz", "910Hz", "4kHz", "14kHz"]
    
    // Real-Time Visualizer Engine Simulation
    private var VisualizerBars: [UIView] = []
    private let VisualizerContainer = UIStackView()

    // MARK: - Lifecycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enforce pure hardware dark mode ecosystem
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = UIColor(red: 0.03, green: 0.03, blue: 0.04, alpha: 1.0)
        
        initializeCoreAudioRouting()
        buildPremiumUserInterface()
        beginVisualizerAnimationEngine()
    }
    
    // MARK: - Audio Routing & Persistence Engines
    private func initializeCoreAudioRouting() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            // Connect to iOS system Command Center (enables lock screen controls)
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.playCommand.addTarget { [weak self] _ in
                self?.handlePlaybackToggle()
                return .success
            }
            commandCenter.pauseCommand.addTarget { [weak self] _ in
                self?.handlePlaybackToggle()
                return .success
            }
            
            updateSystemNowPlayingInterface()
        } catch {
            print("Engine Routing Error Context: \(error.localizedDescription)")
        }
    }
    
    private func updateSystemNowPlayingInterface() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = activeTrack.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = activeTrack.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = activeTrack.album
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = activeTrack.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - User Interface Architecture Layout
    private func buildPremiumUserInterface() {
        let viewWidth = view.frame.width
        
        // 1. Futuristic Album Art Work Box
        AlbumArtContainer.frame = CGRect(x: (viewWidth - 260) / 2, y: 90, width: 260, height: 260)
        AlbumArtContainer.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.11, alpha: 1.0)
        AlbumArtContainer.layer.cornerRadius = 28
        AlbumArtContainer.layer.shadowColor = UIColor.systemCyan.cgColor
        AlbumArtContainer.layer.shadowOpacity = 0.25
        AlbumArtContainer.layer.shadowOffset = CGSize(width: 0, height: 12)
        AlbumArtContainer.layer.shadowRadius = 20
        
        let artworkSymbol = UILabel(frame: AlbumArtContainer.bounds)
        artworkSymbol.text = "🐦"
        artworkSymbol.font = .systemFont(ofSize: 85)
        artworkSymbol.textAlignment = .center
        AlbumArtContainer.addSubview(artworkSymbol)
        view.addSubview(AlbumArtContainer)
        
        // 2. Metadata Text Modules
        SongTitleLabel.frame = CGRect(x: 24, y: 380, width: viewWidth - 48, height: 32)
        SongTitleLabel.text = activeTrack.title
        SongTitleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        SongTitleLabel.textColor = .white
        SongTitleLabel.textAlignment = .center
        view.addSubview(SongTitleLabel)
        
        ArtistAlbumLabel.frame = CGRect(x: 24, y: 415, width: viewWidth - 48, height: 22)
        ArtistAlbumLabel.text = "\(activeTrack.artist) • \(activeTrack.album)"
        ArtistAlbumLabel.font = .systemFont(ofSize: 15, weight: .medium)
        ArtistAlbumLabel.textColor = .systemGray
        ArtistAlbumLabel.textAlignment = .center
        view.addSubview(ArtistAlbumLabel)
        
        // 3. Audio Quality Spec Badges (Better than Apple Music Lossless tags)
        LosslessBadge.frame = CGRect(x: (viewWidth / 2) - 85, y: 448, width: 65, height: 18)
        LosslessBadge.text = activeTrack.fileType.components(separatedBy: " ").first
        LosslessBadge.font = .systemFont(ofSize: 10, weight: .bold)
        LosslessBadge.textColor = .systemCyan
        LosslessBadge.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.12)
        LosslessBadge.layer.cornerRadius = 4
        LosslessBadge.clipsToBounds = true
        LosslessBadge.textAlignment = .center
        view.addSubview(LosslessBadge)
        
        BitrateBadge.frame = CGRect(x: (viewWidth / 2) + 20, y: 448, width: 65, height: 18)
        BitrateBadge.text = activeTrack.bitRate
        BitrateBadge.font = .systemFont(ofSize: 10, weight: .bold)
        BitrateBadge.textColor = .systemGreen
        BitrateBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        BitrateBadge.layer.cornerRadius = 4
        BitrateBadge.clipsToBounds = true
        BitrateBadge.textAlignment = .center
        view.addSubview(BitrateBadge)
        
        // 4. Studio Timeline Scrubbers
        TimelineSlider.frame = CGRect(x: 24, y: 490, width: viewWidth - 48, height: 24)
        TimelineSlider.minimumValue = 0
        TimelineSlider.maximumValue = Float(activeTrack.duration)
        TimelineSlider.value = Float(currentPlayTime)
        TimelineSlider.minimumTrackTintColor = .systemCyan
        TimelineSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.1)
        TimelineSlider.setThumbImage(UIImage(), for: .normal) // Sleek line-look thumb
        TimelineSlider.addTarget(self, action: #selector(handleScrubbing), for: .valueChanged)
        view.addSubview(TimelineSlider)
        
        TimeElapsedLabel.frame = CGRect(x: 24, y: 518, width: 60, height: 14)
        TimeElapsedLabel.text = "0:00"
        TimeElapsedLabel.font = .systemFont(ofSize: 12, weight: .medium)
        TimeElapsedLabel.textColor = .darkGray
        view.addSubview(TimeElapsedLabel)
        
        TimeRemainingLabel.frame = CGRect(x: viewWidth - 84, y: 518, width: 60, height: 14)
        TimeRemainingLabel.text = "-3:42"
        TimeRemainingLabel.font = .systemFont(ofSize: 12, weight: .medium)
        TimeRemainingLabel.textColor = .darkGray
        TimeRemainingLabel.textAlignment = .right
        view.addSubview(TimeRemainingLabel)
        
        // 5. High-Fidelity Transport Deck Control Layout
        let deckCenterY: CGFloat = 555
        
        PlayPauseButton.frame = CGRect(x: (viewWidth - 68) / 2, y: deckCenterY, width: 68, height: 68)
        PlayPauseButton.backgroundColor = .white
        PlayPauseButton.layer.cornerRadius = 34
        PlayPauseButton.setTitle("▶️", for: .normal)
        PlayPauseButton.titleLabel?.font = .systemFont(ofSize: 22)
        PlayPauseButton.setTitleColor(.black, for: .normal)
        PlayPauseButton.layer.shadowColor = UIColor.white.cgColor
        PlayPauseButton.layer.shadowOpacity = 0.2
        PlayPauseButton.layer.shadowRadius = 10
        PlayPauseButton.addTarget(self, action: #selector(handlePlaybackToggle), for: .touchUpInside)
        view.addSubview(PlayPauseButton)
        
        ForwardButton.frame = CGRect(x: (viewWidth / 2) + 68, y: deckCenterY + 14, width: 40, height: 40)
        ForwardButton.setTitle("⏭️", for: .normal)
        ForwardButton.titleLabel?.font = .systemFont(ofSize: 22)
        view.addSubview(ForwardButton)
        
        RewindButton.frame = CGRect(x: (viewWidth / 2) - 108, y: deckCenterY + 14, width: 40, height: 40)
        RewindButton.setTitle("残留", for: .normal)
        RewindButton.setTitle("⏮️", for: .normal)
        RewindButton.titleLabel?.font = .systemFont(ofSize: 22)
        view.addSubview(RewindButton)
        
        // 6. Professional Mastering Parametric Equalizer Rack
        EqSectionTitle.frame = CGRect(x: 28, y: 655, width: viewWidth - 56, height: 16)
        EqSectionTitle.text = "Studio Parametric EQ Rack"
        EqSectionTitle.font = .systemFont(ofSize: 11, weight: .bold)
        EqSectionTitle.textColor = UIColor.white.withAlphaComponent(0.3)
        view.addSubview(EqSectionTitle)
        
        let eqBaseY: CGFloat = 685
        let eqWorkingWidth = viewWidth - 56
        let columnSpacing = eqWorkingWidth / 5
        
        for i in 0..<5 {
            let columnX = 28 + (CGFloat(i) * columnSpacing)
            
            let faderSlider = UISlider()
            faderSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            faderSlider.frame = CGRect(x: columnX, y: eqBaseY, width: 34, height: 100)
            faderSlider.minimumValue = -12
            faderSlider.maximumValue = 12
            faderSlider.value = Float.random(in: -3...5)
            faderSlider.minimumTrackTintColor = .systemCyan
            faderSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.05)
            view.addSubview(faderSlider)
            EqFaders.append(faderSlider)
            
            let frequencyLabel = UILabel(frame: CGRect(x: columnX - 13, y: eqBaseY + 105, width: 60, height: 14))
            frequencyLabel.text = EqFrequencies[i]
            frequencyLabel.font = .systemFont(ofSize: 10, weight: .bold)
            frequencyLabel.textColor = .darkGray
            frequencyLabel.textAlignment = .center
            view.addSubview(frequencyLabel)
        }
        
        // 7. Simulated Live Spectrum Analyzer Layout Stack
        VisualizerContainer.axis = .horizontal
        VisualizerContainer.distribution = .fillEqually
        VisualizerContainer.alignment = .bottom
        VisualizerContainer.spacing = 3
        VisualizerContainer.frame = CGRect(x: 30, y: 345, width: viewWidth - 60, height: 22)
        
        for _ in 0..<32 {
            let bar = UIView()
            bar.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.15)
            bar.layer.cornerRadius = 1
            VisualizerContainer.addArrangedSubview(bar)
            VisualizerBars.append(bar)
        }
        view.addSubview(VisualizerContainer)
    }
    
    // MARK: - Core Execution Logic
    @objc private func handlePlaybackToggle() {
        isPlaying.toggle()
        PlayPauseButton.setTitle(isPlaying ? "⏸️" : "▶️", for: .normal)
        
        if isPlaying {
            // Spin up structural playback timeline loop engine
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.incrementPlaybackTimeline()
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                self.AlbumArtContainer.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
                self.AlbumArtContainer.layer.shadowOpacity = 0.45
            })
        } else {
            playbackTimer?.invalidate()
            playbackTimer = nil
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                self.AlbumArtContainer.transform = .identity
                self.AlbumArtContainer.layer.shadowOpacity = 0.25
            })
        }
    }
    
    @objc private func handleScrubbing() {
        currentPlayTime = TimeInterval(TimelineSlider.value)
        syncTimelineInterfaceLabels()
    }
    
    private func incrementPlaybackTimeline() {
        guard currentPlayTime < activeTrack.duration else {
            currentPlayTime = 0
            handlePlaybackToggle()
            return
        }
        currentPlayTime += 1
        TimelineSlider.setValue(Float(currentPlayTime), animated: true)
        syncTimelineInterfaceLabels()
        updateSystemNowPlayingInterface()
    }
    
    private func syncTimelineInterfaceLabels() {
        let elapsedMinutes = Int(currentPlayTime) / 60
        let elapsedSeconds = Int(currentPlayTime) % 60
        TimeElapsedLabel.text = String(format: "%d:%02d", elapsedMinutes, elapsedSeconds)
        
        let remainingTime = activeTrack.duration - currentPlayTime
        let remainingMinutes = Int(remainingTime) / 60
        let remainingSeconds = Int(remainingTime) % 60
        TimeRemainingLabel.text = String(format: "-%d:%02d", remainingMinutes, remainingSeconds)
    }
    
    private func beginVisualizerAnimationEngine() {
        // High refresh rate UI rendering frame engine
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            for bar in self.VisualizerBars {
                let currentScale = self.isPlaying ? CGFloat.random(in: 0.15...1.0) : 0.08
                UIView.animate(withDuration: 0.08, delay: 0, options: [.curveEaseInOut], animations: {
                    bar.frame.size.height = currentScale * 22
                    bar.backgroundColor = self.isPlaying ? .systemCyan : UIColor.white.withAlphaComponent(0.05)
                })
            }
        }
    }
}

// MARK: - Core System Entry Point Application Delegate
class QuailAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = QuailPlayerViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(QuailAppDelegate.self))
