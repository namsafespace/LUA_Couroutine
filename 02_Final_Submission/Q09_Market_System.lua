-- Q09: Agricultural Market Decision Support System
-- CCS2105 - Lua Coroutines

local markets = {
    {
        name = "Kitale",
        prices = {4300, 4400, 4600, 4700},
        history = {}
    },

    {
        name = "Eldoret",
        prices = {4200, 4500, 4550, 4600},
        history = {}
    },

    {
        name = "Nakuru",
        prices = {4100, 4300, 4400, 4450},
        history = {}
    },

    {
        name = "Kisumu",
        prices = {4400, 4450, 4550, 4600},
        history = {}
    },

    {
        name = "Nairobi",
        prices = {4000, 4200, 4300, 4400},
        history = {}
    }
}


-- Create a coroutine for each market.
local function createMarket(market)
    return coroutine.create(function()

        for round, price in ipairs(market.prices) do
            market.current_price = price
            market.round = round

            coroutine.yield(
                market.name,
                price,
                round
            )
        end
    end)
end


-- Create one independent coroutine for each market.
for _, market in ipairs(markets) do
    market.coroutine = createMarket(market)
end


-- Market monitoring scheduler.
local selectedMarket = nil
local round = 0

while selectedMarket == nil do
    round = round + 1

    print(
        "\n========== Market Round "
        .. round
        .. " =========="
    )

    local activeMarkets = false

    for _, market in ipairs(markets) do
        local co = market.coroutine

        if coroutine.status(co) ~= "dead" then
            activeMarkets = true

            local success, name, price, currentRound =
                coroutine.resume(co)

            if success then
                table.insert(
                    market.history,
                    price
                )

                print(
                    name
                    .. ": KSh "
                    .. price
                )


                -- Check selling condition.
                local history = market.history
                local count = #history

                if count >= 3
                    and history[count] > 4500
                    and history[count] > history[count - 1]
                    and history[count - 1] > history[count - 2] then

                    selectedMarket = market
                    break
                end
            else
                print(
                    market.name
                    .. " error: "
                    .. tostring(name)
                )
            end
        end
    end

    if not activeMarkets then
        break
    end
end


-- Display final market decision.
if selectedMarket ~= nil then
    print(
        "\nSELL at "
        .. selectedMarket.name
        .. " - KSh "
        .. selectedMarket.current_price
    )


    -- Stop unnecessary market execution.
    for _, market in ipairs(markets) do
        if market ~= selectedMarket
            and coroutine.status(market.coroutine) ~= "dead" then

            print(
                "Stopping unnecessary execution for "
                .. market.name
            )
        end
    end

else
    print(
        "\nNo market satisfied the selling condition."
    )
end