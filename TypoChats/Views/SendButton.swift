//
//  SendButton.swift
//  TypoChats
//
//  Created by Vitaliy Yefimchuk on 24.05.2021.
//

import SwiftUI

struct SendButton: View {
    @Binding var text: String
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
        Button(action: {
            self.sendMessage()
        }, label: {
            Image(systemName: "paperplane")
                .font(.system(size: 33))
                .frame(width: 45, height: 45)
        })
    }
    func sendMessage() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        model.sendMessage(text: text)
        
        text = ""
    }
}

//struct SendButton_Previews: PreviewProvider {
//    static var previews: some View {
//       SendButton(text: "")
//    }
//}
