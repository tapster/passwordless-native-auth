import Foundation

class AuthViewModel: ObservableObject {
    private let authService = AuthenticationService()
    var onAccessTokenReceived: (() -> Void)?

    @Published var state: AuthViewState = .emailInput
    @Published var email: String = ""
    @Published var verificationCode: String = ""

    init(state: AuthViewState = .emailInput) {
        self.state = state
    }

    func postEmail() {
        authService.postEmail(email: email) { _ in
            self.state = .verificationCodeInput
        }
    }

    func postVerificationCode() {
        authService.postVerificationCode(email: email, verificationCode: verificationCode) { newToken in
            if let newToken = newToken {
                self.onAccessTokenReceived?()
            } else {
                print("Failed to retrieve new token.")
            }
        }
    }

    var isValidEmail: Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    var isValidVerificationCode: Bool {
        let verificationCodeRegex = #"^\d{6}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", verificationCodeRegex)
        return predicate.evaluate(with: verificationCode)
    }
}
