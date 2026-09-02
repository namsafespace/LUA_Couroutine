-- Q02: M-Pesa Transaction Verification and Recovery
-- CCS2105 - Lua Coroutines


local function createTransaction(id, amount, balance)
    return coroutine.create(function()
        -- Stage 1
        print("Transaction " .. id .. ": Request received.")
        coroutine.yield("Request received")

        -- Stage 2
        print("Transaction " .. id .. ": Customer details checked.")
        coroutine.yield("Customer details checked")

        -- Stage 3
        print("Transaction " .. id .. ": Checking balance...")

        if balance < amount then
            print("Transaction " .. id ..
                  ": Insufficient funds. Transaction rejected.")
            coroutine.yield("Rejected - insufficient funds")
            return
        end

        print("Transaction " .. id .. ": Balance verified.")
        coroutine.yield("Balance verified")

        -- Stage 4
        print("Transaction " .. id .. ": Transaction authorized.")
        coroutine.yield("Transaction authorized")

        -- Stage 5
        print("Transaction " .. id .. ": Receipt generated.")
        coroutine.yield("Receipt generated")

        print("Transaction " .. id .. ": Completed successfully.")
    end)
end

local transactions = {
    {id="TX001", amount=500, balance=2000},
    {id="TX002", amount=3000, balance=1500},
    {id="TX003", amount=1000, balance=2500}
}

-- Create one independent coroutine for each transaction.
for _, transaction in ipairs(transactions) do
    transaction.coroutine = createTransaction(
        transaction.id,
        transaction.amount,
        transaction.balance
    )
end

-- Round-robin cooperative scheduler.
local active = true
local cycle = 0

while active do
    active = false
    cycle = cycle + 1

    print("\n========== Processing Cycle " .. cycle .. " ==========")

    for _, transaction in ipairs(transactions) do
        local co = transaction.coroutine

        -- Never resume a dead coroutine.
        if coroutine.status(co) ~= "dead" then
            active = true

            print("\nScheduler resumes " .. transaction.id)

            local success, status = coroutine.resume(co)

            if success then
                print(transaction.id .. " status: " .. tostring(status))
            else
                print(transaction.id .. " error: " .. tostring(status))
            end
        end
    end
end

print("\n========== Processing Complete ==========")

for _, transaction in ipairs(transactions) do
    print(transaction.id ..
          " final state: " ..
          coroutine.status(transaction.coroutine))
end