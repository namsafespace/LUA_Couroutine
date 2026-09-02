-- Q16: Producer-Consumer Food Distribution System
-- CCS2105 - Lua Coroutines

local producer = {
    consignments = {
        {id = "C001", size = 40},
        {id = "C002", size = 30},
        {id = "C003", size = 50},
        {id = "C004", size = 20}
    }
}


local markets = {
    {
        name = "Nairobi Market",
        capacity = 60,
        used = 0
    },

    {
        name = "Thika Market",
        capacity = 50,
        used = 0
    },

    {
        name = "Mombasa Market",
        capacity = 70,
        used = 0
    }
}


-- Create the producer coroutine.
local producerCoroutine = coroutine.create(function()

    for _, consignment in ipairs(producer.consignments) do

        print(
            "Producer generated "
            .. consignment.id
            .. " ("
            .. consignment.size
            .. " units)"
        )


        -- Yield each consignment to the scheduler.
        coroutine.yield(
            consignment.id,
            consignment.size
        )
    end
end)


-- Calculate the remaining capacity of a market.
local function remainingCapacity(market)
    return market.capacity - market.used
end


-- Cooperative allocation scheduler.
while coroutine.status(producerCoroutine) ~= "dead" do

    local success, id, size =
        coroutine.resume(producerCoroutine)


    if success and id ~= nil then

        print(
            "\nAllocating "
            .. id
            .. " containing "
            .. size
            .. " units."
        )


        -- Find a market with enough space.
        local selectedMarket = nil
        local largestSpace = -1

        for _, market in ipairs(markets) do

            local remaining =
                remainingCapacity(market)


            if remaining >= size
                and remaining > largestSpace then

                selectedMarket = market
                largestSpace = remaining
            end
        end


        -- Allocate the entire consignment if possible.
        if selectedMarket ~= nil then

            selectedMarket.used =
                selectedMarket.used + size


            print(
                id
                .. " allocated to "
                .. selectedMarket.name
                .. ". Remaining capacity: "
                .. remainingCapacity(selectedMarket)
            )


        else

            -- If no single market can hold it,
            -- distribute the consignment across markets.
            print(
                "No single market can fit "
                .. id
                .. " completely."
            )


            local remainingConsignment = size

            for _, market in ipairs(markets) do

                local space =
                    remainingCapacity(market)


                if space > 0
                    and remainingConsignment > 0 then

                    local allocation =
                        math.min(
                            space,
                            remainingConsignment
                        )


                    market.used =
                        market.used + allocation


                    remainingConsignment =
                        remainingConsignment - allocation


                    print(
                        id
                        .. ": "
                        .. allocation
                        .. " units allocated to "
                        .. market.name
                    )
                end
            end


            if remainingConsignment > 0 then

                print(
                    id
                    .. ": "
                    .. remainingConsignment
                    .. " units could not be allocated."
                )
            end
        end
    end
end


print(
    "\n========== Final Market Capacities =========="
)


for _, market in ipairs(markets) do

    print(
        market.name
        .. " → Used: "
        .. market.used
        .. ", Remaining: "
        .. remainingCapacity(market)
    )
end