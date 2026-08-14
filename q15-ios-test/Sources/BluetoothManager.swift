import Foundation
import CoreBluetooth

struct DiscoveredPrinter: Identifiable {
    let id: UUID
    let peripheral: CBPeripheral
    var name: String
    var rssi: Int
}

@MainActor
final class BluetoothManager: NSObject, ObservableObject {
    @Published var bluetoothState = "Bluetooth wird initialisiert …"
    @Published var isScanning = false
    @Published var devices: [DiscoveredPrinter] = []
    @Published var connectedName: String?
    @Published var log = "Kiddotronic Q15 Diagnose\n"

    private var central: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func toggleScan() {
        isScanning ? stopScan() : startScan()
    }

    func startScan() {
        guard central.state == .poweredOn else {
            append("Scan nicht möglich: Bluetooth ist nicht bereit.")
            return
        }
        devices.removeAll()
        isScanning = true
        append("BLE-Scan gestartet …")
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func stopScan() {
        central.stopScan()
        isScanning = false
        append("Scan gestoppt.")
    }

    func connect(_ item: DiscoveredPrinter) {
        stopScan()
        append("Verbinde mit \(item.name) [\(item.id.uuidString)] …")
        central.connect(item.peripheral, options: nil)
    }

    func disconnect() {
        if let p = connectedPeripheral { central.cancelPeripheralConnection(p) }
    }

    func clearLog() { log = "Kiddotronic Q15 Diagnose\n" }

    private func append(_ text: String) {
        log += "\n\(Date().formatted(date: .omitted, time: .standard))  \(text)"
    }

    private func properties(_ p: CBCharacteristicProperties) -> String {
        var result: [String] = []
        if p.contains(.read) { result.append("READ") }
        if p.contains(.write) { result.append("WRITE") }
        if p.contains(.writeWithoutResponse) { result.append("WRITE_NO_RESPONSE") }
        if p.contains(.notify) { result.append("NOTIFY") }
        if p.contains(.indicate) { result.append("INDICATE") }
        return result.isEmpty ? "OTHER" : result.joined(separator: " | ")
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            switch central.state {
            case .poweredOn: bluetoothState = "Bluetooth aktiv ✓"; append("Bluetooth ist aktiv.")
            case .poweredOff: bluetoothState = "Bluetooth ausgeschaltet"
            case .unauthorized: bluetoothState = "Bluetooth-Berechtigung fehlt"
            case .unsupported: bluetoothState = "Bluetooth LE nicht unterstützt"
            default: bluetoothState = "Bluetooth nicht bereit"
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Task { @MainActor in
            let advertised = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            let name = advertised ?? peripheral.name ?? "Unbekanntes BLE-Gerät"
            guard !devices.contains(where: { $0.id == peripheral.identifier }) else { return }
            devices.append(.init(id: peripheral.identifier, peripheral: peripheral, name: name, rssi: RSSI.intValue))
            append("Gefunden: \(name), RSSI \(RSSI)")
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            connectedPeripheral = peripheral
            connectedName = peripheral.name ?? "Q15 / BLE-Gerät"
            append("VERBUNDEN: \(connectedName!)")
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in append("Verbindung fehlgeschlagen: \(error?.localizedDescription ?? "unbekannt")") }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in connectedName = nil; connectedPeripheral = nil; append("Verbindung getrennt.") }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task { @MainActor in
            if let error { append("Service-Fehler: \(error.localizedDescription)"); return }
            append("=== SERVICES ===")
            for service in peripheral.services ?? [] {
                append("SERVICE \(service.uuid.uuidString)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task { @MainActor in
            if let error { append("Characteristic-Fehler: \(error.localizedDescription)"); return }
            for c in service.characteristics ?? [] {
                append("  CHAR \(c.uuid.uuidString)  [\(properties(c.properties))]")
            }
        }
    }
}
