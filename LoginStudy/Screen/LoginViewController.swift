//
//  ViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/22.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let userRepository: UserRepository = UserRepository(type: .sqlite)
    
    private var isLoding: Bool = true {
        didSet {
            isLoding ? setLodingView() : setLodedView()
        }
    }
    private var isLogin: Bool = UserDefaults.standard.bool(forKey: "isLogin") {
        didSet {
            updateFormButton(isLogin: isLogin)
            saveUserLoginState(isLogin: isLogin)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLodingView()
        checkKakaoToken()
    }
    
    @IBAction func login(_ sender: Any) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            loginWithKakaoTalk()
        } else {
            loginWithKakaoWeb()
        }
    }
    @IBAction func logout(_ sender: Any) {
        logoutWithKakao()
    }
    @IBAction func deleteAccount(_ sender: Any) {
        getUserInfo(completion: deleteEmail)
        logoutWithKakao()
    }
    
    private func updateFormButton(isLogin: Bool) {
        loginButton.isHidden = isLogin
        logoutButton.isHidden = !isLogin
        deleteAccountButton.isHidden = !isLogin
    }
    
    private func saveUserLoginState(isLogin: Bool) {
        UserDefaults.standard.set(isLogin, forKey: "isLogin")
    }
    
    private func checkKakaoToken() {
        if (AuthApi.hasToken() && isLogin) {
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        self.isLogin = false
                    }
                    else {
                        print(error)
                    }
                }
                else {
                    self.isLogin = true
                }
                self.isLoding = false
            }
        }
        else {
            isLogin = false
            isLoding = false
        }
        
    }
    
    private func loginWithKakaoWeb() {
        UserApi.shared.loginWithKakaoAccount() { (_, error) in
            if let error = error {
                print(error)
            }
            else {
                UserApi.shared.me() {(user, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("me() success.")
                                                
                        self.getUserInfo(completion: self.saveEmail)
                    }
                }
            }
        }
    }
    
    private func loginWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoTalk() success.")
                self.isLogin = true
                self.getUserInfo(completion: self.saveEmail)
            }
        }
    }
    
    private func logoutWithKakao() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
            self.isLogin = false
        }
    }
    
    private func deleteEmail(result: Result<String,Error>) {
        switch result {
        case .success(let email):
            self.userRepository.addEmail(email)
        case .failure(let error):
            presentErrorAlert(error: error)
        }
    }
    
    private func saveEmail(result: Result<String,Error>) {
        switch result {
        case .success(let email):
            self.userRepository.addEmail(email)
        case .failure(let error):
            presentErrorAlert(error: error)
        }
    }
    
    private func presentErrorAlert(error: Error) {
        var alertVC: UIAlertController
        if self.isNotConnectedInternetError(error: error) {
            alertVC = UIAlertController(title: "인터넷 연결을 확인해주세요", message: nil, preferredStyle: .alert)
            return
        } else {
            alertVC = UIAlertController(title: "다시 시도해주세요", message: nil, preferredStyle: .alert)
        }
        self.present(alertVC, animated: true)
    }
    
    private func setLodingView() {
        indicator.isHidden = false
        loginStackView.isHidden = true
        indicator.startAnimating()
    }
    
    private func setLodedView() {
        indicator.isHidden = true
        loginStackView.isHidden = false
        indicator.stopAnimating()
    }
    
    private func getUserInfo(completion: @escaping (Result<String,Error>) -> Void) {
        UserApi.shared.me { user, error in
            if let error {
                completion(.failure(error))
                return
            }
            print(user?.kakaoAccount?.email,
                  user?.kakaoAccount?.profile?.nickname)
            if let email = user?.kakaoAccount?.email {
                completion(.success(email))
            } else {
                self.requestKakaoAgreement { result in
                    switch result {
                    case .success(let email):
                        completion(.success(email))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        
    }
    
    private func requestKakaoAgreement(completion: @escaping (Result<String,LoginError>) -> Void) {
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
                                completion(.failure(.error(error)))
                            } else {
                                UserApi.shared.me() { (user, error) in
                                    if let error = error {
                                        completion(.failure(.error(error)))
                                        return
                                    } else {
                                        print("me() success.")
                                        
                                        if let email = user?.kakaoAccount?.email  {
                                            completion(.success(email))
                                            return
                                        }
                                        completion(.failure(LoginError.unknown))
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
    
    private func isNotConnectedInternetError(error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorTimedOut
    }
}
