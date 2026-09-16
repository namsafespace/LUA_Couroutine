local task = coroutine.create(function()
    print("Step 1")

    coroutine.yield()

    print("Step 2")

    coroutine.yield()

    print("Step 3")
end)

print("Before starting:", coroutine.status(task))

coroutine.resume(task)

print("After first resume:", coroutine.status(task))

coroutine.resume(task)

print("After second resume:", coroutine.status(task))

coroutine.resume(task)

print("After third resume:", coroutine.status(task))
