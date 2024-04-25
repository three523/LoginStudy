//
//  ViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/22.
//

import UIKit
import NaverThirdPartyLogin

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    private lazy var authManager: AuthManager = AuthManager(presenting: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonHidden(isLogin: authManager.fetchLoginState())
    }
    
    @IBAction func login(_ sender: Any) {
        authManager.login(.kakao, completion: updateForm)
    }
    @IBAction func loginWithNaver(_ sender: Any) {
        authManager.login(.naver, completion: updateForm)
    }
    @IBAction func loginWithGoogle(_ sender: Any) {
        authManager.login(.google, completion: updateForm)
    }
    @IBAction func logout(_ sender: Any) {
        authManager.logout()
        updateButtonHidden(isLogin: false)
    }
    @IBAction func deleteAccount(_ sender: Any) {
        authManager.deleteAccount { success in
            if success {
                self.updateButtonHidden(isLogin: false)
            } else {
                DispatchQueue.main.async {
                    let alertVC = UIAlertController(title: "계정 삭제에 실패하였습니다.", message: nil, preferredStyle: .alert)
                    self.present(alertVC, animated: true)
                }
            }
        }
    }
    
    private func updateForm(result: Result<Bool, LoginError>) {
        switch result {
        case .success(_):
            self.updateButtonHidden(isLogin: true)
        case .failure(let error):
            print(error.message)
            self.updateButtonHidden(isLogin: false)
        }
    }
    
    private func updateButtonHidden(isLogin: Bool) {
        DispatchQueue.main.async {
            self.loginButton.isHidden = isLogin
            self.naverLoginButton.isHidden = isLogin
            self.googleLoginButton.isHidden = isLogin
            self.logoutButton.isHidden = !isLogin
            self.deleteAccountButton.isHidden = !isLogin
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

    private func isNotConnectedInternetError(error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorTimedOut
    }
}
