import Combine
import SwiftUI

enum AuthViewState {
    case emailInput
    case verificationCodeInput
}

struct AuthView: View {
    @ObservedObject var viewModel = AuthViewModel()

    var dismissHandler: (() -> Void)?

    var body: some View {
        ZStack {
            VStack {
                switch viewModel.state {
                case .emailInput:
                    VStack(spacing: 18) {
                        Text("Lets get started")
                            .bold()
                            .font(.title)

                        Text("Enter your email address. We'll send you a verification code to enter on the next screen.")

                        TextField("Email Address",text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8.0)
                            .padding([.leading, .trailing])

                        Button(action: {
                            // TODO: post the email
                            viewModel.postEmail()
                        }) {
                            HStack {
                                Spacer()
                                Text("Send Code")
                                    .foregroundColor(.white)
                                    .bold()
                                Spacer()
                            }.padding()
                                .background(Color.blue)
                                .cornerRadius(8.0)
                        }
                        .padding()
                        .disabled(!viewModel.isValidEmail)
                        .opacity(viewModel.isValidEmail ? 1.0 : 0.5)

                        Spacer()
                    }
                    .padding()
                case .verificationCodeInput:
                    VStack(spacing: 18) {
                        Text("Check Your Email")
                            .bold()
                            .font(.title)

                        Text("Please enter the 6 digit verification code we just sent to your email __\(viewModel.email)__ to complete sign in.")

                        TextField("Verification code",text: $viewModel.verificationCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8.0)
                            .padding([.leading, .trailing])

                        Button(action: {
                            // TODO: post the verification code
                            viewModel.postVerificationCode()
                        }) {
                            HStack {
                                Spacer()
                                Text("Verify Code")
                                    .foregroundColor(.white)
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8.0)
                        }
                        .padding()
                        .disabled(!viewModel.isValidVerificationCode)
                        .opacity(viewModel.isValidVerificationCode ? 1.0 : 0.5)

                        Spacer()
                    }
                    .padding()
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismissHandler?()
                    }) {
                        Image(systemName: "xmark")
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                AuthView(viewModel: AuthViewModel(state: .emailInput))
                    .previewDisplayName("Email Input")

                AuthView(viewModel: AuthViewModel(state: .verificationCodeInput))
                    .previewDisplayName("Verification Code Input")
            }
        }
    }
}
