-- Represent employees 
CREATE TABLE "employees" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "occupation" TEXT NOT NULL,
    "hired_date" NUMERIC DEFAULT CURRENT_DATE NOT NULL,
    "terminated_date" NUMERIC DEFAULT NULL,
    PRIMARY KEY("id")
);

-- Represent currently employed personnel
CREATE VIEW "current_personnel" AS
    SELECT "first_name", "last_name", "occupation", "hired_date"
    FROM "employees"
    WHERE "terminated_date" IS NULL;

-- Represent salaries received by employees
CREATE TABLE "salaries" (
    "id" INTEGER,
    "employee_id" INTEGER,
    "amount" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("employee_id") REFERENCES "workers"("id")
);

-- Represent vehicles operating the fields
CREATE TABLE "vehicles" (
    "id" INTEGER,
    "model" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "purchase_price" INTEGER NOT NULL,
    "purchase_date" NUMERIC DEFAULT CURRENT_DATE NOT NULL,
    "disposal_price" INTEGER DEFAULT NULL,
    "sell_date" NUMERIC DEFAULT NULL,
    PRIMARY KEY("id")
);

-- Create index on vehicle models to speed up common serches
CREATE INDEX "vehicle_model_index" ON "vehicles"("model");

-- Represent currently owned vehicles
CREATE VIEW "available_vehicles" AS
    SELECT "id", "model", "type"
    FROM "vehicles"
    WHERE "sell_date" IS NULL;

-- Represent fuel owned by the farm
CREATE TABLE "fuel" (
    "id" INTEGER,
    "type" TEXT NOT NULL CHECK ("type" IN ('diesel', 'gas', 'gasoline')), 
    "amount" INTEGER NOT NULL CHECK ("amount" >= 0),
    "unit_price" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent fuel used
CREATE TABLE "fuel_used" (
    "id" INTEGER,
    "vehicle_id" INTEGER,
    "fuel_id" INTEGER,
    "amount" INTEGER,
    "date" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("vehicle_id") REFERENCES "vehicles"("id"),
    FOREIGN KEY("fuel_id") REFERENCES "fuel"("id")
);

-- Update available fuel amount after usage
CREATE TRIGGER "after_refill_fuel_update"
AFTER INSERT ON "fuel_used"
BEGIN
    UPDATE "fuel"
    SET "amount" = "amount" - NEW."amount"
    WHERE "id" = NEW."fuel_id";
END;

-- Represent fields at the farm's disposal
CREATE TABLE "fields" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "area" INTEGER NOT NULL,
    "purchase_price" INTEGER NOT NULL,
    "purchase_date" NUMERIC NOT NULL DEFAULT CURRENT_DATE,
    "disposal_price" INTEGER DEFAULT NULL,
    "sell_date" NUMERIC DEFAULT NULL,
    PRIMARY KEY("id")
);

-- Create index on field names to speed up common serches
CREATE INDEX "field_name_index" ON "fields"("name");

-- Represent fieldss under management
CREATE VIEW "managed_fields" AS
    SELECT "id", "name", "area"
    FROM "fields"
    WHERE "sell_date" IS NULL;

-- Represent employees' shifts 
CREATE TABLE "shifts" (
    "id" INTEGER,
    "field_id" INTEGER,
    "vehicle_id" INTEGER,
    "employee_id" INTEGER,
    "work_type" TEXT NOT NULL,
    "date" NUMERIC NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY("id"),
    FOREIGN KEY("field_id") REFERENCES "fields"("id"),
    FOREIGN KEY("vehicle_id") REFERENCES "vehicles"("id"),
    FOREIGN KEY("employee_id") REFERENCES "workers"("id")
);

-- Create index on shift dates to speed up common serches
CREATE INDEX "shift_date_index" ON "shifts"("date");

-- Represent farm crop catalog
CREATE TABLE "crops" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL CHECK ("type" IN ('wheat', 'corn', 'barley', 'sunflower', 'soybean')),
    "quantity" INTEGER NOT NULL,
    "unit_price" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent crops used for seeding
CREATE TABLE "seeded_crops" (
    "id" INTEGER,
    "crop_id" INTEGER,
    "shift_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("crop_id") REFERENCES "crops"("id"),
    FOREIGN KEY("shift_id") REFERENCES "shifts"("id")
);

-- Update available quantity of crops after seeding
CREATE TRIGGER "after_seeded_crops_update"
AFTER INSERT ON "seeded_crops"
BEGIN
    UPDATE "crops"
    SET "quantity" = "quantity" - NEW."quantity"
    WHERE "id" = NEW."id";
END;

-- Represent farm fertiliser catalog
CREATE TABLE "fertilisers" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "type" TEXT CHECK ("type" IN ('nitrogen', 'phosphorus', 'potassium', 'calcium', 'magnesium', 'sulfur', 'micronutrients')),
    "amount" INTEGER NOT NULL,
    "unit_price" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent fertilisers applied to fields
CREATE TABLE "fertilisers_applied" (
    "id" INTEGER,
    "fertiliser_id" INTEGER,
    "shift_id" INTEGER,
    "amount" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("fertiliser_id") REFERENCES "fertilisers"("id"),
    FOREIGN KEY("shift_id") REFERENCES "shifts"("id")
);

-- Update available amount of fertilisers after application
CREATE TRIGGER "after_applied_fertilisers_update"
AFTER INSERT ON "fertilisers_applied"
BEGIN
    UPDATE "fertilisers"
    SET "amount" = "amount" - NEW."amount"
    WHERE "id" = NEW."id";
END;

-- Represent spare parts available in the garage
CREATE TABLE "spare_parts" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL CHECK ("quantity" >= 0),
    "item_price" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent vehicle repairs
CREATE TABLE "repairs" (
    "id" INTEGER,
    "vehicle_id" INTEGER,
    "parts_kit_id" INTEGER,
    "start_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "end_date" NUMERIC DEFAULT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("vehicle_id") REFERENCES "vehicles"("id"),
    FOREIGN KEY("parts_kit_id") REFERENCES "parts_kit"("id")
);

-- Represent spare parts used for a repair
CREATE TABLE "parts_kit" (
    "id" INTEGER,
    "repair_id" INTEGER,
    "part_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("repair_id") REFERENCES "repairs"("id"),
    FOREIGN KEY("part_id") REFERENCES "spare_parts"("id")
);

-- Update available quantity of spare parts after usage
CREATE TRIGGER "after_usage_parts_update"
AFTER INSERT ON "parts_kit"
BEGIN
    UPDATE "spare_parts"
    SET "quantity" = "quantity" - NEW."quantity"
    WHERE "id" = NEW."part_id";
END;

-- Represent collected yields
CREATE TABLE "yields" (
    "id" INTEGER,
    "shift_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("shift_id") REFERENCES "shifts"("id")
);

-- Represent owned storages
CREATE TABLE "storages" (
    "id" INTEGER,
    "capacity" INTEGER NOT NULL,
    "cost" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent yields being stored
CREATE TABLE "yields_stored" (
    "id" INTEGER,
    "yield_id" INTEGER,
    "storage_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("yield_id") REFERENCES "yields"("id"),
    FOREIGN KEY("storage_id") REFERENCES "storages"("id")
);

-- Represent occupancy of storages
CREATE VIEW "storage_occupancy" AS
    SELECT "storages"."id", ("storages"."capacity" - "yields_capacity"."quantity") AS "capacity_available", (("storages"."capacity" - "yields_capacity"."quantity")/"storages"."capacity") AS "occupancy"
    FROM "storages"
    JOIN "yields_stored"
    ON "storages"."id" = "yields_stored"."storage_id"
    GROUP BY "storages"."id";

-- Check wheather a storage has enough available volume
CREATE TRIGGER "yields_stored_insert_check"
AFTER INSERT ON "yields_stored"
BEGIN
    DELETE FROM "yields_stored"
    WHERE "id" = NEW."id";
    
    INSERT INTO "yields_stored" ("id", "yield_id", "storage_id", "quantity")
    SELECT NEW."id", NEW."yield_id", NEW."storage_id", NEW."quantity"
    FROM "yields_stored"
    JOIN "storages"
    ON NEW."id" = "id"
    WHERE NEW."quantity" < ("storages"."capacity" - "storages"."quantity");
END;

-- Represent sells of yields
CREATE TABLE "sells" (
    "id" INTEGER,
    "yield_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    "unit_price" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("yield_id") REFERENCES "yields"("id")
);

-- Update remaining stored yields after selling
CREATE TRIGGER "after_sell_storage_update"
AFTER INSERT ON "sells"
BEGIN 
    UPDATE "yields_stored"
    SET "quantity" = "quantity" - NEW."quantity"
    WHERE "yield_id" = NEW."yield_id";

    DELETE FROM "yields_stored"
    WHERE "quantity" = 0;
END;

-- Represent farm assets by category
CREATE VIEW "assets" AS
    SELECT SUM("purchase_price") AS "vehicles"
    FROM "available_vehicles"

    UNION

    SELECT SUM("amount" * "unit_price") AS "fuel"
    FROM "fuel"

    UNION 

    SELECT SUM("purchase_price") AS "fields"
    FROM "managed_fields"

    UNION

    SELECT SUM("quantity"*"unit_price") AS "crops"
    FROM "crops"

    UNION 

    SELECT SUM("amount"*"unit_price") AS "fertilisers"
    FROM "fertilisers"

    UNION

    SELECT SUM("quantity"*"unit_price") AS "parts"
    FROM "spare_parts"

    UNION

    SELECT SUM("cost") AS "storages"
    FROM "storages";