import SwiftUI
import CloudKit

struct UnderlineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .multilineTextAlignment(.center)
            .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottomLeading)
            .foregroundColor(Color.black)
    }
}

struct UserProfileView: View {
    @State private var nickname: String = ""
    @State private var showGreeting = false
    @State private var isLoading = false
    @State private var isFetched = false // إضافة للتحقق من حالة الجلب
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                // تظهر النافذة فقط إذا تم الجلب ولم يوجد اسم
                if isFetched && !showGreeting {
                    VStack(spacing: 10) {
                        Text("Enter Your Name")
                            .padding(.bottom, 20)
                            .font(.headline)
                        
                        TextField("Enter Your Name", text: $nickname)
                            .textFieldStyle(UnderlineTextFieldStyle())
                            .padding(.horizontal)
                        
                        Text("Choose a Good one, you can't change it!")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 40)
                        
                        Button("Save") {
                            isLoading = true
                            UserProfileManager.shared.createUserProfile(nickname: nickname) {
                                self.isLoading = false
                                self.showGreeting = true
                            }
                        }
                        .disabled(nickname.isEmpty || isLoading)
                        .padding()
                        .frame(width: 120, height: 50)
                        .background(isLoading ? Color.gray : Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        if isLoading {
                            ProgressView()
                        }
                    }
                    .frame(width: 320, height: 300)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1)
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarItems(
                leading: showGreeting ? AnyView(Text("Welcome, \(nickname)!").bold()) : AnyView(EmptyView()),
                trailing: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "Plus") // تغيير الأيقونة إلى xmark
                }
            )
            .navigationTitle("Boards")
            .onAppear {
                UserProfileManager.shared.fetchUserProfile { fetchedNickname in
                    self.isFetched = true // تحديث حالة الجلب
                    if let fetchedNickname = fetchedNickname {
                        self.nickname = fetchedNickname
                        self.showGreeting = true
                    }
                }
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
