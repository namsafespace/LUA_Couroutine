-- Q03: University Course Registration Conflict Resolver
-- CCS2105 - Lua Coroutines

local function createRegistration(student)
    return coroutine.create(function()

        -- Stage 1: Check unit availability.
        print(student.name .. ": Checking unit availability...")

        if not student.unit_available then
            coroutine.yield("Rejected: Unit unavailable")
            return
        end

        coroutine.yield("Unit available")


        -- Stage 2: Check timetable conflict.
        print(student.name .. ": Checking timetable...")

        if student.timetable_conflict then
            coroutine.yield("Rejected: Timetable conflict")
            return
        end

        coroutine.yield("No timetable conflict")


        -- Stage 3: Check prerequisites.
        print(student.name .. ": Checking prerequisites...")

        if not student.prerequisites_met then
            coroutine.yield("Rejected: Prerequisites not met")
            return
        end

        coroutine.yield("Prerequisites satisfied")


        -- Stage 4: Registration confirmation.
        print(student.name .. ": Registration confirmed.")

        student.registered = true

        coroutine.yield("Registration successful")
    end)
end


-- Student registration data.
local students = {
    {
        name = "Student A",
        unit_available = true,
        timetable_conflict = false,
        prerequisites_met = true,
        registered = false
    },

    {
        name = "Student B",
        unit_available = true,
        timetable_conflict = true,
        prerequisites_met = true,
        registered = false
    },

    {
        name = "Student C",
        unit_available = true,
        timetable_conflict = false,
        prerequisites_met = false,
        registered = false
    }
}


-- Create one independent coroutine for each student.
for _, student in ipairs(students) do
    student.coroutine = createRegistration(student)
end


-- Round-robin cooperative scheduler.
local active = true
local cycle = 0

while active do
    active = false
    cycle = cycle + 1

    print("\n========== Registration Cycle "
        .. cycle .. " ==========")

    for _, student in ipairs(students) do
        local co = student.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then
            active = true

            print("\nScheduler resumes " .. student.name)

            local success, result = coroutine.resume(co)

            if success then
                print(
                    student.name
                    .. " status: "
                    .. tostring(result)
                )
            else
                print(
                    student.name
                    .. " error: "
                    .. tostring(result)
                )
            end
        end
    end
end


print("\n========== Registration Results ==========")

for _, student in ipairs(students) do
    if student.registered then
        print(student.name .. ": REGISTERED")
    else
        print(student.name .. ": NOT REGISTERED")
    end
end