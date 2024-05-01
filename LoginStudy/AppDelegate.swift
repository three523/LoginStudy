//
//  AppDelegate.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/22.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin
import GoogleSignIn
import SwiftyBootpay

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: "a728f92d905deb3da2ecf5d1a9fccf16")
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return true }
        instance.isInAppOauthEnable = true
        instance.isInAppOauthEnable = true
        instance.isOnlyPortraitSupportedInIphone()
        instance.serviceUrlScheme = NAVER_APPURLSCHEME
        instance.consumerKey = NAVER_CLIENTID
        instance.consumerSecret = NAVER_CLIENTSECRET
        instance.appName = "LoginStudy"
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                  // Show the app's signed-out state.
            } else {
                  // Show the app's signed-in state.
            }
        }
        
        Bootpay.sharedInstance.appLaunch(application_id: BOOTPAY_KEY)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }
      return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Bootpay.sharedInstance.sessionActive(active: false)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Bootpay.sharedInstance.sessionActive(active: true)
    }

}

