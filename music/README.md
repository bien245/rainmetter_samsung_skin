# Music Player Widget - OneUI Theme

Widget âm nhạc hiện đại cho Rainmeter với hỗ trợ WebNowPlaying.

## Tính năng

- ✅ Hiển thị thông tin bài hát (tên, nghệ sĩ, album)
- ✅ Thumbnail album với hiệu ứng opacity làm background
- ✅ Thanh tiến trình có thể tương tác
- ✅ Nút điều khiển: Play/Pause, Previous, Next, Shuffle, Repeat
- ✅ Hiển thị thời gian hiện tại và tổng thời gian
- ✅ Thiết kế OneUI hiện đại với bo góc và hiệu ứng

## Yêu cầu

1. **Rainmeter** - Phiên bản mới nhất
2. **WebNowPlaying Plugin** - Tải từ [GitHub](https://github.com/tjhrulz/WebNowPlaying)

## Cài đặt

### Bước 1: Cài đặt WebNowPlaying Plugin
1. Tải WebNowPlaying plugin từ GitHub
2. Giải nén và copy file `.dll` vào thư mục `Plugins` của Rainmeter
3. Khởi động lại Rainmeter

### Bước 2: Cài đặt Extension cho trình duyệt
- **Chrome/Edge**: Tải WebNowPlaying Companion từ Chrome Web Store
- **Firefox**: Tải WebNowPlaying Companion từ Firefox Add-ons

### Bước 3: Load widget
1. Mở Rainmeter Manager
2. Tìm skin `oneui\music`
3. Click "Load" để kích hoạt widget

## Tùy chỉnh

Bạn có thể chỉnh sửa các biến trong file `music.ini`:

```ini
[Variables]
BackgroundOpacity=60    ; Độ mờ background (0-100)
CoverOpacity=40         ; Độ mờ thumbnail (0-100)
WidgetWidth=380         ; Chiều rộng widget
WidgetHeight=110        ; Chiều cao widget
```

## Hỗ trợ

Widget hỗ trợ các trình phát nhạc web:
- YouTube Music
- Spotify Web Player
- SoundCloud
- Và nhiều trang web khác

## Lưu ý

- Đảm bảo extension WebNowPlaying đã được bật trong trình duyệt
- Widget sẽ tự động cập nhật khi có nhạc phát
- Nếu không hiển thị thông tin, kiểm tra kết nối plugin và extension
