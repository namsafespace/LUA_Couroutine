-- Q10: Supermarket Checkout and Stock Consistency
-- CCS2105 - Lua Coroutines

-- Shared stock controlled by the scheduler.
local stock = {
    Milk = 5,
    Bread = 4,
    Sugar = 3
}


local checkouts = {
    {
        name = "Checkout 1",
        purchases = {
            {product = "Milk", quantity = 2},
            {product = "Bread", quantity = 1}
        }
    },

    {
        name = "Checkout 2",
        purchases = {
            {product = "Milk", quantity = 3},
            {product = "Sugar", quantity = 2}
        }
    },

    {
        name = "Checkout 3",
        purchases = {
            {product = "Bread", quantity = 3},
            {product = "Sugar", quantity = 2}
        }
    }
}


-- Create a coroutine for each checkout.
local function createCheckout(checkout)
    return coroutine.create(function()

        for _, purchase in ipairs(checkout.purchases) do

            print(
                checkout.name
                .. ": Scanning "
                .. purchase.quantity
                .. " "
                .. purchase.product
            )

            -- Yield after scanning every product.
            coroutine.yield(
                purchase.product,
                purchase.quantity
            )
        end

        print(
            checkout.name
            .. ": Checkout completed."
        )
    end)
end


-- Create one independent coroutine for each checkout.
for _, checkout in ipairs(checkouts) do
    checkout.coroutine = createCheckout(checkout)
end


-- Round-robin checkout scheduler.
local completed = false
local cycle = 0

while not completed do

    completed = true
    cycle = cycle + 1

    print(
        "\n========== Checkout Cycle "
        .. cycle
        .. " =========="
    )


    for _, checkout in ipairs(checkouts) do

        local co = checkout.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then

            completed = false

            local success, product, quantity =
                coroutine.resume(co)


            if success then

                -- Only process a purchase when
                -- the coroutine actually yielded data.
                if product ~= nil and quantity ~= nil then

                    print(
                        checkout.name
                        .. " requests "
                        .. quantity
                        .. " "
                        .. product
                    )


                    -- Check stock before updating it.
                    if stock[product] >= quantity then

                        stock[product] =
                            stock[product] - quantity

                        print(
                            "Purchase approved. Remaining "
                            .. product
                            .. " stock: "
                            .. stock[product]
                        )

                    else

                        print(
                            "Purchase rejected. Insufficient "
                            .. product
                            .. " stock."
                        )
                    end

                end

            else

                print(
                    checkout.name
                    .. " error: "
                    .. tostring(product)
                )
            end
        end
    end
end


print("\n========== Final Stock ==========")

for product, quantity in pairs(stock) do

    print(
        product
        .. ": "
        .. quantity
    )
end