//
//  NaverAuth.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

import NaverThirdPartyLogin
import Alamofire

final class NaverAuth: NSObject, Auth {
    var nextAuth: Auth?
    private var completedLogin: ((Result<Bool, LoginError>) -> Void)?
    private let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    init(auth: Auth?) {
        self.nextAuth = auth
        super.init()
        loginInstance?.delegate = self
    }
    
    func login(_ authType: AuthType, completion: @escaping (Result<Bool, LoginError>) -> Void) {
        loginInstance?.requestThirdPartyLogin()
        self.completedLogin = completion
    }
    
    func logout() {
        loginInstance?.requestDeleteToken()
    }
    
    func fetchEmail(completion: ((Result<String, LoginError>) -> Void)?) {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow(),
              let tokenType = loginInstance?.tokenType,
              let accessToken = loginInstance?.accessToken,
            let url = URL(string: "https://openapi.naver.com/v1/nid/me") else {
            return
        }
        
        let authorization = "\(tokenType) \(accessToken)"
        var request = URLRequest(url: url)
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                completion?(.failure(.error(error)))
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299,
               let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                          let response = json["response"] as? [String: AnyObject],
                          let email = response["email"] as? String else {
                        completion?(.failure(LoginError.unknown))
                        return
                    }
                    completion?(.success(email))
                } catch let error as NSError {
                    print(error)
                    completion?(.failure(.error(error)))
                }
                return
            }
            completion?(.failure(.unknown))
        }.resume()
    }
    
    func fetchLoginState() -> Bool {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else {
            return false
        }
        return isValidAccessToken
    }
    
}

extension NaverAuth: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("success naver")
        completedLogin?(.success(true))
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("delete token")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print(error.localizedDescription)
        completedLogin?(.failure(.error(error)))
    }
    
}
