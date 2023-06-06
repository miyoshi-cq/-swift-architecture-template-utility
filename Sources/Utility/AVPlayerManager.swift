import AVKit

@MainActor
public final class AVPlayerManager {
    private static var avPlayer: AVPlayer?

    private static var avPlayerItem: AVPlayerItem?

    private static var finishedHandler: (() -> Void)?

    public static func createAVPlayer(assetName: String, fileName: String) {
        let asset = NSDataAsset(name: assetName)
        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
        do {
            try asset?.data.write(to: videoUrl)
        } catch {}

        self.avPlayerItem = .init(url: videoUrl)

        self.avPlayer = .init(playerItem: self.avPlayerItem)

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

    public static func addAVPlayer(_ view: UIView) {
        let layer: AVPlayerLayer = .init()
        layer.videoGravity = .resizeAspect
        layer.player = self.avPlayer
        layer.frame = view.bounds
        layer.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(layer)
    }

    @discardableResult
    public static func play() async -> Result<Void, Never> {
        await withCheckedContinuation { continuation in
            self.play {
                continuation.resume(returning: .success(()))
            }
        }
    }

    private static func play(finishedHandler: @escaping () -> Void) {
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

    @objc private static func end() {
        self.finishedHandler?()
        self.finishedHandler = nil
    }
}
