import AVKit
import Combine

@MainActor
public final class AVPlayerManager {
    public typealias ProgressSubject = PassthroughSubject<
        (fromPlayer: Bool, current: TimeInterval, duration: TimeInterval),
        Never
    >

    public typealias ProgressHandler = (_ current: TimeInterval, _ duration: TimeInterval) -> Void

    private var avPlayer: AVPlayer?

    private var avPlayerItem: AVPlayerItem?

    private let avPlayerLayer: AVPlayerLayer = .init()

    private var displayLink: CADisplayLink?

    private var finishedHandler: (() -> Void)?

    private let progressSubject: ProgressSubject

    public init(
        assetName: String,
        fileName: String,
        view: UIView,
        progressSubject: ProgressSubject = .init()
    ) {
        self.progressSubject = progressSubject
        let asset = NSDataAsset(name: assetName)
        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
        do {
            try asset?.data.write(to: videoUrl)
        } catch {}

        self.setup(videoUrl: videoUrl, view: view)
    }

    public init(
        url: String,
        view: UIView,
        progressSubject: ProgressSubject = .init()
    ) {
        self.progressSubject = progressSubject
        guard let videoUrl = URL(string: url) else { return }
        self.setup(videoUrl: videoUrl, view: view)
    }

    public func changeFrame(bounds: CGRect) {
        self.avPlayerLayer.frame = bounds
    }

    @discardableResult
    public func play(fromInitial: Bool = true) async -> Result<Void, Never> {
        validateDisplayLink()

        return await withCheckedContinuation { continuation in
            self.play(fromInitial: fromInitial) {
                continuation.resume(returning: .success(()))
            }
        }
    }

    public func pause() {
        self.avPlayer?.pause()
        self.invalidateDisplayLink()
    }
}

private extension AVPlayerManager {
    func setup(videoUrl: URL, view: UIView) {
        self.avPlayerItem = .init(url: videoUrl)

        self.avPlayer = .init(playerItem: self.avPlayerItem)

        self.avPlayerLayer.videoGravity = .resizeAspect
        self.avPlayerLayer.player = self.avPlayer
        self.avPlayerLayer.frame = view.bounds
        self.avPlayerLayer.backgroundColor = view.backgroundColor?.cgColor
        view.layer.addSublayer(self.avPlayerLayer)

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

    func validateDisplayLink() {
        self.displayLink = CADisplayLink(
            target: self,
            selector: #selector(self.didUpdatePlaybackStatus)
        )
        self.displayLink!.add(
            to: .main,
            forMode: .common
        )
    }

    func invalidateDisplayLink() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }

    @objc func didUpdatePlaybackStatus() {
        guard let avPlayer, let currentItem = avPlayer.currentItem else { return }
        self.progressSubject
            .send((true, avPlayer.currentTime().seconds, currentItem.duration.seconds))
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
