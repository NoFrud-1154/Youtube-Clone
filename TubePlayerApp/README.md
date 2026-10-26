# TubePlayer

App iOS/iPadOS mới, độc lập hoàn toàn với Yattee, xem video dùng data YouTube qua
các instance Invidious công khai (không dùng YouTube Data API, không cần API key).

## Vì sao không có quảng cáo

Invidious lấy stream video trực tiếp từ CDN của Google (`googlevideo.com`) nhưng
**không** chèn các đoạn quảng cáo mà YouTube chèn ở player chính thức, nên video
phát ra đã không có quảng cáo xen giữa — không cần lọc network. Các đoạn quảng
cáo/tài trợ gắn trong nội dung video (sponsor segments) được tự động bỏ qua bằng
dữ liệu công khai từ [SponsorBlock](https://sponsor.ajay.app/).

## Vì sao chạy được nền

- `UIBackgroundModes: audio` trong Info.plist + `AVAudioSession` category `.playback`
  giữ audio tiếp tục phát khi khóa màn hình / chuyển app.
- `AVPlayerViewController` với `allowsPictureInPicturePlayback = true` cho phép
  Picture in Picture để video vẫn hiển thị khi chuyển sang app khác.
- `MPRemoteCommandCenter` / `MPNowPlayingInfoCenter` hiển thị điều khiển
  play/pause/skip trên màn hình khóa và Control Center.

## Cấu trúc

```
TubePlayerApp/
  Package.swift                     # SwiftPM package: TubePlayerCore (models + networking, không phụ thuộc UIKit)
  Sources/TubePlayerCore/
    Models/Video.swift               # Video, VideoDetails, SponsorSegment
    Services/InvidiousService.swift  # gọi API Invidious (có fallback nhiều instance) + SponsorBlock
    Services/InvidiousError.swift
  Tests/TubePlayerCoreTests/
  App/                                # Các file SwiftUI cho app target trong Xcode
    TubePlayerApp.swift
    ViewModels/PlayerViewModel.swift   # AVPlayer + nền + skip sponsor
    ViewModels/SearchViewModel.swift
    Views/HomeView.swift
    Views/VideoPlayerView.swift
    Info-additions.plist
```

## Cách mở project (cần máy Mac có Xcode — môi trường hiện tại là Linux, không build/test được ở đây)

1. Mở Xcode → File ▸ New ▸ Project ▸ iOS ▸ App. Đặt tên `TubePlayer`,
   interface SwiftUI, language Swift, deployment target iOS 16+.
2. Xóa các file mẫu (`ContentView.swift`, ...) mà Xcode tạo sẵn, copy toàn bộ
   nội dung thư mục `App/` vào target đó.
3. File ▸ Add Package Dependencies ▸ Add Local... ▸ chọn thư mục `TubePlayerApp/`
   (chứa `Package.swift`) để thêm `TubePlayerCore` làm dependency của target.
4. Target ▸ Signing & Capabilities ▸ `+ Capability` ▸ **Background Modes** ▸
   tick **Audio, AirPlay, and Picture in Picture** (tương đương nội dung
   `Info-additions.plist`).
5. Build & Run trên simulator hoặc thiết bị thật.

## Hạn chế / việc còn lại

- Chưa kiểm thử thực tế (môi trường này không có Xcode/macOS để build).
- Danh sách instance Invidious trong `InvidiousService.defaultInstances` là
  instance công khai, có thể thay đổi uptime; nên thêm màn hình Settings cho
  người dùng tự nhập instance riêng nếu cần độ tin cậy cao hơn.
- Chưa có cache/offline, chưa có hàng đợi phát (queue) hay lịch sử xem.
