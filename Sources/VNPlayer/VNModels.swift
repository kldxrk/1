import Foundation

struct VNGame: Codable, Identifiable {
    let id: String
    let title: String
    let scenes: [VNScene]
}

struct VNScene: Codable, Identifiable {
    let id: String
    let background: String?
    let speaker: String?
    let text: String
}

struct VNSave: Codable {
    let gameId: String
    let sceneIndex: Int
    let timestamp: Date
}

enum VNRuntimeError: Error {
    case gameNotFound
    case invalidScene
    case unsupportedArchive
    case invalidPath
    case saveMismatch
}

extension VNRuntimeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .gameNotFound: return "找不到游戏数据"
        case .invalidScene: return "存档指向的场景不存在"
        case .unsupportedArchive: return "暂不支持该封包格式"
        case .invalidPath: return "非法路径"
        case .saveMismatch: return "存档不属于当前游戏"
        }
    }
}
