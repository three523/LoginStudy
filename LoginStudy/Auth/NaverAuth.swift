//
//  NaverAuth.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

import NaverThirdPartyLogin

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
        if authType != .naver {
            nextAuth?.login(authType, completion: completion)
            return
        }
        loginInstance?.requestThirdPartyLogin()
        self.completedLogin = completion
    }
    
    func logout() {
        if loginInstance?.accessToken == nil {
            nextAuth?.logout()
        } else {
            loginInstance?.requestDeleteToken()
        }
    }
    
    // TODO: 함수 쪼개기 + fetchName과 합치기
    func fetchEmail(completion: ((Result<String, LoginError>) -> Void)?) {
        guard let loginInstance else {
            completion?(.failure(.unknown))
            return
        }
        if loginInstance.accessToken == nil {
            nextAuth?.fetchEmail(completion: completion)
            return
        }
        guard loginInstance.isValidAccessTokenExpireTimeNow(),
              let tokenType = loginInstance.tokenType,
              let accessToken = loginInstance.accessToken,
            let url = URL(string: "https://openapi.naver.com/v1/nid/me") else {
            loginInstance.requestAccessTokenWithRefreshToken()
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
    
    func fetchName(completion: ((Result<String, LoginError>) -> Void)?) {
        guard let loginInstance else {
            completion?(.failure(.unknown))
            return
        }
        if loginInstance.accessToken == nil {
            nextAuth?.fetchName(completion: completion)
            return
        }
        guard loginInstance.isValidAccessTokenExpireTimeNow(),
              let tokenType = loginInstance.tokenType,
              let accessToken = loginInstance.accessToken,
            let url = URL(string: "https://openapi.naver.com/v1/nid/me") else {
            loginInstance.requestAccessTokenWithRefreshToken()
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
                          let name = response["name"] as? String else {
                        completion?(.failure(LoginError.unknown))
                        return
                    }
                    completion?(.success(name))
                } catch let error as NSError {
                    print(error)
                    completion?(.failure(.error(error)))
                }
                return
            }
            completion?(.failure(.unknown))
        }.resume()
    }
    
    private func fetchReponseUserInfo(authorization: String, url: URL) {
        
    }
    
    func fetchLoginState() -> Bool {
        if loginInstance?.accessToken == nil {
            guard let nextAuth else { return false }
            return nextAuth.fetchLoginState()
        }
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else {
            loginInstance?.requestAccessTokenWithRefreshToken()
            return true
        }
        return isValidAccessToken
    }
    
}

extension NaverAuth: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("success naver")
        completedLogin?(.success(true))
        completedLogin = nil
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("refresh token")
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("delete token")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print(error.localizedDescription)
        completedLogin?(.failure(.error(error)))
    }
    
}
