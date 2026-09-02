-- Q05: Kericho Tea Factory Production Pipeline
-- CCS2105 - Lua Coroutines

local function createBatch(batch)
    return coroutine.create(function()

        -- Receiving.
        print(batch.id .. ": Receiving")
        batch.stage = "Receiving"
        coroutine.yield(batch.id, batch.stage)


        -- Weighing.
        print(batch.id .. ": Weighing")
        batch.stage = "Weighing"
        coroutine.yield(batch.id, batch.stage)


        -- Withering.
        print(batch.id .. ": Withering")
        batch.stage = "Withering"
        coroutine.yield(batch.id, batch.stage)


        -- Drying.
        print(batch.id .. ": Drying")
        batch.stage = "Drying"
        coroutine.yield(batch.id, batch.stage)


        -- Quality inspection.
        print(batch.id .. ": Quality inspection")

        if not batch.quality_pass then
            print(
                batch.id
                .. ": Quality failed. Reprocessing required."
            )

            batch.stage = "Reprocessing"
            coroutine.yield(batch.id, batch.stage)

            -- Repeat drying after reprocessing.
            print(batch.id .. ": Drying after reprocessing")

            batch.stage = "Drying - Reprocessed"
            coroutine.yield(batch.id, batch.stage)
        end


        -- Grading.
        print(batch.id .. ": Grading")
        batch.stage = "Grading"
        coroutine.yield(batch.id, batch.stage)


        -- Packaging.
        print(batch.id .. ": Packaging")
        batch.stage = "Packaging"
        coroutine.yield(batch.id, batch.stage)


        batch.stage = "Completed"

        print(batch.id .. ": Production completed.")
    end)
end


-- Three tea batches.
local batches = {
    {
        id = "Batch 001",
        quality_pass = true,
        stage = "Not started"
    },

    {
        id = "Batch 002",
        quality_pass = false,
        stage = "Not started"
    },

    {
        id = "Batch 003",
        quality_pass = true,
        stage = "Not started"
    }
}


-- Create one independent coroutine for each batch.
for _, batch in ipairs(batches) do
    batch.coroutine = createBatch(batch)
end


-- Round-robin cooperative scheduler.
local completed = false
local cycle = 0

while not completed do
    completed = true
    cycle = cycle + 1

    print(
        "\n========== Production Cycle "
        .. cycle
        .. " =========="
    )

    for _, batch in ipairs(batches) do
        local co = batch.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then
            completed = false

            local success, id, stage =
                coroutine.resume(co)

            if success then
                print(
                    "Scheduler received: "
                    .. tostring(id)
                    .. " - "
                    .. tostring(stage)
                )
            else
                print(
                    batch.id
                    .. " error: "
                    .. tostring(id)
                )
            end
        end
    end
end


print("\n========== Final Batch States ==========")

for _, batch in ipairs(batches) do
    print(
        batch.id
        .. " → "
        .. batch.stage
    )
end