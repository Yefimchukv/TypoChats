//
//  ChatView.swift
//  TypoChats
//
//  Created by Vitaliy Yefimchuk on 24.05.2021.
//

import SwiftUI

struct CustonField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(7)
    }
}

struct ChatView: View {
    @State var message: String = ""
    @EnvironmentObject var model: AppStateModel
    let otherUserName: String
    
    init(otherUserName: String) {
        self.otherUserName = otherUserName
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                ForEach(model.messages, id: \.self) { message in
                    ChatRow(text: message.text, type: message.type)
                        .padding(3)
                }
            }
            
            //Field, send button
            HStack {
                TextField("Message...", text: $message)
                    .modifier(CustonField())
                SendButton(text: $message)
            }
            .padding()
        }
        .navigationBarTitle(otherUserName, displayMode: .inline)
        .onAppear {
            model.otherUsername = otherUserName
            model.observeChat()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(otherUserName: "Yukinai")
    }
}
