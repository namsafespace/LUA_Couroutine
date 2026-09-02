-- Q17: Fraud-Aware Mobile Banking Workflow
-- CCS2105 - Lua Coroutines

local transactions = {
    {
        id = "TX001",
        fraud_score = 20
    },

    {
        id = "TX002",
        fraud_score = 85
    },

    {
        id = "TX003",
        fraud_score = 30
    }
}

local HIGH_RISK = 70


-- Create one independent coroutine for each transaction.
local function createTransaction(transaction)

    return coroutine.create(function()

        -- Stage 1: Authentication
        print(transaction.id .. ": Authentication")

        coroutine.yield(
            transaction.id,
            "Authentication complete"
        )


        -- Stage 2: Transaction request
        print(transaction.id .. ": Transaction request")

        coroutine.yield(
            transaction.id,
            "Transaction requested"
        )


        -- Stage 3: Fraud-risk assessment
        print(
            transaction.id
            .. ": Fraud score = "
            .. transaction.fraud_score
        )


        -- High-risk transaction waits for manual review.
        if transaction.fraud_score >= HIGH_RISK then

            print(
                transaction.id
                .. ": High risk. Waiting for manual review."
            )

            local decision = coroutine.yield(
                transaction.id,
                "Manual review required",
                transaction.fraud_score
            )


            if decision == "approve" then

                print(
                    transaction.id
                    .. ": Manual review approved."
                )

            elseif decision == "reject" then

                print(
                    transaction.id
                    .. ": Rejected after manual review."
                )

                return "rejected"

            else

                print(
                    transaction.id
                    .. ": Invalid review decision."
                )

                return "rejected"
            end
        end


        -- Stage 4: Authorization
        print(transaction.id .. ": Authorization")

        coroutine.yield(
            transaction.id,
            "Authorization complete"
        )


        -- Stage 5: Confirmation
        print(transaction.id .. ": Confirmation")

        print(
            transaction.id
            .. ": Transaction completed."
        )

    end)
end


-- Create a coroutine for every transaction.
for _, transaction in ipairs(transactions) do

    transaction.coroutine =
        createTransaction(transaction)

end


--------------------------------------------------
-- INITIAL PROCESSING
--------------------------------------------------

print("========== Initial Processing ==========")

for _, transaction in ipairs(transactions) do

    print(
        "\nProcessing "
        .. transaction.id
    )


    -- Resume authentication.
    local success, id, status =
        coroutine.resume(
            transaction.coroutine
        )


    if success then

        print(
            id
            .. " → "
            .. tostring(status)
        )

    else

        print(
            transaction.id
            .. " error: "
            .. tostring(id)
        )
    end


    -- Continue the workflow.
    local continueProcessing = true

    while continueProcessing
        and coroutine.status(
            transaction.coroutine
        ) ~= "dead" do

        local ok, resultId, resultStatus =
            coroutine.resume(
                transaction.coroutine
            )


        if not ok then

            print(
                transaction.id
                .. " error: "
                .. tostring(resultId)
            )

            break
        end


        if resultId ~= nil then

            print(
                resultId
                .. " → "
                .. tostring(resultStatus)
            )

        end


        -- Stop when a high-risk transaction reaches
        -- the manual-review suspension.
        if transaction.fraud_score >= HIGH_RISK
            and resultStatus == "Manual review required" then

            continueProcessing = false
        end
    end
end


--------------------------------------------------
-- MANUAL REVIEW
--------------------------------------------------

print("\n========== Manual Review ==========")

for _, transaction in ipairs(transactions) do

    if transaction.fraud_score >= HIGH_RISK
        and coroutine.status(
            transaction.coroutine
        ) == "suspended" then

        print(
            "Manual review for "
            .. transaction.id
        )


        -- External decision.
        local decision = "approve"

        print(
            "Review decision: "
            .. decision
        )


        -- Send decision into the suspended coroutine.
        local success, resultId, resultStatus =
            coroutine.resume(
                transaction.coroutine,
                decision
            )


        if not success then

            print(
                transaction.id
                .. " error: "
                .. tostring(resultId)
            )

        else

            if resultId ~= nil then

                print(
                    resultId
                    .. " → "
                    .. tostring(resultStatus)
                )

            end
        end


        -- Continue after manual approval.
        while coroutine.status(
            transaction.coroutine
        ) ~= "dead" do

            local ok, id, status =
                coroutine.resume(
                    transaction.coroutine
                )


            if not ok then

                print(
                    transaction.id
                    .. " error: "
                    .. tostring(id)
                )

                break
            end


            if id ~= nil then

                print(
                    id
                    .. " → "
                    .. tostring(status)
                )

            end
        end
    end
end


--------------------------------------------------
-- FINAL STATES
--------------------------------------------------

print(
    "\n========== Final Transaction States =========="
)

for _, transaction in ipairs(transactions) do

    print(
        transaction.id
        .. " → "
        .. coroutine.status(
            transaction.coroutine
        )
    )
end