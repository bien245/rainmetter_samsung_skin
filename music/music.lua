function Initialize()
    -- Tạo thư mục cache nếu chưa có
    local cachePath = SKIN:GetVariable('CURRENTPATH') .. 'cache\\'
    os.execute('mkdir "' .. cachePath .. '" 2>nul')
    
    -- Khởi tạo biến để theo dõi URL và cache màu
    lastCoverUrl = ""
    colorCache = {}  -- Cache màu để tối ưu CPU
end

function Update()
    -- Chỉ đổi màu khi có bài hát mới
    local currentUrl = SKIN:GetMeasure('MeasureCover'):GetStringValue()
    if currentUrl and currentUrl ~= lastCoverUrl and currentUrl ~= '' then
        lastCoverUrl = currentUrl
        print('Cover changed to: ' .. tostring(currentUrl))
        
        -- Đổi màu khi có bài mới
        DownloadCover()
        
        -- Làm sạch cache nếu quá lớn (tối ưu bộ nhớ)
        local cacheSize = 0
        for _ in pairs(colorCache) do cacheSize = cacheSize + 1 end
        if cacheSize > 50 then  -- Giới hạn 50 ảnh trong cache
            colorCache = {}
            print('Cache cleared to optimize memory')
        end
    end
end

function DownloadCover()
    local coverUrl = SKIN:GetMeasure('MeasureCover'):GetStringValue()
    print('Processing cover: ' .. tostring(coverUrl))
    
    -- Cập nhật ảnh cover
    SKIN:Bang('!UpdateMeter', 'CoverImage')
    SKIN:Bang('!Redraw')
    
    -- Phân tích màu thực tế từ ảnh
    if coverUrl and coverUrl ~= '' then
        ExtractDominantColor(coverUrl)
    else
        -- Nếu không có cover, dùng màu mặc định
        print('No cover found, using default color')
        SKIN:Bang('!SetVariable', 'ProgressColorR', '100')
        SKIN:Bang('!SetVariable', 'ProgressColorG', '200') 
        SKIN:Bang('!SetVariable', 'ProgressColorB', '255')
        SKIN:Bang('!UpdateMeter', 'ProgressBar')
        SKIN:Bang('!Redraw')
    end
end

function ExtractDominantColor(imagePath)
    -- Tối ưu: chỉ chạy khi cần thiết
    if not imagePath or imagePath == '' then return end
    
    -- Kiểm tra cache trước khi phân tích
    if colorCache[imagePath] then
        local cached = colorCache[imagePath]
        print('Using cached color: R=' .. cached.r .. ' G=' .. cached.g .. ' B=' .. cached.b)
        SKIN:Bang('!SetVariable', 'ProgressColorR', cached.r)
        SKIN:Bang('!SetVariable', 'ProgressColorG', cached.g) 
        SKIN:Bang('!SetVariable', 'ProgressColorB', cached.b)
        SKIN:Bang('!UpdateMeter', 'ProgressBar')
        SKIN:Bang('!Redraw')
        return
    end
    
    print('Extracting dominant color from: ' .. imagePath)
    
    -- Script PowerShell đơn giản hóa để lấy màu chủ đạo
    local escapedPath = string.gsub(imagePath, "'", "''")  -- Escape single quotes
    local psScript = string.format([[
Add-Type -AssemblyName System.Drawing
try {
    if (Test-Path '%s') {
        $img = [System.Drawing.Image]::FromFile('%s')
        $bitmap = New-Object System.Drawing.Bitmap($img, 16, 16)
        
        $r = $g = $b = $count = 0
        
        for ($x = 0; $x -lt 16; $x += 1) {
            for ($y = 0; $y -lt 16; $y += 1) {
                $pixel = $bitmap.GetPixel($x, $y)
                $brightness = ($pixel.R + $pixel.G + $pixel.B) / 3
                if ($brightness -gt 20 -and $brightness -lt 235) {
                    $r += $pixel.R
                    $g += $pixel.G  
                    $b += $pixel.B
                    $count++
                }
            }
        }
        
        if ($count -gt 0) {
            $avgR = [math]::Round($r / $count)
            $avgG = [math]::Round($g / $count)
            $avgB = [math]::Round($b / $count)
            Write-Output "$avgR,$avgG,$avgB"
        } else {
            Write-Output "255,100,100"
        }
        
        $bitmap.Dispose()
        $img.Dispose()
    } else {
        Write-Output "100,255,100"
    }
} catch {
    Write-Output "100,100,255"
}
]], escapedPath, escapedPath)
    
    -- Chạy PowerShell và lấy kết quả
    local tempFile = os.tmpname()
    local cmd = 'powershell -Command "' .. psScript .. '" > "' .. tempFile .. '"'
    os.execute(cmd)
    
    -- Đọc kết quả
    local file = io.open(tempFile, 'r')
    if file then
        local result = file:read('*line')
        file:close()
        os.remove(tempFile)
        
        if result and string.match(result, '%d+,%d+,%d+') then
            local r, g, b = string.match(result, '(%d+),(%d+),(%d+)')
            print('Dominant color: R=' .. r .. ' G=' .. g .. ' B=' .. b)
            
            -- Lưu vào cache để lần sau không phải phân tích lại
            colorCache[imagePath] = {r = r, g = g, b = b}
            
            -- Cập nhật màu progress bar
            print('Setting progress color to: ' .. r .. ',' .. g .. ',' .. b)
            SKIN:Bang('!SetVariable', 'ProgressColorR', r)
            SKIN:Bang('!SetVariable', 'ProgressColorG', g) 
            SKIN:Bang('!SetVariable', 'ProgressColorB', b)
            SKIN:Bang('!UpdateMeter', 'ProgressBar')
            SKIN:Bang('!Redraw')
            print('Progress bar color updated successfully')
        end
    end
end

function CreateRoundMask()
    -- Tạo mask hình tròn cho ảnh cover
    local size = tonumber(SKIN:GetVariable('CoverSize')) or 120
    local radius = size / 2
    
    -- Cập nhật shape mask
    local maskShape = 'Ellipse ' .. radius .. ',' .. radius .. ',' .. radius .. ' | Fill Color 255,255,255,255 | StrokeWidth 0'
    SKIN:Bang('!SetOption', 'CoverMask', 'Shape', maskShape)
    SKIN:Bang('!UpdateMeter', 'CoverMask')
    SKIN:Bang('!Redraw')
end
