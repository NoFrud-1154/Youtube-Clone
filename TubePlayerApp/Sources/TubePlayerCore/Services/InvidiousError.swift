import Foundation

public enum InvidiousError: Error, LocalizedError, Equatable, Sendable {
    case allInstancesFailed
    case invalidResponse
    case decodingFailed(String)
    case videoUnavailable

    public var errorDescription: String? {
        switch self {
        case .allInstancesFailed:
            return "Không thể kết nối tới bất kỳ máy chủ Invidious nào. Vui lòng thử lại sau."
        case .invalidResponse:
            return "Phản hồi không hợp lệ từ máy chủ."
        case .decodingFailed(let detail):
            return "Không đọc được dữ liệu trả về: \(detail)"
        case .videoUnavailable:
            return "Video không còn khả dụng."
        }
    }
}
