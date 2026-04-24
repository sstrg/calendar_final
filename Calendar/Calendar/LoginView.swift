import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var onLoginSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Logo
            Image(systemName: "calendar.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Calendar App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            Button("Create new account") {
                showRegister = true
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView(onRegisterSuccess: {
                showRegister = false
                onLoginSuccess()
            })
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let user = try await APIService.shared.login(email: email, password: password)
                await MainActor.run {
                    SessionManager.shared.user = user
                    isLoading = false
                    onLoginSuccess()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
