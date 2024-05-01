//
//  KakaoAuth.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

import KakaoSDKUser
import KakaoSDKAuth

final class KakaoAuth: Auth {
    
    var nextAuth: Auth?
    
    init(auth: Auth?) {
        self.nextAuth = auth
    }
    
    func login(_ authType: AuthType, completion: @escaping (Result<Bool,LoginError>) -> Void) {
        if authType != .kakao {
            if let nextAuth {
                nextAuth.login(authType, completion: completion)
            } else {
                completion(.failure(.unknown))
            }
            return
        }
        loginWithKakao(completion: completion)
    }
    
    func logout() {
        if AuthApi.hasToken() {
            logoutWithKakao()
        } else {
            nextAuth?.logout()
        }
    }
    
    func fetchEmail(completion: ((Result<String,LoginError>) -> Void)?) {
        if AuthApi.hasToken() {
            getUserInfo(completion: completion)
        } else {
            nextAuth?.fetchEmail(completion: completion)
        }
    }
    
    func fetchName(completion: ((Result<String, LoginError>) -> Void)?) {
        if AuthApi.hasToken() {
            getUserName(completion: completion)
        } else {
            nextAuth?.fetchName(completion: completion)
        }
    }
    
    func fetchLoginState() -> Bool {
        if AuthApi.hasToken() {
            return true
        } else {
            guard let nextAuth else { return false }
            return nextAuth.fetchLoginState()
        }
    }
    
    private func logoutWithKakao() {
        UserApi.shared.logout { error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func loginWithKakao(completion: ((Result<Bool,LoginError>) -> Void)?) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            loginWithKakaoTalk(completion: completion)
        } else {
            loginWithKakaoWeb(completion: completion)
        }
    }
    
    private func loginWithKakaoWeb(completion: ((Result<Bool,LoginError>) -> Void)?) {
        UserApi.shared.loginWithKakaoAccount() { (_, error) in
            if let error = error {
                print(error)
                completion?(.failure(.error(error)))
            }
            else {
                print("loginWithKakaoWeb() success.")
                completion?(.success(true))
            }
        }
    }
    
    private func loginWithKakaoTalk(completion: ((Result<Bool,LoginError>) -> Void)?) {
        UserApi.shared.loginWithKakaoTalk {(_, error) in
            if let error = error {
                print(error)
                completion?(.failure(.error(error)))
            }
            else {
                print("loginWithKakaoTalk() success.")
                completion?(.success(true))
            }
        }
    }
    
    // TODO: getUserInfo, getUserName 비슷한 메서드 합치기
    private func getUserInfo(completion: ((Result<String,LoginError>) -> Void)?) {
        UserApi.shared.me { user, error in
            if let error {
                completion?(.failure(.error(error)))
                return
            }
            if let email = user?.kakaoAccount?.email {
                completion?(.success(email))
            } else {
                self.requestKakaoAgreement(completion: completion)
            }
        }
    }
    
    private func getUserName(completion: ((Result<String,LoginError>) -> Void)?) {
        UserApi.shared.me { user, error in
            if let error {
                completion?(.failure(.error(error)))
                return
            }
            if let name = user?.kakaoAccount?.name {
                completion?(.success(name))
            } else if let nickName = user?.kakaoAccount?.profile?.nickname {
                completion?(.success(nickName))
            } else {
                self.requestKakaoAgreement(completion: completion)
            }
        }
    }
    
    private func requestKakaoAgreement(completion: ((Result<String,LoginError>) -> Void)?) {
        UserApi.shared.me() { (user, error) in
            if let error = error {
                print(error)
            }
            else {
                if let user = user {
                    var scopes = [String]()
                    if (user.kakaoAccount?.profileNeedsAgreement == true) { scopes.append("profile") }
                    if (user.kakaoAccount?.emailNeedsAgreement == true) { scopes.append("account_email") }
                    
                    if scopes.contains(where: { $0 == "account_email" }) == false {
                        print("사용자에게 추가 동의를 받아야 합니다.")

                        UserApi.shared.loginWithKakaoAccount(scopes: scopes) { (_, error) in
                            if let error = error {
                                print(error)
                                completion?(.failure(.error(error)))
                            } else {
                                UserApi.shared.me() { (user, error) in
                                    if let error = error {
                                        completion?(.failure(.error(error)))
                                        return
                                    } else {
                                        print("me() success.")
                                        
                                        if let email = user?.kakaoAccount?.email  {
                                            completion?(.success(email))
                                            return
                                        }
                                        completion?(.failure(LoginError.unknown))
                                    }
                                }
                            }
                        }
                    } else {
                        print("사용자의 추가 동의가 필요하지 않습니다.")
                    }
                }
            }
        }
    }
}
