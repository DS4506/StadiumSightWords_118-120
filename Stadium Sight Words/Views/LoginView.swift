
import SwiftUI
import AudioToolbox

struct LoginView: View {
    @EnvironmentObject private var auth: AuthStore

    @State private var username = ""
    @State private var password = ""
    @State private var isCreateMode = false
    @State private var message = ""

    var body: some View {
        ZStack {
            background

            VStack(spacing: 18) {
                header

                VStack(spacing: 14) {
                    formCard
                    toggleRow
                }
                .frame(maxWidth: 520)

                Spacer(minLength: 0)

                Text("Tip: A short password is fine for this demo.")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.bottom, 14)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
        }
        .onAppear {
            isCreateMode = !auth.hasRegisteredAccount
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.35, green: 0.52, blue: 0.96),
                Color(red: 0.50, green: 0.35, blue: 0.95),
                Color(red: 0.96, green: 0.55, blue: 0.68)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            StarsOverlay()
                .opacity(0.25)
                .ignoresSafeArea()
        )
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {

            HStack(spacing: 14) {
                mascot("soccer_icon")
                mascot("basketball_icon")
                mascot("football_icon")
            }
            .padding(.top, 10)

            Text("Stadium")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 8)

            Text("Sight Words")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 8)

            Text(isCreateMode ? "Create your player account" : "Sign in to play")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white.opacity(0.92))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.16), in: Capsule())
        }
        .padding(.bottom, 8)
    }

    private func mascot(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 52, height: 52)
            .padding(8)
            .background(.white.opacity(0.18), in: Circle())
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
    }

    // MARK: - Form

    private var formCard: some View {
        VStack(spacing: 12) {

            HStack {
                Text(isCreateMode ? "Create Account" : "Sign In")
                    .font(.title3.weight(.heavy))
                    .foregroundColor(.black.opacity(0.85))
                Spacer()
            }

            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )

            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )

            if !message.isEmpty {
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Button {
                handlePrimary()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isCreateMode ? "person.badge.plus" : "play.fill")
                    Text(isCreateMode ? "Create & Play" : "Play Now")
                }
                .font(.title3.weight(.heavy))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.70, blue: 0.45),
                            Color(red: 0.10, green: 0.55, blue: 0.85)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
            }
            .padding(.top, 6)
        }
        .padding(16)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 10)
    }

    private var toggleRow: some View {
        Button {
            message = ""
            password = ""
            if auth.hasRegisteredAccount {
                isCreateMode.toggle()
            } else {
                isCreateMode = true
            }
        } label: {
            Text(auth.hasRegisteredAccount
                 ? (isCreateMode ? "Already have an account? Sign in" : "Need an account? Create one")
                 : "No account yet. Create one to play!")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white.opacity(0.95))
                .padding(.top, 4)
        }
    }

    // MARK: - Actions

    private func handlePrimary() {
        message = ""

        // ✅ Fun “game start” sound
        playStartSound()

        if isCreateMode {
            let result = auth.register(username: username, password: password)
            message = result.1
        } else {
            let result = auth.login(username: username, password: password)
            message = result.1
        }
    }

    private func playStartSound() {
        // A light, upbeat system sound (no audio files needed)
        AudioServicesPlaySystemSound(1108)
    }
}

// MARK: - Stars Overlay

private struct StarsOverlay: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkles")
                .font(.system(size: 220))
                .foregroundStyle(.white)
                .offset(x: -130, y: -170)

            Image(systemName: "sparkles")
                .font(.system(size: 170))
                .foregroundStyle(.white)
                .offset(x: 140, y: 230)

            Image(systemName: "sparkles")
                .font(.system(size: 120))
                .foregroundStyle(.white)
                .offset(x: -80, y: 300)
        }
    }
}
