//
//  LoginError.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/25.
//

import Foundation

enum LoginError: Error {
    case error(Error)
    case unknown
    
    var message: String {
        switch self {
        case .error(let e):
            return e.localizedDescription
        case .unknown:
            return "알수없는 에러"
        }
    }
}
