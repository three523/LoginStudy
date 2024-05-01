//
//  AppleAuth.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/26.
//

import AuthenticationServices
import SwiftJWT

final class AppleAuth: NSObject, Auth {
    
    var nextAuth: Auth?
    private weak var viewController: UIViewController?
    private var completedLogin: ((Result<Bool, LoginError>) -> Void)?
    private var userIdentifier: Data? = UserDefaults.standard.data(forKey: "authCode")
    
    init(nextAuth: Auth? = nil, viewController: UIViewController) {
        self.viewController = viewController
        self.nextAuth = nextAuth
    }
    
    func login(_ authType: AuthType, completion: @escaping (Result<Bool, LoginError>) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
            
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

        guard let jwt = makeJWT() else {
            return
        }
        UserDefaults.standard.set(jwt, forKey: "jwt")
        self.completedLogin = completion
    }
    
    func logout() {
        print("logout")
        getRefreshToken { result in
            switch result {
            case .success(let refreshToken):
                guard let clientSecret = UserDefaults.standard.string(forKey: "jwt") else { return }
                self.revokeToken(clientSecret: clientSecret, token: refreshToken)
            case .failure(let failure):
                print("logout 실패")
                return
            }
        }
    }
    
    func fetchEmail(completion: ((Result<String, LoginError>) -> Void)?) {
        let email = UserDefaults.standard.string(forKey: "email")
        if let email {
            completion?(.success(email))
        } else {
            print("애플 사용자 정보를 가져오지 못했습니다.")
            completion?(.failure(.unknown))
        }
    }
    
    func fetchName(completion: ((Result<String, LoginError>) -> Void)?) {
        let userName = UserDefaults.standard.string(forKey: "userName")
        if let userName {
            completion?(.success(userName))
        } else {
            print("애플 사용자 정보를 가져오지 못했습니다.")
            completion?(.failure(.unknown))
        }
    }
    
    func fetchLoginState() -> Bool {
        guard let dataUserIdentifier = UserDefaults.standard.data(forKey: "authCode"),
              let userIdentifier = String(data: dataUserIdentifier, encoding: .utf8) else { return false }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("로그인중")
            case .revoked:
                print("인증 만료")
            default:
                print("나머지")
            }
        }
        return true
    }
    
    func makeJWT() -> String? {
        let myHeader = Header(kid: APPLE_KEY)
        struct MyClaims: Claims {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }

        let nowDate = Date()
        var dateComponent = DateComponents()
        dateComponent.month = 6
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + 3600
        let myClaims = MyClaims(iss: APPLE_TEAMID,
                                iat: iat,
                                exp: exp,
                                aud: "https://appleid.apple.com",
                                sub: BUNDLEID)

        var myJWT = JWT(header: myHeader, claims: myClaims)

        guard let url = Bundle.main.url(forResource: APPLE_FILENAME, withExtension: "p8") else{
            return nil
        }
        let privateKey: Data = try! Data(contentsOf: url, options: .alwaysMapped)

        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        guard let signedJWT = try? myJWT.sign(using: jwtSigner) else { return nil }

        return signedJWT
    }
    
    private func getRefreshToken(complete: @escaping (Result<String, LoginError>) -> Void) {
        guard let dataAuthCode = UserDefaults.standard.data(forKey: "authCode"),
              let authCode = String(data: dataAuthCode, encoding: .utf8) else { return }
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }

        let url = "https://appleid.apple.com/auth/token?client_id=\(BUNDLEID)&client_secret=\(jwt)&code=\(authCode)&grant_type=authorization_code"

        guard let request = try? URLRequest(url: URL(string: url)!, method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"]) else { return }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                print(error)
                complete(.failure(.error(error)))
                return
            }
            guard let data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                  let accessToken = json["access_token"] as? String,
                  let idToken = json["id_token"] as? String,
                let refreshToken = json["refresh_token"] as? String else { return }
            
            complete(.success(refreshToken))
        }.resume()
    }
    
    func revokeToken(clientSecret: String, token: String) {
        let url = "https://appleid.apple.com/auth/revoke?client_id=\(BUNDLEID)&client_secret=\(clientSecret)&token=\(token)&token_type_hint=refresh_token"
        guard let request = try? URLRequest(url: url, method: .post, headers: ["Content-Type": "application/x-www-form-urlencoded"]) else { return }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                print("로그아웃 성공")
            }
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
             
            
        }.resume()
    }
}

extension AppleAuth: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return viewController!.view.window!
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        
            UserDefaults.standard.setValue(appleIDCredential.authorizationCode, forKey: "authCode")
            let userIdentifier = appleIDCredential.user
            let userName = appleIDCredential.fullName
            let userEmail = appleIDCredential.email
                        
            if let userName {
                let name = (userName.familyName ?? "") + (userName.givenName ?? "")
                if name.isEmpty == false {
                    print("이름은 \(name)")
                    UserDefaults.standard.set((userName.familyName ?? "") + (userName.givenName ?? "") ?? "", forKey: "userName")
                }
            }
            if let userEmail {
                UserDefaults.standard.set(userEmail, forKey: "email")
            }
            
            completedLogin?(.success(true))
            completedLogin = nil
            return
        } else {
            completedLogin?(.failure(.unknown))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("login failed \(error.localizedDescription)")
    }
}
