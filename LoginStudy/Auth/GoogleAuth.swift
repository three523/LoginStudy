//
//  GoogleAuth.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

import UIKit
import GoogleSignIn

final class GoogleAuth: Auth {
    weak var presenting: UIViewController?
    var nextAuth: Auth?
    
    init(nextAuth: Auth?, presenting: UIViewController?) {
        self.presenting = presenting
        self.nextAuth = nextAuth
    }
    
    func login(_ authType: AuthType, completion: @escaping (Result<Bool, LoginError>) -> Void) {
        if authType != .google {
            nextAuth?.login(authType, completion: completion)
            return
        }
        guard let presenting else {
            print("google auth presenting VC nil")
            completion(.failure(.unknown))
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { signInResult, error in
            if let error {
                print(error.localizedDescription)
                completion(.failure(.error(error)))
                return
            }
            completion(.success(true))
        }
    }
    

    func logout() {
        if GIDSignIn.sharedInstance.currentUser != nil {
            GIDSignIn.sharedInstance.signOut()
            print("구글 로그아웃")
        } else {
            if let nextAuth {
                nextAuth.logout()
            } else {
                print("로그인이 되어있지 않습니다.")
            }
        }
    }
    
    func fetchEmail(completion: ((Result<String, LoginError>) -> Void)?) {
        guard let user = GIDSignIn.sharedInstance.currentUser,
                let email = user.profile?.email else {
            print("사용자 정보를 가져올 수 없습니다.")
            nextAuth?.fetchEmail(completion: completion)
            return
        }
        completion?(.success(email))
    }
    
    func fetchName(completion: ((Result<String, LoginError>) -> Void)?) {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("사용자 정보를 가져올 수 없습니다.")
            nextAuth?.fetchName(completion: completion)
            return
        }
        guard let name = user.profile?.name else {
            //TODO: 에러처리하기
            print("구글 프로필정보를 가져오지 못함")
            completion?(.failure(.unknown))
            return
        }
        completion?(.success(name))
    }
    
    func fetchLoginState() -> Bool {
        if GIDSignIn.sharedInstance.currentUser != nil {
            return true
        }
        if let nextAuth {
            return nextAuth.fetchLoginState()
        }
        return false
    }
    
}
