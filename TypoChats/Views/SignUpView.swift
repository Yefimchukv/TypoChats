//
//  SignUpView.swift
//  TypoChats
//
//  Created by Vitaliy Yefimchuk on 24.05.2021.
//

import SwiftUI

struct SignUpView: View {
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
        VStack {
            //Heading
            Image(systemName: "bolt.horizontal")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(Color.green)
            
            VStack {
                TextField("E-mail", text: $email)
                    .modifier(CustonField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                TextField("Username...", text: $username)
                    .modifier(CustonField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                SecureField("Password...", text: $password)
                    .modifier(CustonField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Button(action: {
                    self.signUp()
                }, label: {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(Color.green)
                        .cornerRadius(6)
                })
                .padding()
            }
            .padding()
            
            Spacer()
            
            //Sign Up
            HStack {
                Text("Already have an account?")
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Return")
                        .foregroundColor(Color.green)
                })
            }
        }
        .navigationBarTitle("Create Account", displayMode: .inline)
    }
    
    func signUp() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
        model.signUp(email: email, username: username, password: password)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
