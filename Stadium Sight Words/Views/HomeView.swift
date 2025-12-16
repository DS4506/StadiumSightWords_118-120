
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: SightWordsViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {

                Text("Stadium Sight Words")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("SSText", bundle: nil))

                Text("Tap the right word to score.")
                    .font(.headline)
                    .foregroundColor(Color("SSText", bundle: nil))

                VStack(spacing: 12) {
                    ForEach(SportType.allCases) { sport in
                        NavigationLink(destination: PracticeView(sport: sport)) {
                            HStack(spacing: 12) {
                                Image(systemName: sport.iconName)
                                    .font(.title2)
                                    .foregroundColor(.white)

                                Text(sport.displayName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(Color("SSPrimary", bundle: nil))
                            .cornerRadius(14)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color("SSBackground", bundle: nil).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
