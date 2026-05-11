USE health_inspections;

SHOW DATABASES;

SHOW TABLES;

USE health_inspections;

CREATE TABLE Restaurant (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zipcode VARCHAR(20),
    phone VARCHAR(50)
);

CREATE TABLE Inspection (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    inspection_date DATE NOT NULL,
    inspection_type VARCHAR(100),
    score INT,
    inspector_name VARCHAR(255),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
);

CREATE TABLE Violation (
    violation_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50),
    description TEXT
);

CREATE TABLE InspectionViolation (
    inspection_id INT NOT NULL,
    violation_id INT NOT NULL,
    severity VARCHAR(50),
    comments TEXT,
    PRIMARY KEY (inspection_id, violation_id),
    FOREIGN KEY (inspection_id) REFERENCES Inspection(inspection_id),
    FOREIGN KEY (violation_id) REFERENCES Violation(violation_id)
);

CREATE TABLE RawData (
    restaurant_name VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zipcode VARCHAR(20),
    inspection_date DATE,
    inspection_type VARCHAR(100),
    score INT,
    violation_code VARCHAR(50),
    violation_description TEXT,
    severity VARCHAR(50),
    comments TEXT
);

SHOW TABLES;

LOAD DATA LOCAL INFILE 'C:/Users/shahm/Downloads/health.csv'
INTO TABLE RawData
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM RawData;

INSERT INTO Restaurant (name, address, city, state, zipcode)
SELECT DISTINCT restaurant_name, address, city, state, zipcode
FROM RawData;

INSERT INTO Inspection (restaurant_id, inspection_date, inspection_type, score)
SELECT r.restaurant_id, rd.inspection_date, rd.inspection_type, rd.score
FROM RawData rd
JOIN Restaurant r
ON rd.restaurant_name = r.name
AND rd.address = r.address;

INSERT INTO Violation (code, description)
SELECT DISTINCT violation_code, violation_description
FROM RawData
WHERE violation_code IS NOT NULL
AND violation_code <> '';

INSERT INTO InspectionViolation (inspection_id, violation_id, severity, comments)
SELECT i.inspection_id, v.violation_id, rd.severity, rd.comments
FROM RawData rd
JOIN Restaurant r
ON rd.restaurant_name = r.name
AND rd.address = r.address
JOIN Inspection i
ON i.restaurant_id = r.restaurant_id
AND i.inspection_date = rd.inspection_date
JOIN Violation v
ON v.code = rd.violation_code;

SELECT * FROM Restaurant;
SELECT * FROM Inspection;
SELECT * FROM Violation;
SELECT * FROM InspectionViolation;

SELECT COUNT(*) FROM RawData;
SELECT COUNT(*) FROM Restaurant;
SELECT COUNT(*) FROM Inspection;
SELECT COUNT(*) FROM Violation;
SELECT COUNT(*) FROM InspectionViolation;

SELECT *
FROM Restaurant;

SELECT 
    r.name AS restaurant_name,
    r.address,
    i.inspection_date,
    i.inspection_type,
    i.score
FROM Restaurant r
JOIN Inspection i
ON r.restaurant_id = i.restaurant_id;

SELECT 
    r.name AS restaurant_name,
    i.inspection_date,
    v.code,
    v.description,
    iv.severity,
    iv.comments
FROM Restaurant r
JOIN Inspection i ON r.restaurant_id = i.restaurant_id
JOIN InspectionViolation iv ON i.inspection_id = iv.inspection_id
JOIN Violation v ON iv.violation_id = v.violation_id;

CREATE OR REPLACE VIEW RestaurantInspectionSummary AS
SELECT 
    r.name AS restaurant_name,
    r.address,
    r.city,
    r.zipcode,
    i.inspection_date,
    i.inspection_type,
    i.score,
    v.code AS violation_code,
    v.description AS violation_description,
    iv.severity,
    iv.comments
FROM Restaurant r
JOIN Inspection i ON r.restaurant_id = i.restaurant_id
LEFT JOIN InspectionViolation iv ON i.inspection_id = iv.inspection_id
LEFT JOIN Violation v ON iv.violation_id = v.violation_id;


-- For view 
USE health_inspections;

CREATE OR REPLACE VIEW RestaurantInspectionSummary AS
SELECT 
    r.name AS restaurant_name,
    r.address,
    r.city,
    r.zipcode,
    i.inspection_date,
    i.inspection_type,
    i.score,
    v.code AS violation_code,
    v.description AS violation_description,
    iv.severity,
    iv.comments
FROM Restaurant r
JOIN Inspection i ON r.restaurant_id = i.restaurant_id
LEFT JOIN InspectionViolation iv ON i.inspection_id = iv.inspection_id
LEFT JOIN Violation v ON iv.violation_id = v.violation_id;

SELECT *
FROM RestaurantInspectionSummary
LIMIT 20;