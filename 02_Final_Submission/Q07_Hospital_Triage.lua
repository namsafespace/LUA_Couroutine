-- Q07: County Hospital Emergency Triage
-- CCS2105 - Lua Coroutines

local patients = {
    {
        name = "Patient A",
        type = "routine",
        priority = 1,
        waiting = 0
    },

    {
        name = "Patient B",
        type = "urgent",
        priority = 2,
        waiting = 0
    },

    {
        name = "Patient C",
        type = "critical",
        priority = 3,
        waiting = 0
    },

    {
        name = "Patient D",
        type = "routine",
        priority = 1,
        waiting = 0
    }
}


-- Create a coroutine for each patient.
local function createPatient(patient)
    return coroutine.create(function()

        -- Registration.
        print(patient.name .. ": Registration")
        coroutine.yield("Registration")


        -- Triage.
        print(patient.name .. ": Triage")
        coroutine.yield("Triage")


        -- Consultation.
        print(patient.name .. ": Consultation")
        coroutine.yield("Consultation")


        -- Discharge.
        print(patient.name .. ": Discharge")
        coroutine.yield("Discharge")


        print(patient.name .. ": Treatment completed.")
    end)
end


-- Create one independent coroutine for each patient.
for _, patient in ipairs(patients) do
    patient.coroutine = createPatient(patient)
end


-- Priority-based cooperative scheduler.
local completed = false
local cycle = 0

while not completed do
    completed = true
    cycle = cycle + 1

    print(
        "\n========== Hospital Cycle "
        .. cycle
        .. " =========="
    )


    -- Increase waiting time for active patients.
    for _, patient in ipairs(patients) do
        if coroutine.status(patient.coroutine) ~= "dead" then
            patient.waiting = patient.waiting + 1
        end
    end


    -- Select patient using priority and aging.
    local selected = nil
    local highestScore = -1

    for _, patient in ipairs(patients) do

        if coroutine.status(patient.coroutine) ~= "dead" then

            completed = false

            -- Priority is the main factor.
            -- Waiting time prevents starvation.
            local score =
                (patient.priority * 10)
                + patient.waiting

            if score > highestScore then
                highestScore = score
                selected = patient
            end
        end
    end


    -- Resume the highest-priority patient.
    if selected ~= nil then

        print(
            "Scheduler selects "
            .. selected.name
            .. " ("
            .. selected.type
            .. ")"
        )


        local success, stage =
            coroutine.resume(
                selected.coroutine
            )


        if success then
            print(
                selected.name
                .. " yielded after "
                .. tostring(stage)
            )
        else
            print(
                selected.name
                .. " error: "
                .. tostring(stage)
            )
        end


        -- Reset waiting time after receiving service.
        selected.waiting = 0
    end
end


print(
    "\n========== Hospital Processing Complete =========="
)