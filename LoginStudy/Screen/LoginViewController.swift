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
    
    private let authManager: AuthManager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFrom(isLogin: authManager.fetchLoginState())
    }
    
    @IBAction func login(_ sender: Any) {
        authManager.login(.kakao) { result in
            switch result {
            case .success(_):
                self.updateFrom(isLogin: true)
            case .failure(let error):
                print(error.message)
                self.updateFrom(isLogin: false)
            }
        }
    }
    @IBAction func logout(_ sender: Any) {
        authManager.logout()
        updateFrom(isLogin: false)
    }
    @IBAction func deleteAccount(_ sender: Any) {
        authManager.deleteAccount { success in
            if success {
                self.updateFrom(isLogin: false)
            } else {
                let alertVC = UIAlertController(title: "계정 삭제에 실패하였습니다.", message: nil, preferredStyle: .alert)
                self.present(alertVC, animated: true)
            }
        }
    }
    
    private func updateFrom(isLogin: Bool) {
        loginButton.isHidden = isLogin
        logoutButton.isHidden = !isLogin
        deleteAccountButton.isHidden = !isLogin
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
