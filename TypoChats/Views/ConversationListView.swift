//
//  ContentView.swift
//  TypoChats
//
//  Created by Vitaliy Yefimchuk on 24.05.2021.
//

import SwiftUI

struct ConversationListView: View {
    @EnvironmentObject var model: AppStateModel
    @State var otherUserName: String = ""
    @State var showChat: Bool = false
    @State var showSearch: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ForEach(model.conversations, id: \.self) { name in
                    NavigationLink(
                        destination: ChatView(otherUserName: name),
                        label: {
                            HStack {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 65, height: 65)
                                    .clipShape(Circle())
                                Text(name)
                                    .bold()
                                    .foregroundColor(Color(.label))
                                    .font(.system(size: 32))
                                Spacer()
                            }
                            .padding()
                        })
                }
                if !otherUserName.isEmpty {
                    NavigationLink("", destination: ChatView(otherUserName: otherUserName), isActive: $showChat)
                }
            }
            .navigationTitle("Conversations")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Sign Out") {
                        self.signOut()
                    }
                }
                
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    NavigationLink(
                        destination: SearchView { name in
                            self.showSearch = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                self.otherUserName = name
                                self.showChat = true
                                
                            }
                        },
                        isActive: $showSearch,
                        label: {
                            Image(systemName: "plus.magnifyingglass")
                        })
                }
            }
            .fullScreenCover(isPresented: $model.showingSignIn, content: {
                SignInView()
            })
            .onAppear {
                guard model.auth.currentUser != nil else {
                    return
                }
                model.getConversations()
            }
        }
    }
    func signOut() {
        model.signOut()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationListView()
    }
}
