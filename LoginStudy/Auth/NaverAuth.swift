//
//  NaverAuth.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

import Foundation

final class NaverAuth: Auth {
    var nextAuth: Auth?
    
    init(auth: Auth?) {
        self.nextAuth = auth
    }
    
    func login(_ authType: AuthType, completion: ((Result<Bool, LoginError>) -> Void)?) {
        <#code#>
    }
    
    func logout() {
        <#code#>
    }
    
    func fetchEmail(completion: ((Result<String, LoginError>) -> Void)?) {
        <#code#>
    }
    
    func fetchLoginState() -> Bool {
        <#code#>
    }
    
    
}
