-- Q15: Cooperative University Computing Scheduler
-- CCS2105 - Lua Coroutines

local jobs = {
    {
        name = "AI Model Simulation",
        steps = 8,
        priority = 3,
        completed_steps = 0
    },

    {
        name = "Student Results Processing",
        steps = 5,
        priority = 2,
        completed_steps = 0
    },

    {
        name = "Timetable Generation",
        steps = 6,
        priority = 2,
        completed_steps = 0
    },

    {
        name = "Library Indexing",
        steps = 4,
        priority = 1,
        completed_steps = 0
    }
}


-- Create a coroutine for each computing job.
local function createJob(job)
    return coroutine.create(function()

        while job.completed_steps < job.steps do

            job.completed_steps =
                job.completed_steps + 1


            print(
                job.name
                .. ": Processing step "
                .. job.completed_steps
                .. "/"
                .. job.steps
            )


            -- Yield after one unit of work.
            coroutine.yield(
                job.completed_steps
            )
        end


        print(
            job.name
            .. ": Job completed."
        )
    end)
end


-- Create one independent coroutine for each job.
for _, job in ipairs(jobs) do
    job.coroutine = createJob(job)
end


-- Priority-based cooperative scheduler.
local completed = false
local cycle = 0

while not completed do
    completed = true
    cycle = cycle + 1

    print(
        "\n========== Scheduler Cycle "
        .. cycle
        .. " =========="
    )


    -- Give each active job turns according to priority.
    for _, job in ipairs(jobs) do

        local co = job.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then

            completed = false

            -- Higher-priority jobs receive extra turns.
            local turns = job.priority

            for i = 1, turns do

                if coroutine.status(co) == "dead" then
                    break
                end


                print(
                    "\nRunning: "
                    .. job.name
                )


                local success, step =
                    coroutine.resume(co)


                if success then

                    print(
                        job.name
                        .. " completed step "
                        .. tostring(step)
                    )

                else

                    print(
                        job.name
                        .. " error: "
                        .. tostring(step)
                    )

                    break
                end
            end
        end
    end
end


print(
    "\n========== All Jobs Completed =========="
)