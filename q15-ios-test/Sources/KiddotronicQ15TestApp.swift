import SwiftUI

@main
struct KiddotronicQ15TestApp: App {
    @StateObject private var bluetooth = BluetoothManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetooth)
        }
    }
}
