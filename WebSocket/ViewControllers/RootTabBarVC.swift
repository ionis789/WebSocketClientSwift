//
//  RootTabBarVC.swift
//  WebSocket
//
//  Created by Ion Socol on 2/4/25.
//

import UIKit
class RootTabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Set Tab Bar Appearence
        UITabBar.appearance().tintColor = .myRed
        UITabBar.appearance().unselectedItemTintColor = .gray
        

        //MARK: Chats Tab Bar
        let chatsVC = ChatsVC()
        let chatsNavVC = UINavigationController(rootViewController: chatsVC)
        chatsNavVC.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 0)

        //MARK: Recents Calls Tab Bar
        let recentCallsVC = RecentCallsVC()
        let recentCallsNavVC = UINavigationController(rootViewController: recentCallsVC)
        recentCallsNavVC.tabBarItem = UITabBarItem(title: "Recent Calls", image: UIImage(systemName: "phone"), tag: 1)

        //MARK: Settings Tab Bar
        let settingsVC = SettingsVC()
        let settingsNavVC = UINavigationController(rootViewController: settingsVC)
        settingsNavVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)

        // Assign view controllers to the tab bar
        self.viewControllers = [chatsNavVC, recentCallsNavVC, settingsNavVC]
    }
}
