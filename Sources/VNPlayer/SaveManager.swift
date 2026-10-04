import Foundation

final class SaveManager {
    private let directory: URL

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directory = base.appendingPathComponent("VNPlayer/Saves", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func fileURL(gameId: String, slot: Int) -> URL {
        let safe = String(gameId.map { ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") ? $0 : "_" })
        return directory.appendingPathComponent("\(safe)_slot\(slot).json")
    }

    func save(_ value: VNSave, slot: Int) throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: fileURL(gameId: value.gameId, slot: slot), options: .atomic)
    }

    func load(gameId: String, slot: Int) throws -> VNSave {
        let data = try Data(contentsOf: fileURL(gameId: gameId, slot: slot))
        let value = try JSONDecoder().decode(VNSave.self, from: data)
        guard value.gameId == gameId else { throw VNRuntimeError.saveMismatch }
        return value
    }
}
