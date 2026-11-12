
CREATE DATABASE SupplierDB;

USE SupplierDB;

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

-- Q3. Find the pnames of parts for which there is some supplier.--
SELECT DISTINCT P.PNAME
FROM Parts P
JOIN Catalog C ON P.PID = C.PID;

-- Q4. Find the snames of suppliers who supply every part.
SELECT S.SNAME
FROM Suppliers S
WHERE NOT EXISTS (
    SELECT *
    FROM Parts P
    WHERE NOT EXISTS (
        SELECT *
        FROM Catalog C
        WHERE C.SID = S.SID
        AND C.PID = P.PID
    )
);

-- Q5. Find the snames of suppliers who supply every red part.
SELECT S.SNAME
FROM Suppliers S
WHERE NOT EXISTS (
    SELECT *
    FROM Parts P
    WHERE P.COLOR = 'Red'
    AND NOT EXISTS (
        SELECT *
        FROM Catalog C
        WHERE C.SID = S.SID
        AND C.PID = P.PID
    )
);

-- Q6. Find the pnames of parts supplied by Acme Widget Suppliers and by no one else.
SELECT P.PNAME
FROM Parts P
JOIN Catalog C ON P.PID = C.PID
JOIN Suppliers S ON C.SID = S.SID
WHERE S.SNAME = 'Acme Widget'
AND NOT EXISTS (
    SELECT *
    FROM Catalog C2
    WHERE C2.PID = P.PID
    AND C2.SID <> S.SID
);

-- Q7. Find the sids of suppliers who charge more for some part than the average cost of that part.
SELECT DISTINCT C1.SID
FROM Catalog C1
WHERE C1.COST > (
    SELECT AVG(C2.COST)
    FROM Catalog C2
    WHERE C2.PID = C1.PID
);

-- Q8. For each part, find the sname of the supplier who charges the most for that part.
SELECT P.PID, S.SNAME
FROM Catalog C
JOIN Parts P ON C.PID = P.PID
JOIN Suppliers S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(C2.COST)
    FROM Catalog C2
    WHERE C2.PID = C.PID
);