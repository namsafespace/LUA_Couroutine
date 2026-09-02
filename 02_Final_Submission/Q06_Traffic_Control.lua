-- Q06: Adaptive Nairobi Traffic Control
-- CCS2105 - Lua Coroutines

local roads = {
    {
        name = "Thika Road",
        queue = 20,
        waiting = 0
    },

    {
        name = "Mombasa Road",
        queue = 12,
        waiting = 0
    },

    {
        name = "Ngong Road",
        queue = 6,
        waiting = 0
    },

    {
        name = "Waiyaki Way",
        queue = 15,
        waiting = 0
    }
}


-- Create a coroutine for each road.
local function createRoad(road)
    return coroutine.create(function()

        while road.queue > 0 do

            print(
                road.name
                .. ": Queue = "
                .. road.queue
                .. ", Waiting = "
                .. road.waiting
            )


            -- Give the road a green-light turn.
            local vehicles = math.min(5, road.queue)

            road.queue = road.queue - vehicles
            road.waiting = 0

            print(
                road.name
                .. " receives green light for "
                .. vehicles
                .. " vehicles."
            )


            -- Yield after each traffic-control decision.
            coroutine.yield(
                road.queue,
                road.waiting
            )
        end


        print(
            road.name
            .. ": Traffic cleared."
        )
    end)
end


-- Create one independent coroutine for each road.
for _, road in ipairs(roads) do
    road.coroutine = createRoad(road)
end


-- Priority-based cooperative scheduler.
local completed = false
local cycle = 0

while not completed do
    completed = true
    cycle = cycle + 1

    print(
        "\n========== Traffic Cycle "
        .. cycle
        .. " =========="
    )


    -- Increase waiting time for active roads.
    for _, road in ipairs(roads) do
        if coroutine.status(road.coroutine) ~= "dead" then
            road.waiting = road.waiting + 1
        end
    end


    -- Select the road with the highest priority.
    local selectedRoad = nil
    local highestPriority = -1

    for _, road in ipairs(roads) do

        if coroutine.status(road.coroutine) ~= "dead" then

            completed = false

            -- Congestion is the main factor.
            -- Waiting time adds fairness.
            local priority =
                road.queue + (road.waiting * 3)

            if priority > highestPriority then
                highestPriority = priority
                selectedRoad = road
            end
        end
    end


    -- Resume the selected road coroutine.
    if selectedRoad ~= nil then

        print(
            "\nScheduler selects "
            .. selectedRoad.name
            .. " with priority "
            .. highestPriority
        )


        local success, queue, waiting =
            coroutine.resume(
                selectedRoad.coroutine
            )


        if success then
            print(
                selectedRoad.name
                .. " yielded. Queue = "
                .. tostring(queue)
                .. ", Waiting = "
                .. tostring(waiting)
            )
        else
            print(
                selectedRoad.name
                .. " error: "
                .. tostring(queue)
            )
        end
    end
end


print(
    "\n========== Traffic Control Finished =========="
)


for _, road in ipairs(roads) do
    print(
        road.name
        .. " → Remaining queue: "
        .. road.queue
    )
end