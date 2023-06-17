import AVKit

@MainActor
public final class AVPlayerManager {
    private var avPlayer: AVPlayer?

    private var avPlayerItem: AVPlayerItem?

    private var finishedHandler: (() -> Void)?

    private let layer: AVPlayerLayer = .init()

    public init(assetName: String, fileName: String, view: UIView) {
        let asset = NSDataAsset(name: assetName)
        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
        do {
            try asset?.data.write(to: videoUrl)
        } catch {}

        self.setup(videoUrl: videoUrl, view: view)
    }

    public init(url: String, view: UIView) {
        guard let videoUrl = URL(string: url) else { return }
        self.setup(videoUrl: videoUrl, view: view)
    }

    public func changeFrame(bounds: CGRect) {
        self.layer.frame = bounds
    }

    @discardableResult
    public func play(fromInitial: Bool = true) async -> Result<Void, Never> {
        await withCheckedContinuation { continuation in
            self.play(fromInitial: fromInitial) {
                continuation.resume(returning: .success(()))
            }
        }
    }

    public var isPlaying: Bool {
        guard let avPlayer else { return false }
        return avPlayer.rate != 0 && avPlayer.error == nil
    }

    public func pause() {
        self.avPlayer?.pause()
    }
}

private extension AVPlayerManager {
    func setup(videoUrl: URL, view: UIView) {
        self.avPlayerItem = .init(url: videoUrl)

        self.avPlayer = .init(playerItem: self.avPlayerItem)

        self.layer.videoGravity = .resizeAspect
        self.layer.player = self.avPlayer
        self.layer.frame = view.bounds
        self.layer.backgroundColor = view.backgroundColor?.cgColor
        view.layer.addSublayer(self.layer)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.end),
            name: .AVPlayerItemDidPlayToEndTime,
            object: self.avPlayerItem
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.end),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: self.avPlayerItem
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.end),
            name: .AVPlayerItemPlaybackStalled,
            object: self.avPlayerItem
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.end),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    func play(fromInitial: Bool = true, finishedHandler: @escaping () -> Void) {
        guard let avPlayer else {
            finishedHandler()
            return
        }

        self.finishedHandler = finishedHandler

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.ambient)
        try? audioSession.setActive(true)

        if fromInitial {
            avPlayer.seek(to: CMTime.zero)
        }
        avPlayer.play()
    }

    @objc func end() {
        self.finishedHandler?()
        self.finishedHandler = nil
    }
}
