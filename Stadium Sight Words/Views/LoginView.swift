
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthStore

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isCreateMode: Bool = false
    @State private var message: String = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.70, blue: 1.00),
                    Color(red: 0.55, green: 0.42, blue: 0.95),
                    Color(red: 1.00, green: 0.62, blue: 0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {

                VStack(spacing: 8) {
                    Text("Stadium Sight Words")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 8)

                    Text(isCreateMode ? "Create your account" : "Sign in to play")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 18)

                VStack(spacing: 12) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 18)

                if !message.isEmpty {
                    Text(message)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)
                }

                Button {
                    handlePrimary()
                } label: {
                    Text(isCreateMode ? "Create Account" : "Sign In")
                        .font(.title3.weight(.heavy))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.black.opacity(0.28))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 18)
                }

                Button {
                    // Toggle mode
                    message = ""
                    password = ""
                    if auth.hasRegisteredAccount {
                        isCreateMode.toggle()
                    } else {
                        isCreateMode = true
                    }
                } label: {
                    Text(toggleText)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
                .padding(.top, 4)

                Spacer()

                Text("Tip: Use a simple password you can remember.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: 520)
        }
        .onAppear {
            // If no account exists yet, default to create mode
            isCreateMode = !auth.hasRegisteredAccount
        }
    }

    private var toggleText: String {
        if !auth.hasRegisteredAccount {
            return "No account found. Create one now."
        }
        return isCreateMode ? "Already have an account? Sign in" : "Need an account? Create one"
    }

    private func handlePrimary() {
        message = ""

        if isCreateMode {
            let result = auth.register(username: username, password: password)
            message = result.message
        } else {
            let result = auth.login(username: username, password: password)
            message = result.message
        }
    }
}
