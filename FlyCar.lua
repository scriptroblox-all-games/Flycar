require 'lib.sampfuncs'
require 'lib.moonloader'

local sampev = require 'lib.samp.events'

local ppc = {}
local scripts = false
local cars = 0

function getMoveSpeed(heading, speed)
    moveSpeed = {x = math.sin(-math.rad(heading)) * (speed), y = math.cos(-math.rad(heading)) * (speed), z = 0.25} 
    return moveSpeed
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    repeat wait(0) until isSampAvailable()
    while true do wait(0)
        if not scripts and isKeyDown(VK_1) and isKeyJustPressed(VK_2) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() then 
            sampAddChatMessage('[{00DD00}FlyCar{FFFFFF}] - {FFC000}Активирован', -1)
            scripts = not scripts
            ppc = {}
        elseif scripts and isKeyJustPressed(VK_3) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() then 
            sampAddChatMessage('[{00DD00}FlyCar{FFFFFF}] - {FFC000}Де-активирован', -1)
            cars = 0
            scripts = not scripts
            ppc = {}
        end
        if scripts and isCharInAnyCar(PLAYER_PED) then
            local veh = getCarCharIsUsing(PLAYER_PED)
            if getDriverOfCar(veh) == -1 then pcall(sampForcePassengerSyncSeatId, ppc[1], ppc[2]) pcall(sampForceUnoccupiedSyncSeatId, ppc[1], ppc[2]) else pcall(sampForceVehicleSync, ppc[1]) end
            local speed = getCarSpeed(veh)
            setCarHeavy(veh, false)
            setCarProofs(veh,true,true,true,true,true)
            local var_1, var_2, var_3, var_4 = getPositionOfAnalogueSticks(0)
            local var_1 = var_1 / -64.0
            local var_2 = var_2 / 64.0
            setCarRotationVelocity(veh, var_2, 0.0, var_1)
            if isKeyDown(VK_W) then
                if speed <= 200.0 then 
                    cars = cars + 0.4
                end
            elseif isKeyDown(VK_S) then
                if cars >= 0.0 then 
                    cars = cars - 0.3
                else 
                    cars = 0.0
                end
            end
            if isKeyDown(VK_S) and isKeyDown(VK_SPACE) then 
                cars = 0
                setCarRotationVelocity(veh, 0.0, 0.0, 0,0)
                setCarRoll(veh, 0.0)
            end
            setCarForwardSpeed(veh,cars)
            printStringNow('~R~S ~G~+ ~R~SPACE ~G~= ~R~FAST STOP')
        elseif not isCharInAnyCar(PLAYER_PED) and scripts then 
            sampAddChatMessage('[{00DD00}FlyCar{FFFFFF}] - {FFC000}Де-активирован', -1)
            scripts = not scripts
            ppc = {}
        end
    end
end

function sampev.onSendPassengerSync(data)
    if scripts then 
        ppc = {data.vehicleId, data.seatId}
    end
end

function sampev.onSendUnoccupiedSync(data)
    if scripts then 
        local _, veh = sampGetCarHandleBySampVehicleId(data.vehicleId)
        local heading = getCarHeading(veh)
        data.moveSpeed = getMoveSpeed(heading, 0.200)
        return data    
    end
end

function sampev.onSendVehicleSync(data)
    if scripts then 
        ppc = {data.vehicleId}
        local _, veh = sampGetCarHandleBySampVehicleId(data.vehicleId)
        local heading = getCarHeading(veh)
        data.moveSpeed = getMoveSpeed(heading, 1.250)
        return data  
    end
end
