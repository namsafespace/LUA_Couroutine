-- Q14: Kenya Railways Disruption Management
-- CCS2105 - Lua Coroutines

local trains = {
    {
        id = "Train 1",
        stations = {"Nairobi", "Athi River", "Emali", "Kisumu"},
        current = 1
    },

    {
        id = "Train 2",
        stations = {"Nairobi", "Limuru", "Naivasha", "Nakuru"},
        current = 1
    },

    {
        id = "Train 3",
        stations = {"Nairobi", "Athi River", "Makindu", "Mombasa"},
        current = 1
    }
}

-- Station availability.
-- Stations not listed here are assumed to be available.
local stationAvailable = {
    ["Emali"] = false
}

-- Create a coroutine for each train.
local function createTrain(train)
    return coroutine.create(function()

        while train.current < #train.stations do

            local nextStation =
                train.stations[train.current + 1]

            -- Check whether the next station is unavailable.
            if stationAvailable[nextStation] == false then

                print(
                    train.id
                    .. " waiting before "
                    .. nextStation
                    .. " because the station is unavailable."
                )

                coroutine.yield(
                    "waiting",
                    nextStation
                )

            else

                train.current =
                    train.current + 1

                print(
                    train.id
                    .. " reached "
                    .. train.stations[train.current]
                )

                coroutine.yield(
                    "arrived",
                    train.stations[train.current]
                )
            end
        end

        print(
            train.id
            .. " journey completed."
        )
    end)
end

-- Create one independent coroutine for each train.
for _, train in ipairs(trains) do
    train.coroutine = createTrain(train)
end

-- Cooperative railway scheduler.
local cycle = 0

while true do

    cycle = cycle + 1

    print(
        "\n========== Railway Cycle "
        .. cycle
        .. " =========="
    )

    local activeTrains = 0

    for _, train in ipairs(trains) do

        local co = train.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then

            activeTrains = activeTrains + 1

            print(
                "\nScheduler resumes "
                .. train.id
            )

            local success, status, station =
                coroutine.resume(co)

            if success then

                print(
                    train.id
                    .. " status: "
                    .. tostring(status)
                    .. " - "
                    .. tostring(station)
                )

            else

                print(
                    train.id
                    .. " error: "
                    .. tostring(status)
                )
            end
        end
    end

    -- Make Emali available after Cycle 2.
    if cycle == 2 then

        stationAvailable["Emali"] = true

        print(
            "\nEmali station is now available."
        )
    end

    -- Stop when every train has completed.
    if activeTrains == 0 then
        break
    end

    -- Safety limit prevents an infinite scheduler loop.
    if cycle >= 10 then

        print(
            "\nScheduler stopped after safety limit."
        )

        break
    end
end

print(
    "\n========== Train Journeys Complete =========="
)

for _, train in ipairs(trains) do

    print(
        train.id
        .. " final station: "
        .. train.stations[train.current]
    )
end