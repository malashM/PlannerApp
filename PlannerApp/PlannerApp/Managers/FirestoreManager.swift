//
//  FirestoreManager.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 30.07.23.
//

import Foundation
import FirebaseFirestore

final class FirestoreManager<T: Model> {
    
    private let dataBase = Firestore.firestore()
    
    init() {}
    
    private var collection: CollectionReference { dataBase.collection(String(describing: T.self)) }
    
    func add(id: String? = nil, _ model: T, _ completion: @escaping (Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard var dictionary else { throw CustomError("Can't encode \(String(describing: data))") }
            let document: DocumentReference
            if let id {
                document = collection.document(id)
            } else {
                document = collection.document()
            }
            dictionary["objectId"] = document.documentID
            document.setData(dictionary, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func get(id: String, _ completion: @escaping (Result<T?, Error>) -> Void) {
        collection.document(id).getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
            } else {
                guard let data = snapshot?.data() else { return completion(.success(nil)) }
                let decoder = JSONDecoder()
                do {
                    let json = try JSONSerialization.data(withJSONObject: data)
                    let model = try decoder.decode(T.self, from: json)
                    completion(.success(model))
                } catch {
                    completion(.success(nil))
                    print(error)
                }
            }
        }
    }
    
    func getAll(_ completion: @escaping (Result<[T], Error>) -> Void) {
        collection.getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
            } else {
                var models = [T]()
                let documents = snapshot?.documents ?? []
                let decoder = JSONDecoder()
                documents.forEach { document in
                    do {
                        let json = try JSONSerialization.data(withJSONObject: document.data())
                        let model = try decoder.decode(T.self, from: json)
                        models.append(model)
                    } catch {
                        print(error)
                    }
                }
                completion(.success(models))
            }
        }
    }
    
    func update(model: T, _ completion: @escaping (Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let dictionary else { throw CustomError("Can't encode \(String(describing: data))") }
            collection.document(model.objectId).updateData(dictionary, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func delete(id: String, _ completion: @escaping (Error?) -> Void) {
        collection.document(id).delete(completion: completion)
    }
}
