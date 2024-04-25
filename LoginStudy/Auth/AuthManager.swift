//
//  AuthManager.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

import Foundation

final class AuthManager {
    private let auth: Auth
    private let userRepository: UserRepository = UserRepository()
    private var isLocalLoginState: Bool = UserDefaults.standard.bool(forKey: "isLogin") {
        didSet {
            saveUserLoginState(isLogin: isLocalLoginState)
            updateLoginView?(fetchLoginState())
        }
    }
    var updateLoginView: ((Bool) -> Void)?
    
    init() {
        self.auth = KakaoAuth(auth: nil)
    }
    
    func login(_ authType: AuthType, completion: ((Result<Bool,LoginError>) -> Void)?) {
        auth.login(authType) { result in
            switch result {
            case .success(_):
                self.fetchEmail { result in
                    switch result {
                    case .success(let email):
                        self.saveEmail(email: email)
                        self.isLocalLoginState = true
                        completion?(.success(true))
                    case .failure(_):
                        print("이메일을 가져오지 못했습니다.")
                    }
                }
            case .failure(let error):
                self.isLocalLoginState = false
                completion?(.failure(.error(error)))
            }
        }
    }
    
    func logout() {
        auth.logout()
    }
    
    func fetchEmail(completion: ((Result<String, LoginError>) -> Void)?) {
        auth.fetchEmail(completion: completion)
    }
    
    func fetchLoginState() -> Bool {
        return auth.fetchLoginState() && isLocalLoginState
    }
    
    func deleteAccount(completion: ((Bool) -> Void)?) {
        fetchEmail { result in
            switch result {
            case .success(let email):
                self.userRepository.deleteEmail(email)
                completion?(true)
            case .failure(_):
                completion?(false)
            }
        }
    }
    
    private func saveEmail(email: String) {
        userRepository.addEmail(email)
    }
    
    private func saveUserLoginState(isLogin: Bool) {
        UserDefaults.standard.set(isLogin, forKey: "isLogin")
    }
}
