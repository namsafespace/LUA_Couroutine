-- Q20: Integrated National Emergency Response System
-- CCS2105 - Lua Coroutines

local incidents = {
    {
        id = "INC001",
        county = "Nairobi",
        type = "Fire",
        severity = 5,
        resources_required = 3,
        waiting = 0,
        stage = "Report received"
    },

    {
        id = "INC002",
        county = "Mombasa",
        type = "Flood",
        severity = 4,
        resources_required = 2,
        waiting = 0,
        stage = "Report received"
    },

    {
        id = "INC003",
        county = "Turkana",
        type = "Drought",
        severity = 2,
        resources_required = 2,
        waiting = 0,
        stage = "Report received"
    },

    {
        id = "INC004",
        county = "Kisumu",
        type = "Accident",
        severity = 5,
        resources_required = 4,
        waiting = 0,
        stage = "Report received"
    },

    {
        id = "INC005",
        county = "Machakos",
        type = "Storm",
        severity = 3,
        resources_required = 1,
        waiting = 0,
        stage = "Report received"
    }
}


-- Total emergency resources
local availableResources = 6


-- Create an independent coroutine for every incident
local function createIncident(incident)

    return coroutine.create(function()

        -- Stage 1: Report received
        incident.stage = "Report received"

        local decision =
            coroutine.yield(
                incident.id,
                incident.stage,
                incident.severity,
                incident.resources_required
            )


        -- Stage 2: Incident verified
        incident.stage = "Incident verified"

        decision =
            coroutine.yield(
                incident.id,
                incident.stage,
                incident.severity,
                incident.resources_required
            )


        -- Stage 3: Resource assignment
        if decision == "reject" then

            incident.stage = "Failed - Rejected"

            return
        end


        if type(decision) == "number" then

            incident.resources_assigned = decision

        else

            incident.resources_assigned =
                incident.resources_required
        end


        if incident.resources_assigned <= 0 then

            incident.stage =
                "Failed - Insufficient resources"

            return
        end


        incident.stage = "Resources assigned"

        coroutine.yield(
            incident.id,
            incident.stage,
            incident.severity,
            incident.resources_assigned
        )


        -- Stage 4: Response underway
        incident.stage = "Response underway"

        coroutine.yield(
            incident.id,
            incident.stage,
            incident.severity,
            incident.resources_assigned
        )


        -- Stage 5: Incident resolved
        incident.stage = "Incident resolved"

        coroutine.yield(
            incident.id,
            incident.stage,
            incident.severity,
            incident.resources_assigned
        )
    end)
end


-- Create a coroutine for every incident
for _, incident in ipairs(incidents) do

    incident.coroutine =
        createIncident(incident)

end


local active = true
local cycle = 0


while active do

    active = false
    cycle = cycle + 1

    print(
        "\n========== Emergency Cycle "
        .. cycle
        .. " =========="
    )


    -- Increase waiting time for active incidents
    for _, incident in ipairs(incidents) do

        if coroutine.status(incident.coroutine)
            ~= "dead" then

            incident.waiting =
                incident.waiting + 1
        end
    end


    -- Select the highest-priority active incident
    local selected = nil
    local highestScore = -1


    for _, incident in ipairs(incidents) do

        local status =
            coroutine.status(incident.coroutine)

        if status ~= "dead" then

            active = true

            -- Severity has the greatest influence.
            -- Waiting time prevents starvation.
            local score =
                (incident.severity * 10)
                + (incident.waiting * 3)


            -- Prefer incidents whose resources are
            -- currently available.
            if incident.resources_required
                <= availableResources then

                score = score + 5

            else

                score = score - 5
            end


            if score > highestScore then

                highestScore = score
                selected = incident

            end
        end
    end


    if selected ~= nil then

        print(
            "\nSelected incident: "
            .. selected.id
            .. " ("
            .. selected.county
            .. ")"
        )

        print(
            "Priority score: "
            .. highestScore
        )


        local status =
            coroutine.status(selected.coroutine)


        local success
        local id
        local stage
        local severity
        local resourceInfo


        -- First execution:
        -- No decision is required yet.
        if selected.stage == "Report received"
            and status == "suspended" then

            success,
            id,
            stage,
            severity,
            resourceInfo =
                coroutine.resume(
                    selected.coroutine
                )


        -- After verification, send the resource
        -- allocation decision back into the coroutine.
        elseif selected.stage == "Incident verified"
            and status == "suspended" then

            local allocation = 0


            if selected.resources_required
                <= availableResources then

                allocation =
                    selected.resources_required

                availableResources =
                    availableResources - allocation

                print(
                    "Allocating "
                    .. allocation
                    .. " resources to "
                    .. selected.id
                )

            else

                print(
                    "Insufficient resources for "
                    .. selected.id
                )

            end


            success,
            id,
            stage,
            severity,
            resourceInfo =
                coroutine.resume(
                    selected.coroutine,
                    allocation
                )


        else

            -- Continue the incident normally.
            success,
            id,
            stage,
            severity,
            resourceInfo =
                coroutine.resume(
                    selected.coroutine
                )

        end


        if success then

            -- Only print returned values when the
            -- coroutine actually yielded them.
            if id ~= nil and stage ~= nil then

                print(
                    id
                    .. " → "
                    .. stage
                )

            end

            print(
                "Available resources: "
                .. availableResources
            )


            -- If the incident has reached its final
            -- stage, resume it once more so that the
            -- coroutine terminates and becomes dead.
            if selected.stage == "Incident resolved"
                and coroutine.status(
                    selected.coroutine
                ) == "suspended" then

                coroutine.resume(
                    selected.coroutine
                )

            end


        else

            selected.stage =
                "Failed - Coroutine Error"

            print(
                selected.id
                .. " failed: "
                .. tostring(id)
            )

        end


        -- Reset waiting time after being selected.
        selected.waiting = 0


        -- Return resources after the incident
        -- has completed.
        if selected.stage == "Incident resolved"
            and selected.resources_assigned ~= nil
            and selected.resources_assigned > 0 then

            availableResources =
                availableResources
                + selected.resources_assigned

            print(
                selected.id
                .. " returned "
                .. selected.resources_assigned
                .. " resources."
            )

            selected.resources_assigned = 0

        end


        -- Safely identify completed or failed
        -- coroutines.
        if coroutine.status(selected.coroutine)
            == "dead" then

            print(
                selected.id
                .. " coroutine completed."
            )

        end

    end
end


print(
    "\n========== FINAL EMERGENCY SUMMARY =========="
)


for _, incident in ipairs(incidents) do

    local status =
        coroutine.status(incident.coroutine)

    print(
        incident.id
        .. " | "
        .. incident.county
        .. " | "
        .. incident.stage
        .. " | Coroutine: "
        .. status
    )

end


print(
    "\nAvailable resources at end: "
    .. availableResources
)
