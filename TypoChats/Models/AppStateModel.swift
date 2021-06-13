//
//  AppStateModel.swift
//  TypoChats
//
//  Created by Vitaliy Yefimchuk on 24.05.2021.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SwiftyRSA

class AppStateModel: ObservableObject {
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("currentEmail") var currentEmail: String = ""
    
    @AppStorage("preparedPublicKey") var preparedPublicKey: String = ""
    @AppStorage("preapredPrivateKey") var preapredPrivateKey: String = ""
    
    @Published var showingSignIn: Bool = true
    @Published var conversations: [String] = []
    @Published var messages: [Message] = []
    
    let database = Firestore.firestore()
    let auth = Auth.auth()
    
    var otherUsername = ""
    
    //    var ourChatKey = ""
    var otherChatKey = ""
    
    var conversationListener: ListenerRegistration?
    var chatListener: ListenerRegistration?
    
    init() {
        self.showingSignIn = Auth.auth().currentUser == nil
    }
}

// MARK: - Search
extension AppStateModel {
    func searchUsers(queryText: String, completion: @escaping ([String]) -> Void) {
        //Запит до серверу
        database.collection("users").getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }),
                  error == nil else {
                //Користувачів не знайдено
                completion([])
                return
            }
            //Фільтрування результатів
            let filtered = usernames.filter({
                $0.lowercased().hasPrefix(queryText.lowercased())
            })
            //Результат функції надає масив знайдених користувачів
            completion(filtered)
        }
    }
}

// MARK: - Conversations
extension AppStateModel {
    func getConversations() {
        //Listen for conversations
        
        conversationListener = database
            .collection("users")
            .document(currentUsername)
            .collection("chats").addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let usernames = snapshot?.documents.compactMap({ $0.documentID }),
                      error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.conversations = usernames
                }
            }
    }
}

// MARK: - Get chat / Send messages
extension AppStateModel {
    func observeChat() {
        createConversationIfNeeded()
        
        database.collection("users")
            .document(otherUsername)
            .getDocument { snapshot, error in
                self.otherChatKey = snapshot?.data()?["publicKey"] as? String ?? ""
            }
        
        chatListener = database
            .collection("users")
            .document(currentUsername)
            .collection("chats")
            .document(otherUsername)
            .collection("messages")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let objects = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }
                
                let messages = objects.compactMap({
                    return Message(text: self.decrypt(text: (($0["text"] as? String) ?? "")),
                                   type: $0["sender"] as? String == self.currentUsername ? .sent : .received,
                                   created: ISO8601DateFormatter().date(from: $0["created"] as? String ?? "") ?? Date()
                    )
                })
                .sorted(by: { first, second in
                    return first.created < second.created
                })
                
                print("Received for \(self.currentUsername) at: \(Int64((Date().timeIntervalSince1970 * 1000.0).rounded()))" )
                
                DispatchQueue.main.async {
                    self.messages = messages

                }
            }
    }
    
    func createConversationIfNeeded() {
        database.collection("users")
            .document(currentUsername)
            .collection("chats")
            .document(otherUsername)
            .setData(["created":"true"])
        
        database.collection("users")
            .document(otherUsername)
            .collection("chats")
            .document(currentUsername)
            .setData(["created":"true"])
    }
    
    func sendMessage(text: String) {
        
        let newMessageId = UUID().uuidString
        
        let ourText = encrypt(text: text, with: preparedPublicKey)
        let otherText = encrypt(text: text, with: otherChatKey)
        
        let ourData = [
            "text": ourText,
            "sender": currentUsername,
            "created": ISO8601DateFormatter().string(from: Date())
        ]
        
        let otherData = [
            "text": otherText,
            "sender": currentUsername,
            "created": ISO8601DateFormatter().string(from: Date())
        ]
        
        database.collection("users")
            .document(currentUsername)
            .collection("chats")
            .document(otherUsername)
            .collection("messages")
            .document(newMessageId)
            .setData(ourData)
        
        database.collection("users")
            .document(otherUsername)
            .collection("chats")
            .document(currentUsername)
            .collection("messages")
            .document(newMessageId)
            .setData(otherData)
        
        print("Sended at: \(Int64((Date().timeIntervalSince1970 * 1000.0).rounded()))" )
    }
}

// MARK: - Sign In & Sign Up
extension AppStateModel {
    func signIn(username: String, password: String) {
        //Перевірка на існування користувача
        database.collection("users").document(username).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let email = snapshot?.data()?["email"] as? String, error == nil else {
                return
            }
            //Авторизація
            self.auth.signIn(withEmail: email, password: password, completion: { result, error in
                guard error == nil, result != nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.currentEmail = email
                    self.currentUsername = username
                    self.showingSignIn = false
                }
            })
        }
    }
    
    func signUp(email: String, username: String, password: String) {
        // Створити новий акаунт
        auth.createUser(withEmail: email,
                        password: password) { [weak self] result,
                                                          error in
            guard let self = self else {
                print("no self")
                return }
            guard result != nil, error == nil else { return }
            
            self.createKeys()
            
            //Вставити логін та пошту користувача до БД
            let data = [
                "email": email,
                "username": username,
                "publicKey": self.preparedPublicKey
            ]
            
            self.database
                .collection("users")
                .document(username)
                .setData(data) { error in
                    guard error == nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.currentUsername = username
                        self.currentEmail = email
                        self.showingSignIn = false
                        print("Finished")
                    }
                }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.showingSignIn = true
        }
        catch {
            print(error)
        }
    }
}

// MARK: - Message cryptography
extension AppStateModel {
    func createKeys() {
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
            self.preparedPublicKey = try keyPair.publicKey.base64String()
            self.preapredPrivateKey = try keyPair.privateKey.base64String()
        }
        catch {
            print(error)
        }
    }
    
    func encrypt(text: String, with key: String) -> String {
        do {
            let publicKey = try PublicKey(base64Encoded: key)
            
            let clear = try ClearMessage(string: text, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            
            // Then you can use:
            let base64String = encrypted.base64String
            return base64String
        }
        catch {
            print(error)
            return ""
        }
    }
    
    func decrypt(text: String) -> String {
        do {
            let privateKey = try PrivateKey(base64Encoded: preapredPrivateKey)
            let encrypted = try EncryptedMessage(base64Encoded: text)
            let clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
            
            let string = try clear.string(encoding: .utf8)
            return string
        }
        catch {
            print(error)
            return ""
        }
    }
}
