-- Q19: Fair Scheduling of Digital Government Services
-- CCS2105 - Lua Coroutines

local services = {
    {
        name = "Birth Certificates",
        queue = 5,
        waiting = 0,
        processed = 0
    },

    {
        name = "Passport Appointments",
        queue = 20,
        waiting = 0,
        processed = 0
    },

    {
        name = "Business Registrations",
        queue = 8,
        waiting = 0,
        processed = 0
    },

    {
        name = "Driving Licence Renewals",
        queue = 4,
        waiting = 0,
        processed = 0
    }
}


-- Create one independent coroutine for each service.
local function createService(service)

    return coroutine.create(function()

        while service.queue > 0 do

            -- Process one request.
            service.queue =
                service.queue - 1

            service.processed =
                service.processed + 1

            print(
                service.name
                .. ": Processing request. "
                .. "Remaining queue = "
                .. service.queue
            )

            -- Yield after one unit of work.
            coroutine.yield(
                service.queue,
                service.processed
            )
        end

        print(
            service.name
            .. ": Queue completed."
        )
    end)
end


-- Create a coroutine for every government service.
for _, service in ipairs(services) do

    service.coroutine =
        createService(service)

end


-- Fair priority scheduler.
local active = true
local cycle = 0


while active do

    active = false
    cycle = cycle + 1

    print(
        "\n========== Service Cycle "
        .. cycle
        .. " =========="
    )


    -- Increase waiting time for all active services.
    for _, service in ipairs(services) do

        if coroutine.status(service.coroutine)
            ~= "dead" then

            service.waiting =
                service.waiting + 1
        end
    end


    -- Find the service with the highest priority score.
    local selected = nil
    local highestScore = -1


    for _, service in ipairs(services) do

        if coroutine.status(service.coroutine)
            ~= "dead" then

            active = true

            -- Demand + waiting time.
            -- Waiting time prevents starvation.
            local score =
                service.queue
                + (service.waiting * 3)

            if score > highestScore then

                highestScore = score
                selected = service

            end
        end
    end


    -- Resume the selected service.
    if selected ~= nil then

        print(
            "\nScheduler selected: "
            .. selected.name
            .. " with priority "
            .. highestScore
        )


        local success, queue, processed =
            coroutine.resume(
                selected.coroutine
            )


        if success then

            -- Check whether the coroutine has finished.
            if coroutine.status(selected.coroutine)
                == "dead" then

                print(
                    selected.name
                    .. " completed and coroutine removed."
                )

            else

                print(
                    selected.name
                    .. " yielded."
                )

                print(
                    "Queue: "
                    .. tostring(queue)
                    .. ", Processed: "
                    .. tostring(processed)
                )

            end

        else

            print(
                selected.name
                .. " error: "
                .. tostring(queue)
            )

        end


        -- Reset waiting time after service.
        selected.waiting = 0
    end
end


-- Final government service summary.
print(
    "\n========== All Government Services Completed =========="
)

for _, service in ipairs(services) do

    print(
        service.name
        .. " → Processed: "
        .. service.processed
        .. ", Remaining queue: "
        .. service.queue
        .. ", Coroutine: "
        .. coroutine.status(service.coroutine)
    )
end