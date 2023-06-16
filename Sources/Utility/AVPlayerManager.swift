import AVKit

@MainActor
public final class AVPlayerManager {
    private var avPlayer: AVPlayer?

    private var avPlayerItem: AVPlayerItem?

    private var finishedHandler: (() -> Void)?

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

    private func setup(videoUrl: URL, view: UIView) {
        self.avPlayerItem = .init(url: videoUrl)

        self.avPlayer = .init(playerItem: self.avPlayerItem)

        let layer: AVPlayerLayer = .init()
        layer.videoGravity = .resizeAspect
        layer.player = self.avPlayer
        layer.frame = view.bounds
        layer.backgroundColor = view.backgroundColor?.cgColor
        view.layer.addSublayer(layer)

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

    @discardableResult
    public func play() async -> Result<Void, Never> {
        await withCheckedContinuation { continuation in
            self.play {
                continuation.resume(returning: .success(()))
            }
        }
    }

    private func play(finishedHandler: @escaping () -> Void) {
        guard let avPlayer else {
            finishedHandler()
            return
        }

        self.finishedHandler = finishedHandler

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.ambient)
        try? audioSession.setActive(true)

        avPlayer.seek(to: CMTime.zero)
        avPlayer.play()
    }

    @objc private func end() {
        self.finishedHandler?()
        self.finishedHandler = nil
    }
}
