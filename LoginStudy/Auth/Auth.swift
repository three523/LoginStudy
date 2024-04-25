//
//  Auth.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

protocol Auth {
    var nextAuth: Auth? { get set }
    func login(_ authType: AuthType, completion: @escaping (Result<Bool,LoginError>) -> Void)
    func logout()
    func fetchEmail(completion: ((Result<String,LoginError>) -> Void)?)
    func fetchLoginState() -> Bool
}
