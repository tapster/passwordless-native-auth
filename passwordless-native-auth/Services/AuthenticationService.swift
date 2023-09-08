import Foundation
import KeychainAccess
import WebKit

class AuthenticationService {
    private let baseURL = URL(string: "http://localhost:3000")!

    func postEmail(email: String, completion: @escaping (_ token: String?) -> Void) {
        let url = baseURL.appendingPathComponent("auth.json")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = ["email": email]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("An error occurred: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any],
               let msg = json["msg"] as? String {
                DispatchQueue.main.async {
                    completion(msg)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        task.resume()
    }

    func postVerificationCode(email: String, verificationCode: String, completion: @escaping (_ accessToken: String?) -> Void) {
        let url = baseURL.appendingPathComponent("auth_verification.json")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = ["email": email, "verification_code": verificationCode]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("An error occurred: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any],
               let newToken = json["token"] as? String {
                let headers = httpResponse.allHeaderFields as? [String: String]

                do {
                    let keychain = Keychain(service: "your-app-name-here")
                    try keychain.set(newToken, key: "AuthToken")

                    DispatchQueue.main.async {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers!, for: self.baseURL)
                        HTTPCookieStorage.shared.setCookies(cookies, for: self.baseURL, mainDocumentURL: nil)
                        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
                        cookies.forEach { cookie in
                            cookieStore.setCookie(cookie, completionHandler: nil)
                        }
                    }
                } catch {
                    print("Keychain storage or cookies error: \(error)")
                }

                DispatchQueue.main.async {
                    completion(newToken)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        task.resume()
    }
}
