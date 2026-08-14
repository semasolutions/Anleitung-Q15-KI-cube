import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetooth: BluetoothManager

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "printer.fill").font(.largeTitle).foregroundStyle(.red)
                        VStack(alignment: .leading) {
                            Text("Kiddotronic Q15").font(.title2.bold())
                            Text("Bluetooth Verbindungstest").foregroundStyle(.secondary)
                        }
                    }.padding(.vertical, 8)
                    Label(bluetooth.bluetoothState, systemImage: "antenna.radiowaves.left.and.right")
                    if let name = bluetooth.connectedName {
                        Label("Verbunden mit \(name)", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                        Button("Verbindung trennen", role: .destructive) { bluetooth.disconnect() }
                    }
                }

                Section("Drucker suchen") {
                    Button(bluetooth.isScanning ? "Suche stoppen" : "Q15 / BLE-Geräte suchen") { bluetooth.toggleScan() }
                        .buttonStyle(.borderedProminent)
                    if bluetooth.isScanning { ProgressView("Suche läuft …") }
                    ForEach(bluetooth.devices) { item in
                        Button { bluetooth.connect(item) } label: {
                            HStack {
                                Image(systemName: "printer")
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.headline)
                                    Text("Signal: \(item.rssi) dBm\n\(item.id.uuidString)").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }.foregroundStyle(.primary)
                    }
                }

                Section("Diagnose – für den nächsten Druck-Test") {
                    Text(bluetooth.log).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                    ShareLink(item: bluetooth.log) { Label("Diagnose teilen", systemImage: "square.and.arrow.up") }
                    Button("Protokoll leeren") { bluetooth.clearLog() }
                }

                Section {
                    Text("Diese Version sendet noch keine Druckbefehle. Sie ermittelt zuerst sicher die BLE-Services und Characteristics deines konkreten Q15. Teile danach das Diagnoseprotokoll, damit die Druckschnittstelle implementiert werden kann.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Q15 Test")
        }
    }
}
