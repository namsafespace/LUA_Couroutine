-- Q18: Multi-Stage E-Commerce Fulfilment System
-- CCS2105 - Lua Coroutines

local orders = {
    {
        id = "ORD001",
        payment_ok = true,
        warehouse_ok = true,
        packaging_ok = true,
        courier_ok = true
    },

    {
        id = "ORD002",
        payment_ok = false,
        warehouse_ok = true,
        packaging_ok = true,
        courier_ok = true
    },

    {
        id = "ORD003",
        payment_ok = true,
        warehouse_ok = false,
        packaging_ok = true,
        courier_ok = true
    },

    {
        id = "ORD004",
        payment_ok = true,
        warehouse_ok = true,
        packaging_ok = false,
        courier_ok = true
    },

    {
        id = "ORD005",
        payment_ok = true,
        warehouse_ok = true,
        packaging_ok = true,
        courier_ok = true
    }
}


-- Create one independent coroutine for each order.
local function createOrder(order)

    return coroutine.create(function()

        -- Stage 1: Validation
        print(order.id .. ": Validation")

        order.stage = "Validation"

        coroutine.yield(
            order.id,
            order.stage
        )


        -- Stage 2: Payment
        print(order.id .. ": Payment")

        if not order.payment_ok then

            order.stage = "Failed - Payment"

            print(
                order.id
                .. " → "
                .. order.stage
            )

            return
        end

        order.stage = "Payment successful"

        coroutine.yield(
            order.id,
            order.stage
        )


        -- Stage 3: Warehouse allocation
        print(order.id .. ": Warehouse allocation")

        if not order.warehouse_ok then

            order.stage =
                "Cancelled - Warehouse unavailable"

            print(
                order.id
                .. " → "
                .. order.stage
            )

            return
        end

        order.stage = "Warehouse allocated"

        coroutine.yield(
            order.id,
            order.stage
        )


        -- Stage 4: Packaging
        print(order.id .. ": Packaging")

        if not order.packaging_ok then

            order.stage = "Failed - Packaging"

            print(
                order.id
                .. " → "
                .. order.stage
            )

            return
        end

        order.stage = "Packaged"

        coroutine.yield(
            order.id,
            order.stage
        )


        -- Stage 5: Courier assignment
        print(order.id .. ": Courier assignment")

        if not order.courier_ok then

            order.stage =
                "Cancelled - Courier unavailable"

            print(
                order.id
                .. " → "
                .. order.stage
            )

            return
        end

        order.stage = "Courier assigned"

        coroutine.yield(
            order.id,
            order.stage
        )


        -- Stage 6: Dispatch
        print(order.id .. ": Dispatch")

        order.stage = "Completed"

        coroutine.yield(
            order.id,
            order.stage
        )

    end)
end


-- Create a coroutine for every order.
for _, order in ipairs(orders) do

    order.coroutine =
        createOrder(order)

end


-- Round-robin cooperative scheduler.
local active = true
local cycle = 0

while active do

    active = false
    cycle = cycle + 1

    print(
        "\n========== Fulfilment Cycle "
        .. cycle
        .. " =========="
    )


    for _, order in ipairs(orders) do

        local co = order.coroutine


        -- Only resume active coroutines.
        if coroutine.status(co) ~= "dead" then

            active = true

            print(
                "\nScheduler resumes "
                .. order.id
            )


            local success, id, stage =
                coroutine.resume(co)


            if success then

                if id ~= nil then

                    print(
                        id
                        .. " → "
                        .. tostring(stage)
                    )

                end

            else

                order.stage =
                    "Failed - Coroutine Error"

                print(
                    order.id
                    .. " error: "
                    .. tostring(id)
                )

            end
        end
    end
end


-- Final order summary.
print(
    "\n========== FINAL ORDER SUMMARY =========="
)

for _, order in ipairs(orders) do

    local status

    if order.stage == "Completed" then

        status = "COMPLETED"

    elseif string.find(
        order.stage,
        "Cancelled"
    ) then

        status = "CANCELLED"

    elseif string.find(
        order.stage,
        "Failed"
    ) then

        status = "FAILED"

    else

        status = "INCOMPLETE"
    end


    print(
        order.id
        .. " → "
        .. status
        .. " ("
        .. order.stage
        .. ")"
    )
end