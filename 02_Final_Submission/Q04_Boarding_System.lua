-- Q04: Kenya Airways Boarding Priority System
-- CCS2105 - Lua Coroutines

local categories = {
    {
        name = "Passengers Requiring Assistance",
        passengers = {"A1", "A2"},
        security_available = true
    },

    {
        name = "Business Class",
        passengers = {"B1", "B2", "B3"},
        security_available = true
    },

    {
        name = "Families with Young Children",
        passengers = {"F1", "F2"},
        security_available = false
    },

    {
        name = "Economy",
        passengers = {"E1", "E2", "E3"},
        security_available = true
    }
}


-- Create a coroutine for each boarding category.
local function createBoardingCategory(category)
    return coroutine.create(function()

        for _, passenger in ipairs(category.passengers) do

            -- Check security before boarding.
            if not category.security_available then
                print(
                    category.name
                    .. " is temporarily suspended."
                )

                coroutine.yield("suspended")
                return
            end

            print(
                category.name
                .. ": Passenger "
                .. passenger
                .. " boarded."
            )

            -- Yield after each boarding event.
            coroutine.yield("boarded")
        end

        print(
            category.name
            .. " has completed boarding."
        )
    end)
end


-- Create one independent coroutine for each category.
for _, category in ipairs(categories) do
    category.coroutine =
        createBoardingCategory(category)
end


-- Fair round-robin scheduler.
local completed = false
local cycle = 0

while not completed do
    completed = true
    cycle = cycle + 1

    print(
        "\n========== Boarding Cycle "
        .. cycle
        .. " =========="
    )

    for _, category in ipairs(categories) do
        local co = category.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then
            completed = false

            print(
                "\nScheduler checks: "
                .. category.name
            )

            local success, result =
                coroutine.resume(co)

            if success then
                print(
                    category.name
                    .. " status: "
                    .. tostring(result)
                )
            else
                print(
                    category.name
                    .. " error: "
                    .. tostring(result)
                )
            end
        end
    end

    -- Security becomes available after cycle 2.
    if cycle == 2 then
        categories[3].security_available = true

        print(
            "\nSecurity clearance restored for "
            .. categories[3].name
        )
    end
end


print("\n========== Boarding Complete ==========")