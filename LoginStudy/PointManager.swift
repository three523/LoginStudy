//
//  PointManager.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/02.
//

import Foundation

final class PointManager {
    private var userInfo: UserInfo
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
    }
    
    func addPoint(price: Int) {
        userInfo.point += calculatePoint(for: price)
    }
    
    func getTotalPoint() -> Int {
        return userInfo.point
    }
    
    func subtractPoint(usedPoint: Int) {
        userInfo.point -= usedPoint
    }
    
    private func calculatePoint(for price: Int) -> Int {
        return Int(round(Double(price) * 0.02))
    }
}
