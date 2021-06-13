//
//  SignInView.swift
//  TypoChats
//
//  Created by Vitaliy Yefimchuk on 24.05.2021.
//

import SwiftUI

struct SignInView: View {
    @State var username: String = ""
    @State var password: String = ""
    
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
        NavigationView {
            VStack {
                //Heading
                Image(systemName: "bolt.horizontal")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color.blue)
                Text("TypoChats")
                    .bold()
                    .font(.system(size: 44))
                
                VStack {
                    TextField("Username...", text: $username)
                        .modifier(CustonField())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("Password...", text: $password)
                        .modifier(CustonField())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        self.signIn()
                    }, label: {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(width: 220, height: 50)
                            .background(Color.blue)
                            .cornerRadius(6)
                    })
                    .padding()
                }
                .padding()
                
                Spacer()
                
                //Sign Up
                HStack {
                    Text("New to TypoChats?")
                    NavigationLink("Create Account", destination: SignUpView())
                }
            }
        }
    }
    
    func signIn() {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
        model.signIn(username: username, password: password)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
