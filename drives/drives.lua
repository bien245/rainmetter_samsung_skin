-- Biến lưu trạng thái ổ đĩa trước đó
local previousDrives = {}
local driveCount = 0

function Initialize()
    -- Khởi tạo script
    DetectDrives()
end

function Update()
    -- Cập nhật thông tin hệ thống
    local driveList = DetectDrives()
    
    -- Trả về thông tin chi tiết cho hiển thị
    local info = "Số ổ đĩa: " .. GetDriveCount() .. "\n"
    info = info .. "Danh sách: " .. driveList .. "\n\n"
    
    for i = 1, GetDriveCount() do
        local letter = GetDriveLetter(i)
        local name = GetDriveName(letter)
        info = info .. letter .. ": " .. name .. "\n"
    end
    
    info = info .. "\nRAM: Đang sử dụng\n"
    info = info .. "\n(Cắm USB và nhấn Refresh để cập nhật)"
    
    return info
end

-- Hàm phát hiện tất cả ổ đĩa có sẵn (sử dụng WMI)
function DetectDrives()
    local drives = {}
    local currentDrives = {}
    
    -- Sử dụng WMI để lấy danh sách ổ đĩa chính xác hơn
    local handle = io.popen('wmic logicaldisk get DeviceID /value 2>nul')
    if handle then
        local result = handle:read("*a")
        handle:close()
        
        -- Tìm tất cả DeviceID
        for deviceID in result:gmatch("DeviceID=([A-Z]:)") do
            local letter = deviceID:sub(1,1)
            table.insert(drives, letter)
            currentDrives[letter] = true
        end
    end
    
    -- Kiểm tra thay đổi
    local hasChanged = false
    if #drives ~= driveCount then
        hasChanged = true
        driveCount = #drives
    else
        -- Kiểm tra từng ổ đĩa
        for _, letter in ipairs(drives) do
            if not previousDrives[letter] then
                hasChanged = true
                break
            end
        end
        for letter, _ in pairs(previousDrives) do
            if not currentDrives[letter] then
                hasChanged = true
                break
            end
        end
    end
    
    -- Cập nhật nếu có thay đổi
    if hasChanged then
        previousDrives = currentDrives
        
        -- Cập nhật biến số lượng ổ đĩa
        SKIN:Bang('!SetVariable', 'DriveCount', #drives)
        
        -- Tạo danh sách ổ đĩa
        local driveList = table.concat(drives, ",")
        SKIN:Bang('!SetVariable', 'DriveList', driveList)
        
        -- Refresh toàn bộ skin
        SKIN:Bang('!Refresh')
        
        print("Drives changed: " .. driveList)
    end
    
    return table.concat(drives, ",")
end

-- Hàm lấy tên ổ đĩa
function GetDriveName(driveLetter)
    local handle = io.popen('wmic logicaldisk where "DeviceID=\'' .. driveLetter .. ':\'" get VolumeName /value 2>nul')
    if handle then
        local result = handle:read("*a")
        handle:close()
        
        local volumeName = result:match("VolumeName=([^\r\n]*)")
        if volumeName and volumeName ~= "" then
            return volumeName
        end
    end
    
    -- Trả về tên mặc định nếu không tìm thấy
    if driveLetter == "C" then
        return "System"
    elseif driveLetter == "D" then
        return "Data"
    else
        return "Drive " .. driveLetter
    end
end

-- Hàm format dung lượng theo GB
function FormatBytes(bytes)
    if bytes == nil or bytes == 0 then
        return "0 GB"
    end
    
    local gb = bytes / (1024 * 1024 * 1024)
    return string.format("%.1f GB", gb)
end

-- Hàm tính phần trăm sử dụng
function GetUsagePercent(used, total)
    if total == nil or total == 0 then
        return 0
    end
    return math.floor((used / total) * 100)
end

-- Hàm lấy số lượng ổ đĩa
function GetDriveCount()
    local drives = {}
    
    -- Sử dụng WMI để lấy danh sách ổ đĩa
    local handle = io.popen('wmic logicaldisk get DeviceID /value 2>nul')
    if handle then
        local result = handle:read("*a")
        handle:close()
        
        -- Tìm tất cả DeviceID
        for deviceID in result:gmatch("DeviceID=([A-Z]:)") do
            local letter = deviceID:sub(1,1)
            table.insert(drives, letter)
        end
    end
    
    -- Đảm bảo luôn có ít nhất 1 ổ đĩa (C:)
    if #drives == 0 then
        return 1
    end
    
    return #drives
end

-- Hàm lấy chữ cái ổ đĩa theo thứ tự
function GetDriveLetter(index)
    local drives = {}
    
    -- Sử dụng WMI để lấy danh sách ổ đĩa
    local handle = io.popen('wmic logicaldisk get DeviceID /value 2>nul')
    if handle then
        local result = handle:read("*a")
        handle:close()
        
        -- Tìm tất cả DeviceID
        for deviceID in result:gmatch("DeviceID=([A-Z]:)") do
            local letter = deviceID:sub(1,1)
            table.insert(drives, letter)
        end
    end
    
    -- Sắp xếp theo thứ tự alphabet
    table.sort(drives)
    
    if index <= #drives and index > 0 then
        return drives[index]
    else
        return "C"  -- Mặc định trả về C: nếu không tìm thấy
    end
end

-- Hàm lấy màu cho ổ đĩa
function GetDriveColor(index)
    local colors = {
        "0,191,255,255",    -- Xanh dương
        "0,255,128,255",    -- Xanh lá
        "255,165,0,255",    -- Cam
        "255,99,132,255",   -- Hồng
        "75,192,192,255",   -- Xanh ngọc
        "255,205,86,255"    -- Vàng
    }
    
    local colorIndex = ((index - 1) % #colors) + 1
    return colors[colorIndex]
end
