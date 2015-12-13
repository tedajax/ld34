local _print = print
local json = require 'json'
local console = require 'console.console'
Tween = require 'tween'
require 'camera'
require 'imagebank'
require 'game'

function love.load()
    Defaults = json.load("defaults.json")

    local consoleFont = Defaults.console_font
    Console = console.new(consoleFont, love.graphics.getWidth(), 400, 4, function() end)
    console_register_commands(Console)
    Console:print_intro(Defaults.game.name, Defaults.game.version)

    GameCamera = Camera()

    Images = ImageBank()

    Images:load("assets/images/ground.png", "ground")
    Images:load("assets/images/flower.png", "flower")
    Images:load("assets/images/water_top.png", "water_top")
    Images:load("assets/images/water.png", "water")
    Images:load("assets/images/daynight.png", "daynight")
    Images:load("assets/images/daynightcolors.png", "daynightcolors")

    Timescale = 1

    GrowthGame = Game()
    GrowthGame:start()
end

function love.keypressed(keycode)
    if keycode == "escape" then
        love.event.quit()
    elseif keycode == "`" then
        Console:focus()
    end

    if Console:has_focus() then
        return
    end
end

function love.mousepressed(x, y, button)
    GrowthGame:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    GrowthGame:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    GrowthGame:mousemoved(x, y, dx, dy)
end

function love.update(dt)
    Tween.update(dt * Timescale)

    GrowthGame:update(dt)

    Console:update(dt)
end

function love.draw()
    GrowthGame:render()

    GrowthGame:render_debug()

    love.graphics.setColor(255, 255, 0)
    love.graphics.print("FPS: "..love.timer.getFPS(), 5, love.graphics.getHeight() - 25)

    Console:render()
end

local function command_set_font(p1, p2)
    if p2 == nil and tonumber(p1) ~= nil then
        Console:set_font({ ptsize = tonumber(p1) })
    elseif p2 ~= nil then
        Console:set_font({ filename = p1, ptsize = tonumber(p2) })
    else
        perror("Unable to parse font parameters.")
    end
end

local function command_display_commands()
    print("-------------------------------------------------------------------------------------------------------------------------------")
    print("Comands are executed as the name of the command followed by whitespace delimited parameters (e.g.):")
    print("> help")
    print("> clear")
    print("> gravity 1000")
    print("> font assets/fonts/VeraMono.ttf 18")
    print("> font 12")
    print(" ")
    print("A list of available commands follows:")
    for k, v in pairs(Console.commands) do
        if k ~= "commands" then
            local s = k
            if v[2] ~= nil then
                s = s.." "..v[2]
            end
            print(s)
        end
    end
    print("-------------------------------------------------------------------------------------------------------------------------------")
end

local function command_display_help()
    print("-------------------------------------------------------------------------------------------------------------------------------")
    print("Arbitrary Lua can be executed within this console.")
    print("> print(\"hello, world\")")
    print("hello, world")
    print(" ")
    print("This is quite useful for debugging as you can also directly manipulate variables.")
    print("> myvar = 5")
    print("> print(myvar)")
    print("5")
    print(" ")
    print("For ease of use there are also commands available that don't require function call syntax.")
    print("For a list of available commands use the 'commands' command")
    print("> commands")
    print("...")
    print(" ")
    print("You can also cycle through history with the up/down arrow keys.")
    print("Using the <tab> key will cycle through autocomplete with varying degrees of success.")
    print("-------------------------------------------------------------------------------------------------------------------------------")
end

local function command_memory()
    print("Memory in usage by Lua:")
    local count = collectgarbage("count")
    print(string.format("%.2fkb", count))
end

quit = love.event.quit
exit = love.event.quit
print = function(...) _print(...); if Console then Console:print(...) end end
perror = function(...) _print(...); Console:error(...) end
help = command_display_help

function console_register_commands(console)
    console.commands = {
        help        = { command_display_help, "-- Display help message." },
        commands    = { command_display_commands, "-- Displays a list of commands." },
        quit        = { love.event.quit, "-- Quit game.." },
        exit        = { love.event.quit, "-- Exit game." },
        clear       = { function() Console:clear() end, "-- Clear the console." },
        font        = { command_set_font, "<filename> ptsize -- Set console font.  Don't provide filename to just change size." },
        memory      = { command_memory, "memory -- display memory usage information." },
        timescale   = { function(ts) Timescale = ts or 1 end, "timescale <number> -- set timescale to value or reset if none provided." },
    }
end