import UIKit
import SwiftUI
import WebKit
import Turbo

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigationController = UINavigationController()
    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"

        let session = Session(webViewConfiguration: configuration)
        session.delegate = self
        session.pathConfiguration = PathConfiguration(sources: [
            .file(Bundle.main.url(forResource: "PathConfiguration", withExtension: "json")!),
        ])
        return session
    }()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        visit()
    }

    private func visit() {
        let url = URL(string: "http://localhost:3000")!
        let controller = VisitableViewController(url: url)
        session.visit(controller, action: .advance)
        navigationController.pushViewController(controller, animated: true)
    }

    private func createAuthenticationViewController() -> UIViewController {
        let authViewModel = AuthViewModel()
        var authView = AuthView(viewModel: authViewModel)

        authViewModel.onAccessTokenReceived = {
            DispatchQueue.main.async {
                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                self.visit()
            }
        }

        authView.dismissHandler = {
            self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }

        return UIHostingController(rootView: authView)
    }

}

extension SceneDelegate: SessionDelegate {
    func session(_ session: Turbo.Session, didProposeVisit proposal: Turbo.VisitProposal) {
        if proposal.properties["controller"] as? String == "authentication" {
            navigationController.present(createAuthenticationViewController(), animated: true)
        } else {
            let controller = VisitableViewController(url: proposal.url)
            session.visit(controller, options: proposal.options)

            navigationController.pushViewController(controller, animated: true)
        }
    }


    func session(_ session: Turbo.Session, didFailRequestForVisitable visitable: Turbo.Visitable, error: Error) {
        // TODO: Handle error
    }

    func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {
        // TODO: Handle exit
    }
}
