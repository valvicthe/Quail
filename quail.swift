import UIKit
import AVFoundation
import MediaPlayer

// structural song model representing file metadata details
struct track {
    let title: String
    let artist: String
    let album: String
    let duration: String
    let format: String
    let bitrate: String
}

class musicplayercontroller: UIViewController {
    
    // background audio player engine instance
    var audiosession = AVAudioSession.sharedInstance()
    var isplaying = false
    
    // metadata item sample
    let currenttrack = track(
        title: "quail",
        artist: "thequaildev",
        album: "quail",
        duration: "06:07",
        format: "audio/mpeg (mp3)",
        bitrate: "320 kbps cbr"
    )

    // ui components layout
    let albumartview = UIView()
    let titlelabel = UILabel()
    let artistlabel = UILabel()
    let metaextlabel = UILabel()
    let playbutton = UIButton(type: .system)
    let slider = UISlider()
    
    // parametric equalizer simulation faders
    let eqlabel = UILabel()
    var eqsliders: [UISlider] = []
    let eqfrequencies = ["60hz", "230hz", "910hz", "4khz", "14khz"]

    override func viewDidLoad() {
        super.viewdidload()
        
        // force dark mode styling layout
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        
        configurebackgroundaudio()
        setupinterface()
        connectapplemusiclibrary()
    }
    
    func configurebackgroundaudio() {
        do {
            // configure system session to allow background playback routing
            try audiosession.setCategory(.playback, mode: .default, options: [])
            try audiosession.setActive(true)
        } catch {
            print("failed to initialize background session route.")
        }
    }
    
    func setupinterface() {
        let screenwidth = view.frame.width
        
        // album art box definition
        albumartview.frame = CGRect(x: (screenwidth - 240)/2, y: 100, width: 240, height: 240)
        albumartview.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
        albumartview.layer.cornerRadius = 24
        let iconlabel = UILabel(frame: albumartview.bounds)
        iconlabel.text = "🐦"
        iconlabel.font = .systemFont(ofSize: 70)
        iconlabel.textAlignment = .center
        albumartview.addSubview(iconlabel)
        view.addSubview(albumartview)
        
        // main text track detail blocks
        titlelabel.frame = CGRect(x: 20, y: 365, width: screenwidth - 40, height: 28)
        titlelabel.text = currenttrack.title
        titlelabel.font = .systemFont(ofSize: 24, weight: .bold)
        titlelabel.textColor = .white
        titlelabel.textAlignment = .center
        view.addSubview(titlelabel)
        
        artistlabel.frame = CGRect(x: 20, y: 395, width: screenwidth - 40, height: 20)
        artistlabel.text = "\(currenttrack.artist) — \(currenttrack.album)"
        artistlabel.font = .systemFont(ofSize: 16, weight: .medium)
        artistlabel.textColor = .lightGray
        artistlabel.textAlignment = .center
        view.addSubview(artistlabel)
        
        // tech properties display block (format, bitrate, duration)
        metaextlabel.frame = CGRect(x: 20, y: 425, width: screenwidth - 40, height: 35)
        metaextlabel.text = "format: \(currenttrack.format)  |  bitrate: \(currenttrack.bitrate)  |  length: \(currenttrack.duration)"
        metaextlabel.font = .systemFont(ofSize: 11, weight: .regular)
        metaextlabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0)
        metaextlabel.textAlignment = .center
        metaextlabel.numberOfLines = 2
        view.addSubview(metaextlabel)
        
        // main progress timeline tracker bar
        slider.frame = CGRect(x: 40, y: 475, width: screenwidth - 80, height: 20)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 18
        slider.minimumTrackTintColor = .systemCyan
        slider.maximumTrackTintColor = .darkGray
        view.addSubview(slider)
        
        // simple play state button layout
        playbutton.frame = CGRect(x: (screenwidth - 64)/2, y: 515, width: 64, height: 64)
        playbutton.backgroundColor = .white
        playbutton.layer.cornerRadius = 32
        playbutton.setTitle("▶️", for: .normal)
        playbutton.titleLabel?.font = .systemFont(ofSize: 24)
        playbutton.addTarget(self, action: #selector(handleplay), for: .touchUpInside)
        view.addSubview(playbutton)
        
        // equalizer header labeling setup
        eqlabel.frame = CGRect(x: 30, y: 605, width: screenwidth - 60, height: 20)
        eqlabel.text = "parametric equalizer config"
        eqlabel.font = .systemFont(ofSize: 12, weight: .bold)
        eqlabel.textColor = .darkGray
        view.addSubview(eqlabel)
        
        // multi-band vertical eq array configuration engine layout
        let eqstarty: CGFloat = 635
        let eqtotalwidth = screenwidth - 60
        let spacing = eqtotalwidth / 5
        
        for i in 0..<5 {
            let fader = UISlider()
            // rotate the tracking bar vertically to act as mixing console component
            fader.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            fader.frame = CGRect(x: 30 + (CGFloat(i) * spacing), y: eqstarty, width: 40, height: 110)
            fader.minimumValue = -12
            fader.maximumValue = 12
            fader.value = Float.random(in: -4...6) // visual variance default state
            fader.minimumTrackTintColor = .systemCyan
            view.addSubview(fader)
            eqsliders.append(fader)
            
            let freqlabel = UILabel(frame: CGRect(x: 30 + (CGFloat(i) * spacing) - 10, y: eqstarty + 115, width: 60, height: 15))
            freqlabel.text = eqfrequencies[i]
            freqlabel.font = .systemFont(ofSize: 10, weight: .regular)
            freqlabel.textColor = .gray
            freqlabel.textAlignment = .center
            view.addSubview(freqlabel)
        }
    }
    
    @objc func handleplay() {
        isplaying.toggle()
        playbutton.setTitle(isplaying ? "⏸️" : "▶️", for: .normal)
    }
    
    func connectapplemusiclibrary() {
        // checks local media system configuration authorizations for native system apple music integration profiles
        let status = MPMediaLibrary.authorizationStatus()
        if status == .notDetermined {
            MPMediaLibrary.requestAuthorization { _ in }
        }
    }
}

// initialization entrypoints definition block wrapper
class appdelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = musicplayercontroller()
        window?.makeKeyAndVisible()
        return true
    }
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appdelegate.self))
