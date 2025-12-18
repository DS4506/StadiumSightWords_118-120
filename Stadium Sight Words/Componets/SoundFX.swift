
import Foundation
import AudioToolbox

enum SoundFX {
    static func correct() {
        // Light “success” sound (system sound)
        AudioServicesPlaySystemSound(1104)
    }

    static func incorrect() {
        // Light “error” sound (system sound)
        AudioServicesPlaySystemSound(1053)
    }
}
