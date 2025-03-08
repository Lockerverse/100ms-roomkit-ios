//
//  HMSChatMessageView.swift
//  HMSSDK
//
//  Created by Pawan Dixit on 16/08/2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK
import Popovers
import HMSRoomModels

struct UserMetadata: Codable {
    let image: String
}

struct HMSChatMessageView: View {
    
    @Environment(\.chatScreenAppearance) var chatScreenAppearance
    
    @EnvironmentObject var roomModel: HMSRoomModel
    @EnvironmentObject var theme: HMSUITheme
    
    let messageModel: HMSMessage
    var isPartOfTransparentChat: Bool
    @Binding var recipient: HMSRecipient?
    
    @State var isPopoverPresented = false
    
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        if isPartOfTransparentChat {
            messageView
                .padding(.vertical, 8)
                .padding(.horizontal, 2)
                //.background(.backgroundDim, cornerRadius: 8, opacity: 0.64)
        }
        else {
            if messageModel.recipient.type != .broadcast {
                messageView
                    .background(.surfaceDefault, cornerRadius: 8)
            }
            else {
                messageView
            }
        }
    }
    
    var senderMetadata: UserMetadata? {
        guard let jsonString = messageModel.sender?.metadata,
              let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        return try? JSONDecoder().decode(UserMetadata.self, from: jsonData)
    }
    
    
    var messageView: some View {
        HStack(alignment: .top, spacing: 8) {
            HMSAsyncImageAvatar(url: URL(string: senderMetadata?.image ?? ""))
                .padding(.top, 1)
          
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    Text(messageModel.sender?.name ?? "")
                        .font(.subtitle2Semibold14)
                        .foregroundColor(.secondary)
//                        .foreground(.onSurfaceHigh)
//                        .foreground(isPartOfTransparentChat ? .white : .onSurfaceHigh)
//                        .shadow(color: isPartOfTransparentChat ? .black : .clear, radius: 3, y: 1)
                    
                    if !chatScreenAppearance.isPlain.wrappedValue {
                        Text(formatter.string(from: messageModel.time))
                            .font(.captionRegular12).foreground(.onSurfaceMedium)
//                            .shadow(color: isPartOfTransparentChat ? .black : .clear, radius: 3, y: 1)
                    }
                    
                    if messageModel.recipient.type == .peer, let peerParticipant = messageModel.recipient.peerRecipient {
                        Text("to \(peerParticipant.isLocal ? "You" : peerParticipant.name) (DM)")
                            .lineLimit(1)
                            .font(.captionRegular12)
                            .foreground(.onSurfaceMedium)
                    }
                    else if messageModel.recipient.type == .roles, let firstRoleRecipient = messageModel.recipient.rolesRecipient?.first {
                        
                        Text("to \(firstRoleRecipient.name) (Group)")
                            .foreground(.onSurfaceMedium)
                            .font(.captionRegular12)
                            .lineLimit(1)
                    }
                    
                    Spacer()
//                    HStack {
//
//                        Spacer()
//                        
//                        if !chatScreenAppearance.isPlain.wrappedValue {
//                            Button() {
//                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
//                                    isPopoverPresented.toggle()
//                                }
//                                
//                            } label: {
//                                Image(assetName: "vertical-ellipsis")
//                                    .resizable()
//                                    .frame(width: 3.33, height: 15)
//                                    .padding(.horizontal, 9)
//                            }
//                            .foreground(.onSurfaceLow)
//                            .sheet(isPresented: $isPopoverPresented, content: {
//                                HMSSheet {
//                                    if verticalSizeClass == .regular {
//                                        HMSMessageOptionsView(messageModel: messageModel, recipient: $recipient)
//                                    }
//                                    else {
//                                        ScrollView {
//                                            HMSMessageOptionsView(messageModel: messageModel, recipient: $recipient)
//                                        }
//                                    }
//                                }
//                                .edgesIgnoringSafeArea(.all)
//                                .environmentObject(theme)
//                            })
//                        }
//                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                .frame(maxWidth: .infinity)
                Text(LocalizedStringKey(messageModel.message))
                    .font(.body2Regular14)
                    .foreground(.onSurfaceHigh)
//                    .foreground(isPartOfTransparentChat ? .white : .onSurfaceHigh)
//                    .shadow(color: isPartOfTransparentChat ? .black : .clear ,radius: 3, y: 1)
                
            }
            .frame(maxWidth: .infinity)
            
        }
//        .padding(12)
    }
}

struct HMSChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
#if Preview
            HMSChatMessageView(messageModel: .init(message: "hello"), isPartOfTransparentChat: false, recipient: .constant(.everyone))
                .environmentObject(HMSUITheme())
                .environmentObject(HMSRoomModel.dummyRoom(3))
            
            HMSChatMessageView(messageModel: .init(message: "hello"), isPartOfTransparentChat: true, recipient: .constant(.everyone))
                .environmentObject(HMSUITheme())
                .environmentObject(HMSRoomModel.dummyRoom(3))
#endif
        }
    }
}

struct HMSAsyncImageAvatar: View {
    let itemSize: CGFloat = 40
    let url: URL?
    
    @State private var isLoaded = false
    @State private var cachedImage: UIImage?
    
    // Static image cache
    private static let imageCache = NSCache<NSURL, UIImage>()
    
    var body: some View {
        Group {
            if let cachedImage = cachedImage {
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: itemSize, height: itemSize)
                    .clipShape(Circle())
            } else if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.black.opacity(0.3)
                            .frame(width: itemSize, height: itemSize)
                            .clipShape(Circle())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: itemSize, height: itemSize)
                            .clipShape(Circle())
                    case .failure(_):
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
                .frame(width: itemSize, height: itemSize)
                .clipShape(Circle())
                .redacted(reason: isLoaded ? [] : .placeholder)
            } else {
                placeholderView
            }
        }
        .onAppear {
            loadCachedImage()
        }
    }
    
    var placeholderView: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all).opacity(0.9)
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 18, height: 18)
                .foregroundColor(.gray)
        }
        .frame(width: itemSize, height: itemSize)
        .clipShape(Circle())
    }
    
    private func loadCachedImage() {
        guard let url = url as NSURL? else { return }
        
        // Check cache first
        if let cachedImage = Self.imageCache.object(forKey: url) {
            self.cachedImage = cachedImage
            self.isLoaded = true
            return
        }
        
        // Otherwise load from network and cache
        URLSession.shared.dataTask(with: url as URL) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            // Store in cache
            Self.imageCache.setObject(image, forKey: url)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.cachedImage = image
                self.isLoaded = true
            }
        }.resume()
    }
}
