
import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var auth: AuthStore
    @Environment(\.dismiss) private var dismiss

    @State private var showChangeUsername = false
    @State private var showChangeEmail = false
    @State private var showChangePassword = false
    @State private var showLogoutConfirm = false
    @State private var showMyItems = false

    @State private var currentPassword = ""
    @State private var newUsername = ""
    @State private var newEmail = ""
    @State private var newPassword = ""

    @State private var statusMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                background

                VStack(spacing: 16) {
                    topRow
                    headerCard

                    VStack(spacing: 12) {
                        ActionCardButton(
                            icon: "person.fill",
                            title: "Change Username",
                            subtitle: "Update your player name",
                            color: .blue
                        ) {
                            statusMessage = ""
                            currentPassword = ""
                            newUsername = ""
                            showChangeUsername = true
                        }

                        ActionCardButton(
                            icon: "envelope.fill",
                            title: "Change Email",
                            subtitle: "Update your email address",
                            color: .purple
                        ) {
                            statusMessage = ""
                            newEmail = auth.email
                            showChangeEmail = true
                        }

                        ActionCardButton(
                            icon: "lock.fill",
                            title: "Change Password",
                            subtitle: "Reset your password",
                            color: .green
                        ) {
                            statusMessage = ""
                            currentPassword = ""
                            newPassword = ""
                            showChangePassword = true
                        }

                        // ✅ Core Data assignment screen
                        NavigationLink(destination: ContentView()) {
                            ActionCardRow(
                                icon: "tray.full.fill",
                                title: "My Items (Core Data)",
                                subtitle: "Add/delete items and show persistence",
                                color: .orange
                            )
                        }
                        .buttonStyle(.plain)

                        ActionCardButton(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Logout",
                            subtitle: "Return to login screen",
                            color: .red
                        ) {
                            showLogoutConfirm = true
                        }
                    }
                    .padding(.horizontal, 18)

                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .multilineTextAlignment(.center)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.top, 12)
            }
            .navigationBarHidden(true)
        }
        .confirmationDialog("Logout?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Logout", role: .destructive) {
                auth.logout()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showChangeUsername) { changeUsernameSheet }
        .sheet(isPresented: $showChangeEmail) { changeEmailSheet }
        .sheet(isPresented: $showChangePassword) { changePasswordSheet }
    }

    // MARK: - UI

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
        .overlay(StarsOverlay().opacity(0.25))
    }

    private var topRow: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.white.opacity(0.16), in: Circle())
            }

            Spacer()

            Text("Account")
                .font(.headline.weight(.heavy))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "gearshape.fill")
                .foregroundColor(.white.opacity(0.9))
                .padding(10)
                .background(.white.opacity(0.16), in: Circle())
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    private var headerCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image("soccer_icon").resizable().scaledToFit().frame(width: 40, height: 40)
                Image("basketball_icon").resizable().scaledToFit().frame(width: 40, height: 40)
                Image("football_icon").resizable().scaledToFit().frame(width: 40, height: 40)
            }
            .padding(.top, 6)

            Text(auth.currentUsername.isEmpty ? "Player" : auth.currentUsername)
                .font(.title2.weight(.heavy))
                .foregroundColor(.black.opacity(0.85))

            Text(auth.email.isEmpty ? "Email not set" : auth.email)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black.opacity(0.6))
        }
        .padding(16)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 10)
        .padding(.horizontal, 18)
    }

    // MARK: - Sheets

    private var changeUsernameSheet: some View {
        SheetContainer(title: "Change Username") {
            SecureField("Current password", text: $currentPassword)
            TextField("New username", text: $newUsername)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

            Button("Save") {
                let result = auth.updateUsername(currentPassword: currentPassword, newUsername: newUsername)
                statusMessage = result.1
                if result.0 { showChangeUsername = false }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var changeEmailSheet: some View {
        SheetContainer(title: "Change Email") {
            TextField("Email", text: $newEmail)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

            Button("Save") {
                let result = auth.updateEmail(newEmail: newEmail)
                statusMessage = result.1
                if result.0 { showChangeEmail = false }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var changePasswordSheet: some View {
        SheetContainer(title: "Change Password") {
            SecureField("Current password", text: $currentPassword)
            SecureField("New password", text: $newPassword)

            Button("Save") {
                let result = auth.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
                statusMessage = result.1
                if result.0 { showChangePassword = false }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Components

private struct ActionCardButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ActionCardRow(icon: icon, title: title, subtitle: subtitle, color: color)
        }
        .buttonStyle(.plain)
    }
}

private struct ActionCardRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.9), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.heavy))
                    .foregroundColor(.black.opacity(0.85))
                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black.opacity(0.55))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.35))
        }
        .padding(14)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}

private struct SheetContainer<Content: View>: View {
    let title: String
    let content: () -> Content
    @Environment(\.dismiss) private var dismiss

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 14) {
                content()
                    .textFieldStyle(.roundedBorder)

                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct StarsOverlay: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkles")
                .font(.system(size: 220))
                .foregroundStyle(.white)
                .offset(x: -120, y: -120)

            Image(systemName: "sparkles")
                .font(.system(size: 180))
                .foregroundStyle(.white)
                .offset(x: 130, y: 220)

            Image(systemName: "sparkles")
                .font(.system(size: 120))
                .foregroundStyle(.white)
                .offset(x: -60, y: 260)
        }
    }
}
