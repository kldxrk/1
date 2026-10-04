import Foundation
import SwiftUI

@MainActor
final class VNRuntime: ObservableObject {
    @Published private(set) var game: VNGame?
    @Published private(set) var sceneIndex = 0
    @Published private(set) var message: String?

    private let saves = SaveManager()

    var currentScene: VNScene? {
        guard let game, game.scenes.indices.contains(sceneIndex) else { return nil }
        return game.scenes[sceneIndex]
    }

    var isAtEnd: Bool {
        guard let game else { return true }
        return sceneIndex + 1 >= game.scenes.count
    }

    private func flash(_ text: String) {
        message = text
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if self?.message == text { self?.message = nil }
        }
    }

    func loadDemo() {
        do {
            guard let url = Bundle.main.url(forResource: "demo", withExtension: "json") else {
                throw VNRuntimeError.gameNotFound
            }
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(VNGame.self, from: data)
            game = decoded
            sceneIndex = 0
            message = nil
        } catch {
            flash("载入失败：\(error.localizedDescription)")
        }
    }

    func next() {
        guard !isAtEnd else { return }
        sceneIndex += 1
    }

    func previous() {
        if sceneIndex > 0 { sceneIndex -= 1 }
    }

    func save(slot: Int) {
        guard let game else { return }
        do {
            try saves.save(VNSave(gameId: game.id, sceneIndex: sceneIndex, timestamp: Date()), slot: slot)
            flash("已存档（栏位 \(slot)）")
        } catch {
            flash("存档失败：\(error.localizedDescription)")
        }
    }

    func load(slot: Int) {
        guard let game else { return }
        do {
            let value = try saves.load(gameId: game.id, slot: slot)
            guard game.scenes.indices.contains(value.sceneIndex) else { throw VNRuntimeError.invalidScene }
            sceneIndex = value.sceneIndex
            flash("已读档（栏位 \(slot)）")
        } catch {
            flash("读档失败：\(error.localizedDescription)")
        }
    }
}
