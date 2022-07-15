//
//  Util.swift
//  VNPT ID
//
//  Created by Nguyễn Hữu Dũng on 3/26/20.
//  Copyright © 2020 Nguyễn Hữu Dũng. All rights reserved.
//

import UIKit

class BiometricsUtil: NSObject {
    static let shared = BiometricsUtil()
    func isIPhoneX() -> Bool {
        var isiPhoneX: Bool = false
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            if #available(iOS 11.0, *) {
                if UIApplication.shared.keyWindow?.safeAreaInsets.bottom == 34.0 {
                    isiPhoneX = true
                }
            }
        }
        return isiPhoneX
    }
    
}
