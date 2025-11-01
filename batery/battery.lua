function Initialize()
    -- Khởi tạo các biến
    circleX = tonumber(SKIN:GetVariable('CircleX'))
    circleY = tonumber(SKIN:GetVariable('CircleY'))
    circleSize = tonumber(SKIN:GetVariable('CircleSize'))
    circleWidth = tonumber(SKIN:GetVariable('CircleWidth'))
    
    -- Lấy màu sắc từ Rainmeter
    local function parseColor(colorStr)
        local r, g, b, a = colorStr:match('(%d+),(%d+),(%d+),(%d+)')
        return {tonumber(r), tonumber(g), tonumber(b), tonumber(a) or 255}
    end
    
    circleColor = parseColor(SKIN:GetVariable('CircleColor'))
    circleBGColor = parseColor(SKIN:GetVariable('CircleBG'))
    
    -- Khởi tạo biến toàn cục
    arc = {}
    arcProgress = {}
    batteryPercent = 0
    
    -- Tính toán bán kính trong và ngoài
    radius = circleSize / 2
    innerRadius = radius - circleWidth
    
    -- Tạo hình dạng vòng cung
    local segments = 180
    local startAngle = math.rad(-90)  -- Bắt đầu từ trên cùng
    local endAngle = math.rad(270)    -- Kết thúc ở dưới cùng
    local angleStep = (endAngle - startAngle) / segments
    
    -- Xóa dữ liệu cũ
    for i = #arc, 1, -1 do
        table.remove(arc, i)
    end
    
    -- Tạo các điểm cho vòng cung ngoài
    for i = 0, segments do
        local angle = startAngle + i * angleStep
        local x = circleX + radius * math.cos(angle)
        local y = circleY + radius * math.sin(angle)
        table.insert(arc, {x, y})
    end
    
    -- Tạo các điểm cho vòng cung trong (theo thứ tự ngược lại)
    for i = segments, 0, -1 do
        local angle = startAngle + i * angleStep
        local x = circleX + innerRadius * math.cos(angle)
        local y = circleY + innerRadius * math.sin(angle)
        table.insert(arc, {x, y})
    end
    
    -- Đóng đường dẫn
    table.insert(arc, {arc[1][1], arc[1][2]})
end

function Update()
    -- Cập nhật giá trị pin
    local measure = SKIN:GetMeasure('MeasureBattery')
    if measure then
        batteryPercent = tonumber(measure:GetValue()) / 100
    else
        batteryPercent = 0.5  -- Giá trị mặc định nếu không lấy được
    end
    
    -- Tính toán góc kết thúc dựa trên phần trăm pin
    startAngle = math.rad(-90)
    endAngle = startAngle + math.rad(360 * batteryPercent)
    
    -- Tạo hình dạng vòng cung dựa trên phần trăm pin
    for i = #arcProgress, 1, -1 do
        table.remove(arcProgress, i)
    end
    
    local segments = math.max(10, math.floor(180 * batteryPercent))
    local angleStep = (endAngle - startAngle) / segments
    
    -- Vòng cung ngoài
    for i = 0, segments do
        local angle = startAngle + i * angleStep
        local x = circleX + radius * math.cos(angle)
        local y = circleY + radius * math.sin(angle)
        table.insert(arcProgress, {x, y})
    end
    
    -- Vòng cung trong (theo thứ tự ngược lại)
    for i = segments, 0, -1 do
        local angle = startAngle + i * angleStep
        local x = circleX + innerRadius * math.cos(angle)
        local y = circleY + innerRadius * math.sin(angle)
        table.insert(arcProgress, {x, y})
    end
    
    -- Đóng đường dẫn
    if #arcProgress > 0 then
        table.insert(arcProgress, {arcProgress[1][1], arcProgress[1][2]})
    end
end

function Draw()
    -- Vẽ nền vòng cung
    if #arc > 2 then
        SKIN:DrawLines(arc, 1, 1, circleBGColor)
    end
    
    -- Vẽ phần trăm pin
    if batteryPercent > 0 and #arcProgress > 2 then
        SKIN:DrawLines(arcProgress, 1, 1, circleColor)
    end
end
