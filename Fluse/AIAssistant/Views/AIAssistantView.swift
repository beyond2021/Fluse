//
//  AIAssistantView.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/13/24.
//

import ChatGPTUI
import SwiftUI

let apiKey = ""//"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"
let _senderImage = ""
let _botImage = ""

enum ChatType: String, Identifiable, CaseIterable {
    case text = "Text"
    case voice = "Voice"
    var id: Self {
        self
    }
}

struct AIAssistantView: View {
    @State var textChatVM = AIAssistantTextChatViewModel(apiKey: apiKey)
    @State var voiceChatVM = AIAssistantVoiceChatViewModel(apiKey: apiKey)
    @State  var chatType = ChatType.text
    var body: some View {
        VStack(spacing:0) {
            Picker(selection: $chatType, label: Text("Chat Type").font(.system(size: 12, weight: .bold))) {
                ForEach(ChatType.allCases) { type in
                    Text(type.rawValue).tag(type)
                    
                }
                
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            #if !os(iOS)
            .padding(.vertical) // Only for iOS
            #endif
            Divider()
            ZStack {
                switch chatType {
                case .text:
                    TextChatView(customContentVM: textChatVM)
                case .voice:
                    VoiceChatView(customContentVM: voiceChatVM)
                }
                
            }
            .frame(maxWidth: 1024, alignment: .center)
        }
        // Macro
        #if !os(macOS)
        .navigationBarTitle("Fluse Assistant", displayMode: .inline)
        
        #endif
    }
}

#Preview {
    AIAssistantView()
}
