CREATE DATABASE SupplierDB8;

USE SupplierDB8;

CREATE TABLE Suppliers (
    SID INT PRIMARY KEY,
    SNAME VARCHAR(50),
    CITY VARCHAR(50)
);

CREATE TABLE Parts (
    PID INT PRIMARY KEY,
    PNAME VARCHAR(50),
    COLOR VARCHAR(20)
);

CREATE TABLE Catalog (
    SID INT,
    PID INT,
    COST INT,
    PRIMARY KEY (SID, PID),
    FOREIGN KEY (SID) REFERENCES Suppliers(SID),
    FOREIGN KEY (PID) REFERENCES Parts(PID)
);



INSERT INTO Suppliers VALUES
(10001, 'Acme Widget', 'Bangalore'),
(10002, 'Johns', 'Kolkata'),
(10003, 'Vimal', 'Mumbai'),
(10004, 'Reliance', 'Delhi');

INSERT INTO Parts VALUES
(20001, 'Book', 'Red'),
(20002, 'Pen', 'Red'),
(20003, 'Pencil', 'Green'),
(20004, 'Mobile', 'Green'),
(20005, 'Charger', 'Black');

INSERT INTO Catalog VALUES
(10001, 20001, 10),
(10001, 20002, 10),
(10001, 20003, 30),
(10001, 20004, 10),
(10001, 20005, 10),
(10002, 20001, 10),
(10002, 20002, 20),
(10003, 20003, 30),
(10004, 20003, 40);

SELECT * FROM Suppliers;
SELECT * FROM Parts;
SELECT * FROM Catalog;


-- Q1. Find the most expensive part overall and the supplier who supplies it.
SELECT P.PID, P.PNAME, S.SNAME, C.COST
FROM Catalog C
JOIN Parts P ON C.PID = P.PID
JOIN Suppliers S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(COST)
    FROM Catalog
);

-- Q2. Find suppliers who do NOT supply any red parts.
SELECT S.SID, S.SNAME
FROM Suppliers S
WHERE NOT EXISTS (
    SELECT *
    FROM Catalog C
    JOIN Parts P ON C.PID = P.PID
    WHERE C.SID = S.SID
    AND P.COLOR = 'Red'
);

-- Q3. Show each supplier and total value of all parts they supply.
SELECT S.SNAME, SUM(C.COST) AS TOTAL_VALUE
FROM Suppliers S
JOIN Catalog C ON S.SID = C.SID
GROUP BY S.SID, S.SNAME;

-- Q4. Find suppliers who supply at least 2 parts cheaper than ₹20.
SELECT S.SNAME
FROM Suppliers S
JOIN Catalog C ON S.SID = C.SID
WHERE C.COST < 20
GROUP BY S.SID, S.SNAME
HAVING COUNT(*) >= 2;

-- Q5. List suppliers who offer the cheapest cost for each part.
SELECT P.PNAME, S.SNAME, C.COST
FROM Catalog C
JOIN Parts P ON C.PID = P.PID
JOIN Suppliers S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MIN(C2.COST)
    FROM Catalog C2
    WHERE C2.PID = C.PID
);
-- Q6. Create a view of the most expensive supplier for each part.
CREATE VIEW ExpensiveSupplier AS
SELECT P.PID, P.PNAME, S.SNAME, C.COST
FROM Catalog C
JOIN Parts P ON C.PID = P.PID
JOIN Suppliers S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(C2.COST)
    FROM Catalog C2
    WHERE C2.PID = C.PID
);

SELECT * FROM ExpensiveSupplier;

-- Q7. Create a trigger to prevent inserting a Catalog cost below 1.
DELIMITER //

CREATE TRIGGER Check_Cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.COST < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cost cannot be below 1';
    END IF;
END //

DELIMITER ;

-- Q8. Create a trigger to set default cost if not provided.

DELIMITER //

CREATE TRIGGER Set_Default_Cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.COST IS NULL THEN
        SET NEW.COST = 1;
    END IF;
END //

DELIMITER ;


-- Check all suppliers
SELECT * FROM Suppliers;

-- Check all parts
SELECT * FROM Parts;

-- Check catalog
SELECT * FROM Catalog;

-- Check view
SELECT * FROM ExpensiveSupplier;

-- Check triggers
SHOW TRIGGERS;