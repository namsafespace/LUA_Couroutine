-- Q11: Coroutine State Diagnosis and Fault Recovery
-- CCS2105 - Lua Coroutines

-- Coroutine 1: completes normally.
local completedTask = coroutine.create(function()
    print("Completed task is running.")
    coroutine.yield("Completed task paused")
    print("Completed task finished.")
end)


-- Coroutine 2: produces an error.
local errorTask = coroutine.create(function()
    print("Error task is running.")
    error("Simulated coroutine error")
end)


-- Coroutine 3: remains suspended.
local suspendedTask = coroutine.create(function()
    print("Suspended task is running.")
    coroutine.yield("Suspended permanently")
    print("This line will not be reached.")
end)


-- Store all coroutine tasks.
local tasks = {
    {
        name = "Completed Task",
        coroutine = completedTask
    },

    {
        name = "Error Task",
        coroutine = errorTask
    },

    {
        name = "Suspended Task",
        coroutine = suspendedTask
    }
}


-- First execution.
print("========== First Execution ==========")

for _, task in ipairs(tasks) do

    print(
        task.name
        .. " initial status: "
        .. coroutine.status(task.coroutine)
    )


    local success, result =
        coroutine.resume(task.coroutine)


    if success then
        print(
            task.name
            .. " result: "
            .. tostring(result)
        )
    else
        print(
            task.name
            .. " error handled: "
            .. tostring(result)
        )
    end


    print(
        task.name
        .. " current status: "
        .. coroutine.status(task.coroutine)
    )
end


-- Complete the first coroutine.
print("\n========== Completing First Task ==========")

if coroutine.status(completedTask) ~= "dead" then

    local success, result =
        coroutine.resume(completedTask)


    print(
        "Resume successful: "
        .. tostring(success)
    )

    print(
        "Result: "
        .. tostring(result)
    )

    print(
        "Completed Task status: "
        .. coroutine.status(completedTask)
    )
end


-- Safely inspect all coroutine states.
print("\n========== Safe Scheduler Check ==========")

for _, task in ipairs(tasks) do

    local status =
        coroutine.status(task.coroutine)


    print(
        task.name
        .. " status: "
        .. status
    )


    if status == "dead" then

        print(
            task.name
            .. " will not be resumed because it is dead."
        )

    elseif status == "suspended" then

        print(
            task.name
            .. " is still suspended and can be resumed."
        )

    else

        print(
            task.name
            .. " is currently active."
        )
    end
end