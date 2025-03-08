//
//  HMSJoinButton.swift
//  HMSSDK
//
//  Created by Pawan Dixit on 16/06/2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK
import HMSRoomModels

struct HMSJoinNameLabel: View {
    
    @EnvironmentObject var roomModel: HMSRoomModel
    @State private var namePreset = false
    
    var body: some View {
        HMSJoinNameView(name: $roomModel.userName)
            .onAppear {
                namePreset = !roomModel.userName.isEmpty
        }
    }
}

struct HMSJoinNamebox_Previews: PreviewProvider {
    static var previews: some View {
#if Preview
        HMSJoinNameLabel()
            .environmentObject(HMSUITheme())
            .environmentObject(HMSRoomModel.dummyRoom(1))
#endif
    }
}

