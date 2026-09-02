-- SPDX-FileCopyrightText: 2026 Samuel Hulme <https://github.com/samuelh2005>
-- SPDX-License-Identifier: MPL-2.0

--[[ CC Web Browser v26

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.
--]]


local defaultTheme = {
    ["body"] = {
        ["text-color"] = "black",
        ["background-color"] = "white"
    }
}

local w, h = term.getSize()
local currentTheme = defaultTheme

local url = "about:blank"

local contentWindow = window.create(term.current(), 1, 2, w - 1, h - 2)
local screenContent = {}

local loading = false
local logs = {}

-- Scrolling state
local scrollOffset = 0
local contentLines = {} -- flattened, pre-wrapped lines: { text = ... }

-- Scrollbar hit-testing state, recomputed every render
local scrollbarVisible = false
local scrollbarTrackHeight = 0
local scrollbarThumbHeight = 0
local scrollbarThumbPos = 0
local draggingScrollbar = false
local dragGrabOffset = 0


local function checkVal(value, arg_type, default)
    if value == nil then
        return default, false, "Value is nil"
    end

    if arg_type and type(value) ~= arg_type then
        return default, false, "Expected type " .. arg_type .. ", got " .. type(value)
    end

    return value, true, nil
end

local function fillLine(y, bg, fg, text)
    term.setBackgroundColour(bg)
    term.setTextColour(fg)
    term.setCursorPos(1, y)
    term.clearLine()

    if text then
        term.write(text)
    end
end

local function consoleLog(status, msg)
    table.insert(logs, {
        ["status"] = status,
        ["message"] = msg
    })
end

local function startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

local function wrapText(text, width)
    local lines = {}
    local currentLine = ""
    local currentWidth = 0

    for word in text:gmatch("%S+") do
        local wordWidth = #word

        if currentWidth + wordWidth + 1 > width then
            table.insert(lines, currentLine)
            currentLine = word .. " "
            currentWidth = wordWidth + 1
        else
            currentLine = currentLine .. word .. " "
            currentWidth = currentWidth + wordWidth + 1
        end
    end

    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end

    return lines
end

local function buildContentLines()
    local lines = {}
    local width = select(1, contentWindow.getSize())

    if #screenContent == 0 and #logs > 0 then
        for _, err in ipairs(logs) do
            local wrapped = wrapText("[" .. err["status"] .. "]: " .. err["message"], width)
            for _, l in ipairs(wrapped) do
                table.insert(lines, { text = l })
            end
        end
    else
        for _, element in ipairs(screenContent) do
            if element["type"] == "text" then
                local wrapped = wrapText(element["text"], width)
                for _, l in ipairs(wrapped) do
                    table.insert(lines, { text = l })
                end
            end
        end
    end

    return lines
end

local function maxScroll()
    local _, ch = contentWindow.getSize()
    return math.max(0, #contentLines - ch)
end

local function clampScroll()
    local max = maxScroll()
    if scrollOffset < 0 then
        scrollOffset = 0
    elseif scrollOffset > max then
        scrollOffset = max
    end
end

local function refreshContentLines()
    contentLines = buildContentLines()
    clampScroll()
end

local function preparePage(content)
    local json, err = textutils.unserialiseJSON(content)
    if not json then
        consoleLog("error", "Failed to parse JSON: " .. err)
        loading = false
        return
    end

    -- local properties, ok1, err1 = checkVal(json["properties"], "table", {})

    -- if not ok1 then
    --     currErr = err1
    -- end

    -- local assets, ok2, err2 = checkVal(json["assets"], "table", {})
    -- if not ok2 then
    --     currErr = err2
    -- end

    local body, ok3, err3 = checkVal(json["body"], "table", {})
    if not ok3 then
        consoleLog("error", "Failed to check body: " .. err3)
        return false
    end

    screenContent = {}

    for _, element in ipairs(body) do
        local elementType, ok4, err4 = checkVal(element["type"], "string", nil)

        if not ok4 then
            consoleLog("error", "Failed to check element type: " .. err4)
        elseif elementType == "text" then
            local text, ok5, err5 = checkVal(element["text"], "string", "")

            if not ok5 then
                consoleLog("error", "Failed to check text element: " .. err5)
            else
                table.insert(screenContent, {
                    ["type"] = "text",
                    ["text"] = text
                })
            end
        end
    end

    loading = false
end

local function renderScrollbar()
    local cw, ch = contentWindow.getSize()
    local x = cw + 1 -- the column reserved to the right of contentWindow
    local total = #contentLines

    scrollbarTrackHeight = ch

    if total <= ch then
        scrollbarVisible = false
        term.setBackgroundColour(colors.white)
        for row = 0, ch - 1 do
            term.setCursorPos(x, 2 + row)
            term.write(" ")
        end
        return
    end

    scrollbarVisible = true
    scrollbarThumbHeight = math.max(1, math.floor(ch * ch / total))

    local travel = ch - scrollbarThumbHeight
    local max = maxScroll()
    scrollbarThumbPos = 0
    if max > 0 then
        scrollbarThumbPos = math.floor(travel * scrollOffset / max + 0.5)
    end

    for row = 0, ch - 1 do
        term.setCursorPos(x, 2 + row)
        if row >= scrollbarThumbPos and row < scrollbarThumbPos + scrollbarThumbHeight then
            term.setBackgroundColour(colors.gray)
        else
            term.setBackgroundColour(colors.lightGray)
        end
        term.write(" ")
    end
end

local function renderContent()
    refreshContentLines()

    contentWindow.setBackgroundColour(colors.white)
    contentWindow.setTextColour(colors.black)
    contentWindow.setCursorPos(1, 1)
    contentWindow.clear()

    local cw, ch = contentWindow.getSize()
    local errorMode = (#screenContent == 0 and #logs > 0)

    for row = 1, ch do
        local line = contentLines[row + scrollOffset]
        if line then
            contentWindow.setCursorPos(1, row)
            contentWindow.setTextColour(errorMode and colors.red or colors.black)
            contentWindow.write(line.text)
        end
    end

    renderScrollbar()
end

local function renderChrome()
    term.setBackgroundColour(colors.white)
    term.setTextColour(colors.black)
    term.clear()

    -- Header
    fillLine(1, colors.lightGray, colors.black)

    term.setBackgroundColour(colors.gray)
    term.setTextColour(colors.white)
    term.setCursorPos(2, 1)
    term.write(url)

    -- Footer
    local status = "Ready"
    if loading then
        status = "Loading..."
    elseif #screenContent == 0 and #logs > 0 then
        status = "Error"
    end
    fillLine(h, colors.lightGray, colors.black, status)
end

local function editValue(currentValue, prompt)
    local dialogW = math.min(30, w - 4)
    local dialogH = 5
    local x = math.floor((w - dialogW) / 2) + 1
    local y = math.floor((h - dialogH) / 2) + 1

    term.setBackgroundColour(colors.gray)
    term.setTextColour(colors.white)

    for row = 0, dialogH - 1 do
        term.setCursorPos(x, y + row)
        term.write(string.rep(" ", dialogW))
    end

    term.setCursorPos(x + 2, y + 1)
    term.write(prompt)

    term.setCursorPos(x + 2, y + 2)
    local newValue = read()

    if newValue ~= "" then
        return newValue
    else
        return currentValue
    end
end

local function GET(sourceUrl)
    if startsWith(sourceUrl, "file://") then
        local fileName = shell.resolve(sourceUrl)

        if not fs.exists(fileName) then
            consoleLog("error", "File not found: " .. fileName)
            loading = false
            return
        end

        local file = fs.open(fileName, "r")
        if not file then
            consoleLog("error", "Failed to open file: " .. fileName)
            loading = false
            return
        end

        local content = file.readAll()
        file.close()

        if not content then
            consoleLog( "error", "Failed to read file: " .. fileName)
            loading = false
            return
        end

        return content
    elseif startsWith(sourceUrl, "http://") or startsWith(sourceUrl, "https://") then
        local request = http.get(sourceUrl)
        if not request then
            consoleLog("error", "Failed to make HTTP request to: " .. sourceUrl)
            loading = false
            return
        end

        local statusCode = request.getResponseCode()
        local headers = request.getResponseHeaders()
        local content = request.readAll()
        request.close()

        if statusCode ~= 200 then
            if not content then
                consoleLog("error", "HTTP request failed with status code: " .. statusCode)
            else
                consoleLog("error", content)
            end
            loading = false
            request.close()
            return
        end

        if not content then
            consoleLog("error", "Failed to read HTTP response from: " .. sourceUrl)
            loading = false
            return
        end

        return content, statusCode, headers
    end
end

renderChrome()
renderContent()

while true do
    local event, p1, p2, p3, p4, p5 = os.pullEvent()

    if event == "mouse_click" and p1 == 1 then
        local cw = select(1, contentWindow.getSize())

        if p3 == 1 and p2 >= 2 and p2 <= #url + 1 then
            url = editValue(url, "Enter URL:")
            logs = {}
            loading = true
            scrollOffset = 0
            local content = GET(url)
            if content then
                preparePage(content)
            end
        elseif scrollbarVisible and p2 == cw + 1 and p3 >= 2 and p3 <= 1 + scrollbarTrackHeight then
            local row = p3 - 2
            if row >= scrollbarThumbPos and row < scrollbarThumbPos + scrollbarThumbHeight then
                draggingScrollbar = true
                dragGrabOffset = row - scrollbarThumbPos
            else
                local travel = scrollbarTrackHeight - scrollbarThumbHeight
                local target = row - math.floor(scrollbarThumbHeight / 2)
                if travel > 0 then
                    scrollOffset = math.floor(maxScroll() * target / travel + 0.5)
                    clampScroll()
                end
            end
        end
    elseif event == "mouse_drag" and p1 == 1 and draggingScrollbar then
        local travel = scrollbarTrackHeight - scrollbarThumbHeight
        if travel > 0 then
            local row = p3 - 2 - dragGrabOffset
            scrollOffset = math.floor(maxScroll() * row / travel + 0.5)
            clampScroll()
        end
    elseif event == "mouse_up" then
        draggingScrollbar = false
    elseif event == "mouse_scroll" then
        scrollOffset = scrollOffset + p1 * 3
        clampScroll()
    elseif event == "key" then
        local ch = select(2, contentWindow.getSize())

        if p1 == keys.down then
            scrollOffset = scrollOffset + 1
        elseif p1 == keys.up then
            scrollOffset = scrollOffset - 1
        elseif p1 == keys.pageDown then
            scrollOffset = scrollOffset + ch
        elseif p1 == keys.pageUp then
            scrollOffset = scrollOffset - ch
        elseif p1 == keys.home then
            scrollOffset = 0
        elseif p1 == keys["end"] then
            scrollOffset = maxScroll()
        end
        clampScroll()
    elseif event == "term_resize" then
        w, h = term.getSize()
        contentWindow.reposition(1, 2, w - 1, h - 2)
        clampScroll()
    elseif event == "terminate" then
        break
    end

    renderChrome()
    renderContent()
end
