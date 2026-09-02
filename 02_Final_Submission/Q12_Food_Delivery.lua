-- Q12: Nairobi Food Delivery Dispatcher
-- CCS2105 - Lua Coroutines

local riders = {
    {
        name = "Rider 1",
        workload = 0,
        coroutine = nil
    },

    {
        name = "Rider 2",
        workload = 0,
        coroutine = nil
    },

    {
        name = "Rider 3",
        workload = 0,
        coroutine = nil
    },

    {
        name = "Rider 4",
        workload = 0,
        coroutine = nil
    }
}


-- Create a coroutine for each rider.
local function createRider(rider)
    return coroutine.create(function()

        while true do

            -- Wait for an order assignment.
            local order = coroutine.yield("waiting")

            if order == nil then
                break
            end


            print(
                rider.name
                .. " received order "
                .. order.id
            )


            -- Wait for restaurant confirmation.
            while not order.ready do

                print(
                    rider.name
                    .. " waiting for restaurant confirmation "
                    .. "for order "
                    .. order.id
                )

                order.ready = coroutine.yield(
                    "waiting for restaurant"
                )
            end


            print(
                rider.name
                .. " collected order "
                .. order.id
                .. " from "
                .. order.location
            )


            print(
                rider.name
                .. " delivered order "
                .. order.id
            )


            rider.workload =
                rider.workload + 1


            coroutine.yield(
                "delivery completed"
            )
        end
    end)
end


-- Create one independent coroutine for each rider.
for _, rider in ipairs(riders) do
    rider.coroutine = createRider(rider)
end


local orders = {
    {
        id = "ORD001",
        location = "Westlands",
        preparation_time = 2,
        priority = 3,
        ready = true
    },

    {
        id = "ORD002",
        location = "Kilimani",
        preparation_time = 3,
        priority = 1,
        ready = false
    },

    {
        id = "ORD003",
        location = "CBD",
        preparation_time = 1,
        priority = 3,
        ready = true
    },

    {
        id = "ORD004",
        location = "Karen",
        preparation_time = 2,
        priority = 2,
        ready = true
    }
}


-- Start each rider coroutine.
for _, rider in ipairs(riders) do
    coroutine.resume(rider.coroutine)
end


-- Sort orders by priority.
table.sort(orders, function(a, b)
    return a.priority > b.priority
end)


-- Round-robin cooperative dispatcher.
print("========== Order Assignment ==========")

for _, order in ipairs(orders) do

    -- Select the rider with the smallest workload.
    local selectedRider = riders[1]

    for _, rider in ipairs(riders) do

        if rider.workload < selectedRider.workload then
            selectedRider = rider
        end
    end


    print(
        "\nAssigning "
        .. order.id
        .. " to "
        .. selectedRider.name
    )


    -- Send the order into the selected rider coroutine.
    local success, status =
        coroutine.resume(
            selectedRider.coroutine,
            order
        )


    if success then
        print(
            selectedRider.name
            .. " status: "
            .. tostring(status)
        )
    else
        print(
            selectedRider.name
            .. " error: "
            .. tostring(status)
        )
    end
end


-- Restaurant confirms delayed orders.
print(
    "\n========== Restaurant Confirmation =========="
)

for _, order in ipairs(orders) do

    if not order.ready then

        order.ready = true

        print(
            order.id
            .. " is now ready."
        )
    end
end


print(
    "\n========== Final Rider Workloads =========="
)

for _, rider in ipairs(riders) do

    print(
        rider.name
        .. " → Workload: "
        .. rider.workload
    )
end