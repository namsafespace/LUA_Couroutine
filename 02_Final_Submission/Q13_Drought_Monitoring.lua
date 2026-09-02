-- Q13: Drought Monitoring and Water Allocation
-- CCS2105 - Lua Coroutines

local stations = {
    {
        county = "Turkana",
        reservoir = 15,
        consumption = 30
    },

    {
        county = "Kitui",
        reservoir = 18,
        consumption = 25
    },

    {
        county = "Garissa",
        reservoir = 35,
        consumption = 20
    },

    {
        county = "Machakos",
        reservoir = 22,
        consumption = 18
    }
}


-- Create a coroutine for each monitoring station.
local function createStation(station)
    return coroutine.create(function()

        coroutine.yield(
            station.county,
            station.reservoir,
            station.consumption
        )
    end)
end


-- Create one independent coroutine for each station.
for _, station in ipairs(stations) do
    station.coroutine = createStation(station)
end


-- Collect monitoring reports.
print("========== Monitoring Reports ==========")

for _, station in ipairs(stations) do

    local success, county, reservoir, consumption =
        coroutine.resume(station.coroutine)

    if success then
        print(
            county
            .. ": Reservoir = "
            .. reservoir
            .. "%, Consumption = "
            .. consumption
        )
    else
        print(
            station.county
            .. " error: "
            .. tostring(county)
        )
    end
end


-- Emergency water supply.
local emergency_supply = 100

print(
    "\nEmergency supply: "
    .. emergency_supply
)


-- Identify counties requiring priority allocation.
local critical = {}

for _, station in ipairs(stations) do

    if station.reservoir < 20 then
        table.insert(critical, station)
    end
end


print("\n========== Critical Counties ==========")

for _, station in ipairs(critical) do
    print(
        station.county
        .. " requires priority allocation."
    )
end


-- Maximum allocation per county = 40% of available supply.
local maximum_per_county =
    emergency_supply * 0.40

print(
    "\nMaximum allocation per county: "
    .. maximum_per_county
)


-- Allocate emergency water.
local remaining = emergency_supply

for _, station in ipairs(critical) do

    if remaining > 0 then

        local requested = station.consumption

        local allocation =
            math.min(
                requested,
                maximum_per_county,
                remaining
            )

        station.allocation = allocation
        remaining = remaining - allocation

    else
        station.allocation = 0
    end
end


-- Display final allocation.
print("\n========== Water Allocation ==========")

for _, station in ipairs(stations) do

    print(
        station.county
        .. " → "
        .. tostring(station.allocation or 0)
        .. " units"
    )
end


print(
    "\nRemaining emergency supply: "
    .. remaining
)


-- Check whether all emergency resources were used.
if remaining == 0 then

    print(
        "Emergency supply was insufficient to satisfy all "
        .. "critical counties."
    )
end