//
//  HMSPrebuiltOptions.swift
//  HMSSDK
//
//  Created by Pawan Dixit on 27/06/2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import Foundation
import Combine
import HMSSDK
import HMSRoomModels

public class HMSPrebuiltOptions: ObservableObject {
    
    var theme: HMSUITheme?
    var roomOptions: HMSRoomOptions?
    var userImage: String?
    var userVerified: Bool?
    
    public init(theme: HMSUITheme? = nil, roomOptions: HMSRoomOptions? = nil, userImage: String? = nil, userVerified: Bool? = nil) {
        self.theme = theme
        self.roomOptions = roomOptions
        self.userImage = userImage
        self.userVerified = userVerified
    }
}
