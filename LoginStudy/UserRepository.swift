//
//  UserRepository.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/04/24.
//

import Foundation
import CoreData

enum CoreDataType {
    case inMemory
    case sqlite
}

final class UserRepository {
    
    private let type: CoreDataType
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        
        if self.type == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unable to load core data persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    init(type: CoreDataType = .inMemory) {
        self.type = type
    }
    
    private func fetchEntity(email: String) -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email as CVarArg)
        do {
            let email = try context.fetch(fetchRequest)
            return email.first
        } catch {
            print("fetch for update Person error: \(error)")
            return nil
        }
    }
    
    func addEmail(_ email: String) {
        if isSignup(email: email) {
            return
        }
        let user = User(context: context)
        user.email = email
        save()
        print("회원가입")
    }
    
    func isSignup(email: String) -> Bool {
        return fetchEntity(email: email) != nil
    }
    
    func deleteEmail(_ email: String) {
        guard let userEntity = fetchEntity(email: email) else { return }
        context.delete(userEntity)
        save()
        print("회원탈퇴")
    }
    
    private func save() {
        do {
            try context.save()
        } catch let e {
            print(e.localizedDescription)
        }
    }
}
