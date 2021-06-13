//
//  ChatRow.swift
//  TypoChats
//
//  Created by Vitaliy Yefimchuk on 24.05.2021.
//

import SwiftUI

struct ChatRow: View {
    @EnvironmentObject var model: AppStateModel
    
    let type: MessageType
    let text: String
    
    var isSender: Bool {
        return type == .sent
    }
    
    init(text: String, type: MessageType) {
        self.text = text
        self.type = type
    }
    
    var body: some View {
        HStack {
            if isSender { Spacer() }
            
            if !isSender {
                VStack {
                    Spacer()
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }
            }
            HStack {
                Text(text)
                    .foregroundColor(isSender ? Color.white : Color(.label))
                    .padding()
            }
            .background(isSender ? Color.blue : Color(.systemGray4))
            .padding(isSender ? .leading : .trailing, isSender ? UIScreen.main.bounds.width/3 : UIScreen.main.bounds.width/5)
            
            if !isSender { Spacer() }
        }
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatRow(text: "Hello1", type: .sent)
                .preferredColorScheme(.dark)
            ChatRow(text: "Hello2", type: .received)
                .preferredColorScheme(.dark)
            
        }
    }
}
