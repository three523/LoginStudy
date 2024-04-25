//
//  ViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/22.
//

import UIKit

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    private let userRepository: UserRepository = UserRepository(type: .sqlite)
    private let testEmail: String = "email@test.com"
    
    private var isLogin: Bool = UserDefaults.standard.bool(forKey: "isLogin") {
        didSet {
            updateFormButton(isLogin: isLogin)
            saveUserLoginState(isLogin: isLogin)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFormButton(isLogin: isLogin)
    }
    
    @IBAction func login(_ sender: Any) {
        print("카카오로 시작하기")
        if userRepository.isSignup(email: testEmail) == false {
            userRepository.addEmail(testEmail)
        }
        isLogin = true
    }
    @IBAction func logout(_ sender: Any) {
        print("로그아웃")
        isLogin = false
    }
    @IBAction func deleteAccount(_ sender: Any) {
        userRepository.deleteEmail("email@test.com")
        isLogin = false
    }
    
    private func updateFormButton(isLogin: Bool) {
        loginButton.isHidden = isLogin
        logoutButton.isHidden = !isLogin
        deleteAccountButton.isHidden = !isLogin
    }
    
    private func saveUserLoginState(isLogin: Bool) {
        UserDefaults.standard.set(isLogin, forKey: "isLogin")
    }
}
