-- Employees And Their Salaries
-- Find currently employed personnel
SELECT "first_name", "last_name", "occupation", "hired_date"
FROM "employees"
WHERE "terminated_date" IS NULL;

-- Find employed workers whose occupation is combine operator
SELECT "id", "first_name", "last_name"
FROM "employees"
WHERE "terminated_date" IS NULL AND "occupation" = 'combine operator';

-- Find employees with salary below a certain limit
SELECT "employees"."id", "employees"."first_name", "employees"."last_name"
FROM "employees"
JOIN "salaries"
ON "employees"."id" = "salaries"."employee_id"
WHERE "employees"."terminated_date" IS NULL AND "salaries"."amount" < 30000;

-- Find average employee salary by year
SELECT "year", ROUND(AVG("amount")) AS "average_salary"
FROM "salaries"
GROUP BY "year";

-- Find workers operating a specific field on a specific date
SELECT "employees"."first_name", "employees"."last_name"
FROM "employees"
WHERE "id" IN (
    SELECT "employee_id"
    FROM "shifts"
    WHERE "field_id" = 21 AND "date" = '2025-10-10'
);

-- Add new employees
INSERT INTO "employees" ("first_name", "last_name", "occupation")
VALUES 
    ('John', 'Smith', 'tractor driver'),
    ('Peter', 'Dickens', 'combine operator'),
    ('Jack', 'Wilson', 'agronomist');

-- Change employee's occupation
UPDATE "employees"
SET "occupation" = 'planter operator'
WHERE "id" = (
    SELECT "id"
    FROM "employees"
    WHERE "first_name" = 'Peter' AND "last_name" = 'Dickens'
);

-- Add new salary records
INSERT INTO "salaries" ("employee_id", "amount", "year")
VALUES
    ((SELECT "id" FROM "employees" WHERE "first_name" = 'John' AND "last_name" = 'Smith' AND "occupation" = 'tractor driver'), 25000, 2025),
    ((SELECT "id" FROM "employees" WHERE "first_name" = 'Peter' AND "last_name" = 'Dickens' AND "occupation" = 'planter operator'), 40000, 2025),
    ((SELECT "id" FROM "employees" WHERE "first_name" = 'Jack' AND "last_name" = 'Wilson' AND "occupation" = 'agronomist'), 45000, 2025);

-- Raise agronomist salary by 10% in 2026
INSERT INTO "salaries" ("employee_id", "amount", "year")
SELECT "employee_id", "amount" * 1.1, 2026
FROM "salaries"
WHERE "year" = 2025 AND "employee_id" IN (
    SELECT "id" 
    FROM "employees" 
    WHERE "occupation" = 'agronomist'
);

-- Terminate an employee
UPDATE "employees"
SET "terminated_date" = CURRENT_DATE
WHERE "first_name" = 'Jack' AND "last_name" = 'Wilson';


-- Vehicles 
-- Find currently owned vehicles
SELECT "id", "model", "type"
FROM "vehicles"
WHERE "sell_date" IS NULL;

-- Find old vehicles that still in operation
SELECT "id", "model", "type"
FROM "vehicles"
WHERE "sell_date" IS NULL AND "purchase_date" < '2010-01-01';

-- Add newly purchased vehicle to the garage
INSERT INTO "vehicles" ("model", "type", "purchase_price")
VALUES 
    ('John Deere 5075E', 'tractor', 38500),
    ('John Deere S770', 'combine', 298000);

-- Remove recently disposed vehicle from the garage
UPDATE "vehicles" 
SET 
    "disposal_price" = 15000,
    "sell_date" = CURRENT_DATE
WHERE "id" = (
    SELECT "id"
    FROM "vehicles"
    WHERE "model" = 'John Deere 5075E' AND "purchase_date" = '2026-05-03'
);


-- Fuel
-- Find available amount of fuel
SELECT "type", "amount"
FROM "fuel";

-- Find amount and cost of fuel used in 2025
SELECT SUM("fuel_used"."amount") AS "total_usage", SUM("fuel_used"."amount" * "fuel"."unit_price") AS "total_cost"
FROM "fuel_used"
JOIN "fuel"
ON "fuel_used"."fuel_id" = "fuel"."id"
WHERE "fuel_used"."date" BETWEEN '2025-01-01' AND '2025-12-31';

-- Add new fuel refuel records for vehicles
INSERT INTO "fuel_used" ("vehicle_id", "fuel_id", "amount")
SELECT 
    (SELECT "id" FROM "vehicles" WHERE "model" = 'John Deere S770'), 
    (SELECT "id" FROM "fuel" WHERE "type" = 'diesel'),
    200;

-- Add newly purchased fuel amount to the tank
UPDATE "fuel"
SET "amount" = "amount" + 500
WHERE "type" = 'diesel'; 


-- Fields
-- Find fields under managemnt
SELECT "id", "name", "area"
FROM "fields"
WHERE "sell_date" IS NULL;

-- Find total area of the owned fields
SELECT SUM("area") AS "total_area"
FROM "fields"
WHERE "sell_date" IS NULL;

-- Find the fields and fertilisers applied in spring 2026
SELECT "shifts"."field_id", "fields"."name", "fields"."area", "fertilisers"."name", "fertilisers_applied"."amount"
FROM "shifts"
JOIN "fertilisers_applied"
ON "shifts"."id" = "fertilisers_applied"."shift_id"
JOIN "fertilisers"
ON "fertilisers_applied"."fertiliser_id" = "fertilisers"."id"
JOIN "fields"
ON "shifts"."field_id" = "fields"."id"
WHERE "shifts"."date" BETWEEN '2026-03-01' AND '2026-05-31';

-- Find the fields with wheat seeded in specific year
SELECT "shifts"."field_id", "fields"."name", "crops"."name"
FROM "shifts"
JOIN "seeded_crops"
ON "shifts"."id" = "seeded_crops"."shift_id"
JOIN "crops"
ON "seeded_crops"."crop_id" = "crops"."id"
JOIN "fields"
ON "shifts"."field_id" = "fields"."id"
WHERE ("shifts"."date" BETWEEN '2025-01-01' AND '2025-12-31') AND "crops"."type" = 'wheat';

-- Find field productivity
SELECT "fields"."id", SUM("yields"."quantity") / "fields"."area" AS "productivity"
FROM "fields"
JOIN "shifts"
ON "fields"."id" = "shifts"."field_id"
JOIN "yields"
ON "shifts"."id" = "yields"."shift_id"
WHERE "shifts"."date" BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY "fields"."id";

-- Add newly purchased field
INSERT INTO "fields" ("name", "area", "purchase_price")
VALUES ('North Meadow', 10000, 12000);

-- Remove recently disposed field
UPDATE "fields" 
SET 
    "disposal_price" = 10000,
    "sell_date" = CURRENT_DATE
WHERE "id" = (
    SELECT "id"
    FROM "fields"
    WHERE "name" = 'North Meadow' AND "purchase_date" = '2026-05-04'
);


-- Crops
-- Find quantity of crops available
SELECT "name", "type", "quantity"
FROM "crops";

-- Find crops seeded in specific year
SELECT SUM("seeded_crops"."quantity") AS "total_seeding"
FROM "seeded_crops"
JOIN "shifts"
ON "seeded_crops"."shift_id" = "shifts"."id"
WHERE "shifts"."date" BETWEEN '2025-01-01' AND '2025-12-31';

-- Add newly purchased crops
INSERT INTO "crops" ("name", "type", "quantity", "unit_price")
VALUES 
    ('Wheat Triticum 12', 'wheat', 500, 10),
    ('Corn P9241', 'corn', 1000, 12);

-- Add recently seeded crop records
INSERT INTO "seeded_crops" ("crop_id", "shift_id", "quantity")
SELECT 
    (SELECT "id" FROM "crops" WHERE "name" = 'Wheat Triticum 12'),
    (SELECT "id" FROM "shifts" WHERE "field_id" = 1 AND "date" = '2026-03-01' AND "work_type" = 'seeding'),
    20;


-- Fertilisers
-- Find amount of fertilisers available
SELECT "name", "type", "amount"
FROM "fertilisers";

-- Find fertiliser info applied onto a specific field
SELECT "fertilisers"."name", "fertilisers_applied"."amount", "shifts"."date"
FROM "fertilisers"
JOIN "fertilisers_applied"
ON "fertilisers"."id" = "fertilisers_applied"."fertiliser_id"
JOIN "shifts"
ON "fertilisers_applied"."shift_id" = "shifts"."id"
WHERE "shifts"."field_id" = (
    SELECT "id"
    FROM "fields"
    WHERE "name" = 'North Meadow'
)
ORDER BY "shifts"."date" DESC
LIMIT 1;

-- Finde fertilisers running out of stock
SELECT "name", "type", "amount"
FROM "fertilisers" 
WHERE "amount" < 100
ORDER BY "amount" ASC;

-- Add newly purchased fertilisers
INSERT INTO "fertilisers" ("name", "type", "amount", "unit_price")
VALUES 
    ('UAN 32', 'nitrogen', 200, 30),
    ('SSP 16', 'phosphorus', 100, 15);

-- Add recently applied fertiliser records
INSERT INTO "fertilisers_applied" ("fertiliser_id", "shift_id", "amount")
SELECT 
    (SELECT "id" FROM "fertilisers" WHERE "name" = 'UAN 32'),
    (SELECT "id" FROM "shifts" WHERE "field_id" = 1 AND "date" = '2026-03-01'),
    20;


-- Spare Parts
-- Find available spare parts
SELECT "name", "type", "quantity"
FROM "spare_parts";

-- Find spare parts ran out
SELECT "name", "type"
FROM "spare_parts"
WHERE "quantity" = 0;

-- Add newly purchased spare parts
INSERT INTO "spare_parts" ("name", "type", "quantity", "item_price")
VALUES 
    ('Bosch 044', 'fuel pump', 2, 299),
    ('Denso DSN1202', 'starter motor', 1, 149);


-- Repairs
-- Find repairs in progress
SELECT "id", "vehicle_id", "start_date"
FROM "repairs"
WHERE "end_date" IS NULL;

-- Find verhicles being on repair the most times
SELECT "vehicles"."model"
FROM "vehicles"
JOIN "repairs"
ON "vehicles"."id" = "repairs"."vehicle_id"
GROUP BY "repairs"."vehicle_id"
ORDER BY "repairs"."vehicle_id"
LIMIT 1;

-- Find what repair was performed on s specific vehicle most recently
SELECT "spare_parts"."name"
FROM "spare_parts"
JOIN "parts_kit"
ON "spare_parts"."id" = "parts_kit"."part_id"
JOIN "repairs"
ON "parts_kit"."repair_id" = "repairs"."parts_kit_id"
WHERE "repairs"."vehicle_id" = (
    SELECT "id"
    FROM "vehicles"
    WHERE "model" = 'John Deere S770'
)
ORDER BY "repairs"."end_date" DESC
LIMIT 1;

-- Add new repair records
INSERT INTO "repairs" ("vehicle_id")
SELECT "id" FROM "vehicles" WHERE "model" = 'John Deere S770';

-- Add spare parts used
INSERT INTO "parts_kit" ("repair_id", "part_id", "quantity")
SELECT 
    (SELECT "id" FROM "repairs" WHERE "vehicle_id" = (
        SELECT "id" FROM "vehicles" WHERE "model" = 'John Deere S770'
    ) AND "end_date" IS NULL),
    (SELECT "id" FROM "spare_parts" WHERE "name" = 'Bosch 044'),
    1;

-- Mark repair as finished
UPDATE "repairs" 
SET "end_date" = CURRENT_TIMESTAMP
WHERE "vehicle_id" = (
        SELECT "id" FROM "vehicles" WHERE "model" = 'John Deere S770'
    ) AND "end_date" IS NULL;


-- Yields
-- Find yield amount collected in 2025
SELECT "crops"."type", SUM("yields"."quantity") AS "collected"
FROM "yields"
JOIN "shifts" 
ON "yields"."shift_id" = "shifts"."id"
JOIN "seeded_crops"
ON "shifts"."id" = "seeded_crops"."shift_id"
JOIN "crops"
ON "seeded_crops"."crop_id" = "crops"."id"
WHERE "shifts"."date" BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY "crops"."type"
ORDER BY "collected" DESC;

-- Find yields being stored
SELECT "crops"."type", SUM("yields_stored"."quantity") AS "totally_stored"
FROM "yields_stored"
JOIN "yields"
ON "yields_stored"."yield_id" = "yields"."id"
JOIN "shifts"
ON "yields"."shift_id" = "shifts"."id"
JOIN "seeded_crops"
ON "shifts"."id" = "seeded_crops"."shift_id"
JOIN "crops"
ON "seeded_crops"."crop_id" = "crops"."id"
GROUP BY "crops"."type"
ORDER BY "totally_stored" DESC;

-- Add recently collected yields
INSERT INTO "yields" ("shift_id", "quantity")
SELECT 
    (SELECT "id" FROM "shifts" WHERE "date" = '2025-07-13' AND "field_id" = (
        SELECT "id" FROM "fields" WHERE "name" = 'North Meadow') AND "work_type" = 'harvesting'),
    110000;
    

-- Storages
-- Find the total capacity of the storages
SELECT SUM("capacity") AS "total_capacity"
FROM "storages";

-- Find occupancy of storages
SELECT "storages"."id", ("storages"."capacity" - "yields_stored"."quantity") AS "capacity_available", (("storages"."capacity" - "yields_stored"."quantity")/"storages"."capacity") AS "occupancy"
FROM "storages"
JOIN "yields_stored"
ON "storages"."id" = "yields_stored"."storage_id"
GROUP BY "storages"."id";

-- Add newly built storage
INSERT INTO "storages" ("capacity", "cost")
VALUES (960000, 70000);


-- Sells
-- Find revenue for a specific year
SELECT SUM("sells"."quantity" * "sells"."unit_price") AS "revenue"
FROM "sells"
JOIN "yields"
ON "sells"."yield_id" = "yields"."id"
JOIN "shifts"
ON "yields"."shift_id" = "shifts"."id"
WHERE "shifts"."date" BETWEEN '2025-01-01' AND '2025-12-31';

-- Add new sell record
INSERT INTO "sells" ("yield_id", "quantity", "unit_price")
SELECT 
    (SELECT "id" FROM "yields_stored" WHERE "storage_id" = 3),
    30000, 
    20;


-- Shifts
-- Add new shift records
INSERT INTO "shifts" ("field_id", "vehicle_id", "employee_id", "work_type")
VALUES 
    (12, 3, 7, 'plowing'),
    (12, 4, 13, 'plowing');