import Foundation

protocol ArchiveProvider {
    func canOpen(url: URL) -> Bool
    func listFiles(url: URL) throws -> [String]
    func readFile(url: URL, path: String) throws -> Data
}

final class DirectoryProvider: ArchiveProvider {
    func canOpen(url: URL) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }

    func listFiles(url: URL) throws -> [String] {
        // iOS 上 /var 与 /private/var 前缀可能不一致，所以统一解析符号链接后按路径分量取相对路径
        let base = url.resolvingSymlinksInPath()
        let baseCount = base.pathComponents.count
        guard let e = FileManager.default.enumerator(
            at: base,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { throw VNRuntimeError.gameNotFound }

        var result: [String] = []
        for case let item as URL in e {
            let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isDir { continue }
            let comps = item.resolvingSymlinksInPath().pathComponents
            result.append(comps.dropFirst(baseCount).joined(separator: "/"))
        }
        return result.sorted()
    }

    func readFile(url: URL, path: String) throws -> Data {
        let base = url.resolvingSymlinksInPath()
        let target = base.appendingPathComponent(path).resolvingSymlinksInPath()
        let b = base.pathComponents
        let t = target.pathComponents
        // 防止 "../" 逃出游戏目录
        guard t.count > b.count, Array(t.prefix(b.count)) == b else { throw VNRuntimeError.invalidPath }
        return try Data(contentsOf: target, options: .mappedIfSafe)
    }
}

// 占位：后续依据公开格式规范实现 PAC。
final class PACProvider: ArchiveProvider {
    func canOpen(url: URL) -> Bool { url.pathExtension.lowercased() == "pac" }
    func listFiles(url: URL) throws -> [String] { throw VNRuntimeError.unsupportedArchive }
    func readFile(url: URL, path: String) throws -> Data { throw VNRuntimeError.unsupportedArchive }
}

// 占位：后续依据公开格式规范实现 XP3（读取时用 .mappedIfSafe，不要整包读入内存）。
final class XP3Provider: ArchiveProvider {
    func canOpen(url: URL) -> Bool { url.pathExtension.lowercased() == "xp3" }
    func listFiles(url: URL) throws -> [String] { throw VNRuntimeError.unsupportedArchive }
    func readFile(url: URL, path: String) throws -> Data { throw VNRuntimeError.unsupportedArchive }
}
