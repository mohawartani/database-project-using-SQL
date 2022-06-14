/*
* File: Assignment2_SubmissionTemplate.sql
* 
* 1) Rename this file according to the instructions in the assignment statement.
* 2) Use this file to insert your solution.
*
*
* Author: <Awartani>, <Mohammad>
* Student ID Number: <2201621>
* Institutional mail prefix: <MXA1311>
*/


/*
*  Assume a user account 'fsad' with password 'fsad2022' with permission
* to create  databases already exists. You do NO need to include the commands
* to create the user nor to give it permission in you solution.
* For your testing, the following command may be used:
*
* CREATE USER fsad PASSWORD 'fsad2022' CREATEDB;
* GRANT pg_read_server_files TO fsad;
*/


/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.
\cd 'YOUR WORKING DIRECTORY HERE'
  -- In PostgreSQL, folders are identified with '/'


-- 1) Create a database called SmokedTrout.

CREATE DATABASE 'SmokedTrout'
WITH OWNER = fsad
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;


-- 2) Connect to the database

\c smokedtrout fsad




/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state
CREATE TYPE materialState AS ENUM ('Solid', 'Liquid', 'Gas',
'Plasma');
-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.
CREATE TYPE materialComposition AS ENUM ('Fundamental','Composite');
-- 3) Create the table TradingRoute with the corresponding attributes.

CREATE TABLE TradingRoute(
    MonitoringKey SERIAL,
    FleetSize int,
    OperatingCompany varchar(60),
    LastYearRevenue real,
    PRIMARY KEY (MonitoringKey));
-- 4) Create the table Planet with the corresponding attributes.

    CREATE TABLE Planet(
    PlanetId SERIAL ,
    StarSystem varchar(60) ,
    Name varchar(60) ,
    Population int ,
    PRIMARY KEY (PlanetID)
    );
-- 5) Create the table SpaceStation with the corresponding attributes.
CREATE TABLE SpaceStation(
  StationID SERIAL,
  PlanetID int,
  Name varchar(60),
  Longtitude varchar(60),
  Latitude varchar(60),
  PRIMARY KEY (StationID),
  FOREIGN KEY(PlanetID) REFERENCES Planet(PlanetID)
    );

-- 6) Create the parent table Product with the corresponding attributes.
CREATE TABLE Product(
    ProductID SERIAL,
    Product varchar (150),
    VolumePerTon real,
    ValuePerTon real,
    PRIMARY KEY (ProductID)
    );

-- 7) Create the child table RawMaterial with the corresponding attributes.
CREATE TABLE RawMaterial(
  State materialState,
  FundamentalOrComposite materialComposition)
  INHERITS (Product)
  ;

-- 8) Create the child table ManufacturedGood. 
CREATE TABLE ManufacturedGoods() inherits (Product);
-- 9) Create the table MadeOf with the corresponding attributes.
CREATE TABLE MadeOf (ManufacturedGoodID int, ProductID int);
-- 10) Create the table Batch with the corresponding attributes.
CREATE TABLE Batch(
     BatchID SERIAL, 
    ProductID int,
    ExtractionOrManufacturingDate varchar(60),
    OriginalFrom int,
    PRIMARY KEY(BatchID),
    FOREIGN KEY(OriginalFrom) REFERENCES Planet(PlanetID)
    );
-- 11) Create the table Sells with the corresponding attributes.
CREATE TABLE Sells(
  BatchID int,
  StationID SERIAL,
  FOREIGN KEY(BatchID)
  REFERENCES Batch(BatchID),
  FOREIGN KEY(StationID) REFERENCES SpaceStation(StationID)
  );
-- 12)  Create the table Buys with the corresponding attributes.
CREATE TABLE Buys(
    BatchID int,
    StationID int,
    FOREIGN KEY(BatchID) REFERENCES Batch(BatchID),
    FOREIGN KEY(StationID) REFERENCES SpaceStation(StationID)
    );
-- 13)  Create the table CallsAt with the corresponding attributes.
CREATE TABLE CallsAt(
  VisitOrder int,
  StationID int,
  MonitoringKey int,
  FOREIGN KEY(MonitoringKey) REFERENCES TradingRoute(MonitoringKey),
  FOREIGN KEY(StationID) REFERENCES SpaceStation(StationID)
  );
-- 14)  Create the table Distance with the corresponding attributes.
CREATE TABLE Distance(
    PlanetOrigin int REFERENCES Planet(PlanetID),
    PlanetDestination int REFERENCES Planet(PlanetID),
    AvgDistance real
    );
/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */



-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.
CREATE TABLE Dummy (
  MonitoringKey SERIAL,
  FleetSize int,
  OperatingCompany varchar (60),
  LastYearRevenue real NOT NULL);
\copy Dummy FROM './data/TradeRoutes.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO TradingRoute (MonitoringKey ,
OperatingCompany, 
FleetSize,
LastYearRevenue) 

SELECT MonitoringKey,
OperatingCompany,
FleetSize,
LastYearRevenue FROM Dummy;

DROP TABLE Dummy;
-- 3) Populate the table Planet with the data in the file Planets.csv.
CREATE TABLE Dummy(
  Population int,
  StarSystem varchar(60),
  Name varchar(60),
  PlanetID SERIAL
  );

\copy Dummy FROM './data/Planets.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO PLANET(PlanetID,
StarSystem,
Name ,
Population) 

SELECT Population,
StarSystem,
Name,
PlanetID FROM Dummy;

DROP TABLE Dummy;
-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.
CREATE TABLE Dummy(
  StationID SERIAL,
  PlanetID int,
  Name varchar(60),
  Longtitude varchar(60),
  Latitude varchar(60)
  );

\copy Dummy FROM './data/SpaceStations.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO SpaceStation(
StationID,
PlanetID,
Name,
Longtitude,
Latitude) 

SELECT StationID,
PlanetID,
Name,
Longtitude,
Latitude FROM Dummy;

DROP TABLE Dummy;
-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv. 
CREATE TABLE Dummy(
  ProductID SERIAL PRIMARY KEY ,
  Name varchar(60) ,
  FundamentalOrComposite text ,
  VolumePerTon real ,
  ValuePerTon real ,
  State materialState
  );

\copy Dummy FROM './data/Products_Raw.csv' WITH ( FORMAT CSV , HEADER );

UPDATE Dummy SET FundamentalOrComposite = 
CASE
WHEN FundamentalOrComposite = 'Yes' THEN 'Composite' 
WHEN FundamentalOrComposite = 'No' THEN 'Fundamental'
END;
INSERT INTO RawMaterial (ProductID,
Name,
FundamentalOrComposite,
VolumePerTon,
ValuePerTon,
State)

SELECT ProductID,
Name,
CAST(FundamentalOrComposite AS materialComposition),
VolumePerTon,
ValuePerTon, 
State FROM Dummy;

DROP TABLE Dummy;
-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.
CREATE TABLE Dummy(
ProductID SERIAL,
Product varchar (60),
VolumePerTon real,
ValuePerTon real
);

\copy Dummy FROM './data/Products_Manufactured.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO ManufacturedGood (ProductID,
Name,
VolumePerTon,
ValuePerTon) 

SELECT ProductID,
Product,
VolumePerTon,
ValuePerTon FROM Dummy;

DROP TABLE Dummy;
-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.
CREATE TABLE Dummy(
  ManufacturedGoodID int,
  ProductID int
  );

\copy Dummy FROM './data/MadeOf.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO MadeOf( ManufacturedGoodID,
ProductID) 

SELECT ManufacturedGoodID,
ProductID FROM Dummy;

DROP TABLE Dummy;
-- 8) Populate the table Batch with the data in the file Batches.csv.
CREATE TABLE Dummy(
  BatchID SERIAL,
  ProductID int, 
  ExtractionOrManufacturingDate varchar(60) ,
  OriginalFrom int
  );

\copy Dummy FROM './data/Batches.csv' WITH ( FORMAT CSV , HEADER );

INSERT INTO Batch(
  BatchID,
  ProductID,
  ExtractionOrManufacturingDate,
  OriginalFrom)

SELECT BatchID,
ProductID,
 ExtractionOrManufacturingDate,
 OriginalFrom FROM Dummy;

 DROP TABLE Dummy;
-- 9) Populate the table Sells with the data in the file Sells.csv.
CREATE TABLE Dummy( BatchID int,
StationID int
);

\copy Dummy FROM './data/Sells.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO Sells(
  BatchID,
  StationID) 

SELECT BatchID,
StationID FROM Dummy;

DROP TABLE Dummy;
-- 10) Populate the table Buys with the data in the file Buys.csv.
CREATE TABLE Dummy(
  BatchID SERIAL,
  StationID SERIAL
  );

\copy Dummy FROM './data/Buys.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO Buys (
  BatchID,
  StationID) 
  
SELECT BatchID,
StationID FROM Dummy;

DROP TABLE Dummy;
-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.
CREATE TABLE Dummy(
  MonitoringKey SERIAL,
  StationID SERIAL,
  VisitOrder int
  );

\copy Dummy FROM './data/CallsAt.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO CallsAt (MonitoringKey,
StationID,
VisitOrder) 

SELECT MonitoringKey,
StationID,
VisitOrder FROM Dummy;

DROP TABLE Dummy;
-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.
CREATE TABLE Dummy(
  PlanetOrigin int,
  PlanetDestination int,
  AvgDistance real);

\copy Dummy FROM './data/PlanetDistances.csv' WITH (FORMAT CSV , HEADER );

INSERT INTO Distance (PlanetOrigin,
PlanetDestination,
AvgDistance) 

SELECT PlanetOrigin,
PlanetDestination,
AvgDistance FROM Dummy;

DROP TABLE Dummy;



/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute
 ALTER TABLE TradingRoute ADD Taxes real;
-- 2) Set the derived attribute taxes as 12% of LastYearRevenue
UPDATE TradingRoute SET Taxes = LastYearRevenue * 0.12;
-- 3) Report the operating company and the sum of its taxes group by company.
SELECT OperatingCompany , SUM(Taxes) FROM TradingRoute GROUP BY OperatingCompany;


-- 4.2 What's the longest trading route in parsecs?

-- 1) Create a dummy table RouteLength to store the trading route and their lengths.
CREATE TABLE RouteLength (RouteMonitoringKey SERIAL , RouteTotalDistance real);
-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.
CREATE VIEW EnrichedCallsAt 
     AS 
        SELECT
        CallsAt . MonitoringKey AS MonitoringKey,
        SpaceStation . PlanetID AS PlanetID,
        CallsAt . VisitOrder AS VisitOrder

        FROM SpaceStation
        INNER JOIN CallsAt
        ON  CallsAt . StationID = SpaceStation . StationID;
-- 3) Add the support to execute an anonymous code block as follows;
DO
$$
DECLARE
routeTotalDistance real;
hopPartialDistance real;
routes record;
hops record;
queries text;
BEGIN
FOR routes IN SELECT MonitoringKey FROM TradingRoute
LOOP
queries := 'CREATE OR REPLACE VIEW PortsOfCall AS  '
|| 'SELECT PlanetID, VisitOrder '
|| 'FROM EnrichedCallsAt '
|| 'WHERE MonitoringKey = ' || routes.MonitoringKey
|| 'ORDER BY VisitOrder';
EXECUTE queries;
CREATE OR REPLACE VIEW Hops AS
SELECT p.PlanetID AS PlanetOrigin,
f.PlanetID AS PlanetDestination
FROM PortsOfCall p
INNER JOIN PortsOfCall f on f.VisitOrder = p.VisitOrder - 1;
routeTotalDistance :=0.0;
FOR hops IN SELECT PlanetOrigin, PlanetDestination FROM Hops
   LOOP
   queries := 'SELECT AvgDistance '
   || 'FROM Distance '
   || 'WHERE PlanetOrigin = ' || hops.PlanetOrigin
   || 'AND ' || 'PlanetDestination = ' || hops.PlanetDestination;
   EXECUTE queries INTO hopPartialDistance;
   routeTotalDistance := hopPartialDistance + routeTotalDistance;
   END LOOP;
INSERT INTO RouteLength (RouteMonitoringKey, RouteTotalDistance)
VALUES
(routes.MonitoringKey, routeTotalDistance);
DROP VIEW Hops CASCADE;
DROP VIEW PortsOfCall CASCADE;
END LOOP;
END;
$$; 

-- 4) Within the declare section, declare a variable of type real to store a route total distance.

-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.

-- 6) Within the declare section, declare a variable of type record to iterate over routes.

-- 7) Within the declare section, declare a variable of type record to iterate over hops.

-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.

-- 9) Within the main body section, loop over routes in TradingRoutes

-- 10) Within the loop over routes, get all visited planets (in order) by this trading route.

-- 11) Within the loop over routes, execute the dynamic view

-- 12) Within the loop over routes, create a view Hops for storing the hops of that route. 

-- 13) Within the loop over routes, initialize the route total distance to 0.0.

-- 14) Within the loop over routes, create an inner loop over the hops

-- 15) Within the loop over hops, get the partial distances of the hop. 

-- 16)  Within the loop over hops, execute the dynamic view and store the outcome INTO the hop partial distance.

-- 17)  Within the loop over hops, accumulate the hop partial distance to the route total distance.

-- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).

-- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).

-- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).

-- 21)  Finally, just report the longest route in the dummy table RouteLength.
SELECT RouteMonitoringKey , RouteTotalDistance FROM RouteLength
WHERE RouteTotalDistance = (SELECT MAX(RouteTotalDistance) FROM RouteLength);