//
//  BottomSheetViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/01.
//

import UIKit

class BottomSheetViewController: UIViewController {
    
    private var isDismissDragging: Bool = false
    
    // view의 처음 높이(팝업뷰 드래그시 이 위치보다 더 높아지지 않음)
    private var originY: CGFloat = 0
    
    // 팝업뷰를 닫기 위해 터치시, 터치가 적용되는 영역 높이 설정 (터치 영역보다 더 아래쪽을 클릭시 팝업뷰가 내려가지 않음)
    var dismissTouchHeightArea: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        originY = view.frame.origin.y
    }

}

// MARK: TouchEvent
extension BottomSheetViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let window = UIApplication.shared.windows.first,
              let location = touches.first?.location(in: window),
              location.y <= originY + dismissTouchHeightArea else { return }
        isDismissDragging = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let window = UIApplication.shared.windows.first
        guard let location = touches.first?.location(in: window),
            isDismissDragging else { return }
        guard location.y > originY else {
            view.frame.origin.y = originY
            return
        }
        view.frame.origin.y = location.y
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard isDismissDragging,
              let window = UIApplication.shared.windows.first,
              let touch = touches.first else { return }
        
        let previousLocation = touch.previousLocation(in: window)
        let location = touch.location(in: window)
        
        let dismissY = originY + 200.0
        let isFasterDown = (location.y - previousLocation.y) >= 7
        
        if location.y >= dismissY { dismiss(animated: true) }
        else if isFasterDown { dismiss(animated: true) }
        else {
            isDismissDragging = false
            UIView.animate(withDuration: 0.1) {
                self.view.frame.origin.y = self.originY
            }
        }
    }
}

