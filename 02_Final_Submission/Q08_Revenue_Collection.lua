-- Q08: Cooperative County Revenue Collection System
-- CCS2105 - Lua Coroutines

local requests = {
    {
        id = "Parking-001",
        service = "Parking Payments",
        network_failures = 0,
        max_retries = 2
    },

    {
        id = "Permit-001",
        service = "Business Permits",
        network_failures = 1,
        max_retries = 2
    },

    {
        id = "Land-001",
        service = "Land Rates",
        network_failures = 0,
        max_retries = 2
    }
}


-- Create a coroutine for each revenue request.
local function createRequest(request)
    return coroutine.create(function()

        -- Validation.
        print(request.id .. ": Validation")
        coroutine.yield("Validated")


        -- Payment verification.
        print(request.id .. ": Payment verification")

        if request.network_failures > 0 then
            request.network_failures =
                request.network_failures - 1

            request.retries = request.retries + 1

            print(
                request.id
                .. ": Temporary network failure."
            )

            coroutine.yield("Retry required")
            return
        end

        coroutine.yield("Payment verified")


        -- Receipt generation.
        print(request.id .. ": Receipt generation")
        coroutine.yield("Receipt generated")


        -- Completion.
        print(request.id .. ": Completed")
        coroutine.yield("Completed")
    end)
end


-- Create one independent coroutine for each request.
for _, request in ipairs(requests) do
    request.retries = 0
    request.coroutine = createRequest(request)
end


-- Cooperative revenue-processing scheduler.
local completed = false
local cycle = 0

while not completed do
    completed = true
    cycle = cycle + 1

    print(
        "\n========== Revenue Cycle "
        .. cycle
        .. " =========="
    )


    for _, request in ipairs(requests) do
        local co = request.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then
            completed = false

            if request.retries <= request.max_retries then

                print(
                    "\nScheduler resumes "
                    .. request.id
                )


                local success, status =
                    coroutine.resume(co)


                if success then
                    print(
                        request.id
                        .. " status: "
                        .. tostring(status)
                    )
                else
                    print(
                        request.id
                        .. " error: "
                        .. tostring(status)
                    )
                end

            else
                print(
                    request.id
                    .. ": Retry limit reached."
                )
            end
        end
    end
end


print(
    "\n========== Revenue Processing Complete =========="
)