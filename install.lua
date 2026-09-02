print("CC Web Browser Installer")
print("")
print("This Source Code Form is subject to the terms of the Mozilla Public")
print("License, v. 2.0. If a copy of the MPL was not distributed with this")
print("file, You can obtain one at https://mozilla.org/MPL/2.0/.")
print("")

local packages = {
    [1] = {
        name = "Latest Development",
        url = "https://github.com/samuelh2005/ccweb/raw/refs/heads/main/browser.lua",
        dest = "browser.lua"
    }
}

print("Choose a package to install...")
for i, pkg in ipairs(packages) do
    print(i .. ". " .. pkg.name)
end

local choice = nil
repeat
    local input = read()
    local num = tonumber(input)
    if num and num >= 1 and num <= #packages then
        choice = num
    else
        print("Invalid choice. Please enter a number between 1 and " .. #packages)
    end
until choice and packages[choice]

local selectedPackage = packages[choice]
print("Installing " .. selectedPackage.name .. "...")

local success, err = pcall(function()
    local response = http.get(selectedPackage.url)
    if not response then
        error("Failed to download package. Please check your internet connection.")
    end

    local content = response.readAll()
    response.close()

    local file = fs.open(selectedPackage.dest, "w")
    if not file then
        error("Failed to open file for writing: " .. selectedPackage.dest)
    end

    file.write(content)
    file.close()
end)

print("")
if success then
    print("Installation complete! You can now run the program by executing '" .. selectedPackage.dest .. "'")
else
    print("Installation failed: " .. err)
end
