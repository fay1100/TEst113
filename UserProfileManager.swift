import Foundation
import CloudKit

class UserProfileManager {
    static let shared = UserProfileManager()
    private let container: CKContainer
    private let database: CKDatabase

    private init() {
        // استخدام حاوية محددة بناءً على معرف الحاوية المخصص
        container = CKContainer(identifier: "iCloud.fa.CloudKitTest1")
        database = container.privateCloudDatabase
    }

    // دالة لاسترجاع ملف المستخدم إذا كان موجوداً
    func fetchUserProfile(completion: @escaping (String?) -> Void) {
        let predicate = NSPredicate(value: true)  // هذا الشرط يمكن تعديله ليكون أكثر تحديداً
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let records = records, !records.isEmpty {
                    let record = records.first!
                    let nickname = record["nickname"] as? String
                    completion(nickname)
                } else {
                    completion(nil)
                }
            }
        }
    }

    // دالة لإنشاء ملف المستخدم الجديد
    func createUserProfile(nickname: String, completion: @escaping () -> Void) {
        let predicate = NSPredicate(format: "nickname == %@", nickname)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, e in
            DispatchQueue.main.async {
                if let records = records, !records.isEmpty {
                    print("User already exists")
                    completion()  // دعوة الـ completion لتحديث الواجهة
                } else {
                    self?.saveNewUserProfile(nickname: nickname, completion: completion)
                }
            }
        }
    }

    // دالة خاصة لحفظ ملف المستخدم الجديد في CloudKit
    private func saveNewUserProfile(nickname: String, completion: @escaping () -> Void) {
        let record = CKRecord(recordType: "UserProfile")
        record["nickname"] = nickname

        database.save(record) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error occurred: \(error.localizedDescription)")
                } else {
                    print("Record saved successfully")
                    completion()  // دعوة الـ completion لتحديث الواجهة
                }
            }
        }
    }
}
