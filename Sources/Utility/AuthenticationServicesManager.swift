#if !os(macOS)
import AuthenticationServices

@MainActor
public class AuthenticationServicesManager: NSObject,
    ASAuthorizationControllerDelegate,
    ASWebAuthenticationPresentationContextProviding
{
    private let successHandler: (String) -> Void
    private let failureHandler: () -> Void

    private weak var window: UIWindow?

    private var authenticationSession: ASWebAuthenticationSession?

    public init(
        successHandler: @escaping (String) -> Void,
        failureHandler: @escaping () -> Void
    ) {
        self.successHandler = successHandler
        self.failureHandler = failureHandler
    }

    public func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    public func setup(window: UIWindow) {
        self.window = window
    }

    /// Appleログイン成功時
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityToken = appleIDCredential.identityToken else { return }

            let token = String(decoding: identityToken, as: UTF8.self)
            self.successHandler(token)
        }
    }

    /// Appleログイン失敗時
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        self.failureHandler()
    }

    public func presentationAnchor(for session: ASWebAuthenticationSession)
        -> ASPresentationAnchor
    {
        self.window!
    }

    public func startSession(
        url: URL,
        callbackURLScheme: String,
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    ) {
        self.authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackURLScheme,
            completionHandler: completionHandler
        )
        self.authenticationSession?.presentationContextProvider = self
        self.authenticationSession?.start()
    }
}
#endif
