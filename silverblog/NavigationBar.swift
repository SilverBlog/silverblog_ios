//
//  NavigationBar.swift
//  silverblog
//
//  Created by 黄江华 on 2018/3/30.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11.0, *) {
            for subview in self.subviews {
                let stringFromClass = NSStringFromClass(subview.classForCoder)
                if stringFromClass.contains("BarBackground") {
                    subview.frame = self.bounds
                } else if stringFromClass.contains("BarContentView") {
                    subview.frame.origin.y = UIApplication.shared.statusBarFrame.height - 5
                    subview.frame.size.height = self.bounds.height - UIApplication.shared.statusBarFrame.height
                }
            }
        }
    }

}
