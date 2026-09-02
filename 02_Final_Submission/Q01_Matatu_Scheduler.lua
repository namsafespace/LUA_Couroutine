-- Q01: Intelligent Matatu Terminus Scheduler
-- CCS2105 - Lua Coroutines

local routes = {
    Rongai = {
        passengers = 0,
        waiting_cycles = 0
    },

    Thika = {
        passengers = 0,
        waiting_cycles = 0
    },

    Ngong = {
        passengers = 0,
        waiting_cycles = 0
    },

    Kitengela = {
        passengers = 0,
        waiting_cycles = 0
    }
}

-- Create a coroutine for each route.
local function createRoute(name, passengerList)
    return coroutine.create(function()
        for _, passengers in ipairs(passengerList) do

            -- Boarding event.
            routes[name].passengers =
                routes[name].passengers + passengers

            print(name .. ": " .. passengers .. " passenger(s) boarded.")
            print(name .. " total passengers: "
                .. routes[name].passengers)

            -- Yield after every boarding event.
            coroutine.yield("boarding")

            -- Check departure rules.
            if routes[name].passengers >= 8 then

                print(name .. " departs with "
                    .. routes[name].passengers .. " passengers.")

                routes[name].passengers = 0
                routes[name].waiting_cycles = 0

                -- Yield after scheduling decision.
                coroutine.yield("departed")

            elseif routes[name].waiting_cycles > 3
                and routes[name].passengers >= 5 then

                print(name .. " has waited more than 3 cycles "
                    .. "and departs with "
                    .. routes[name].passengers .. " passengers.")

                routes[name].passengers = 0
                routes[name].waiting_cycles = 0

                -- Yield after scheduling decision.
                coroutine.yield("departed")

            else
                print(name .. " remains at the terminus.")

                -- Yield after scheduling decision.
                coroutine.yield("waiting")
            end
        end

        print(name .. " route has no more boarding events.")
    end)
end

-- Passenger arrivals for each route.
local routeData = {
    Rongai = {3, 2, 3},
    Thika = {2, 2, 1, 1},
    Ngong = {4, 2, 2},
    Kitengela = {2, 2, 2, 1}
}

-- Create one independent coroutine for each route.
local tasks = {
    {
        name = "Rongai",
        coroutine = createRoute("Rongai", routeData.Rongai)
    },

    {
        name = "Thika",
        coroutine = createRoute("Thika", routeData.Thika)
    },

    {
        name = "Ngong",
        coroutine = createRoute("Ngong", routeData.Ngong)
    },

    {
        name = "Kitengela",
        coroutine = createRoute("Kitengela", routeData.Kitengela)
    }
}

-- Round-robin cooperative scheduler.
local completed = false
local cycle = 0

while not completed do
    completed = true
    cycle = cycle + 1

    print("\n========== Scheduling Cycle "
        .. cycle .. " ==========")

    for _, task in ipairs(tasks) do
        local co = task.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then
            completed = false

            -- Increase waiting time for active routes.
            routes[task.name].waiting_cycles =
                routes[task.name].waiting_cycles + 1

            print("\nScheduler resumes " .. task.name)

            local success, result = coroutine.resume(co)

            if success then
                print(
                    task.name
                    .. " yielded: "
                    .. tostring(result)
                )
            else
                print(
                    task.name
                    .. " error: "
                    .. tostring(result)
                )
            end
        end
    end
end

print("\n========== Scheduler Finished ==========")

for name, data in pairs(routes) do
    print(
        name
        .. " - Passengers: "
        .. data.passengers
        .. ", Waiting cycles: "
        .. data.waiting_cycles
    )
end