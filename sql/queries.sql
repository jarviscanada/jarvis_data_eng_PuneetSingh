-- =========================
-- SQL Practice Queries
-- Database: exercises
-- Schema: cd
-- =========================

-- Q1: Add a new facility (Spa) to the facilities table
INSERT INTO cd.facilities (
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
)
VALUES (
    9,
    'Spa',
    20,
    30,
    100000,
    800
);

-- Q2: Add a new facility (Spa) with automatically generated facid
INSERT INTO cd.facilities (
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
)
SELECT
    MAX(facid) + 1,
    'Spa',
    20,
    30,
    100000,
    800
FROM cd.facilities;

-- Q3: Fix initial outlay for the second tennis court
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;

-- Q4: Increase price of second tennis court by 10%
DO $$
DECLARE
    temp1 NUMERIC;
    temp2 NUMERIC;
BEGIN
    SELECT membercost, guestcost
    INTO temp1, temp2
    FROM cd.facilities
    WHERE facid = 0;

    UPDATE cd.facilities
    SET membercost = temp1 * 1.1,
        guestcost = temp2 * 1.1
    WHERE facid = 1;
END $$;

-- Q5: Delete all bookings
DELETE FROM cd.bookings;

-- Q6: Remove member 37 who has never made a booking
DELETE FROM cd.members
WHERE memid = 37;

-- Q7: Facilities with member fee less than 1/50th of maintenance
SELECT facid,
       name,
       membercost,
       monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
  AND membercost < monthlymaintenance * 1/50;

-- Q8: Facilities containing the word Tennis
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- Q9: Facilities with ID 1 and 5
SELECT *
FROM cd.facilities
WHERE facid IN (1, 5);

-- Q10: Members who joined after September 2012
SELECT memid,
       surname,
       firstname,
       joindate
FROM cd.members
WHERE joindate >= '2012-09-01';

-- Q11: Combined list of surnames and facility names
SELECT surname
FROM cd.members
UNION
SELECT name
FROM cd.facilities;

-- Q12: Booking start times for David Farrell
SELECT starttime
FROM cd.bookings b
JOIN cd.members m
  ON b.memid = m.memid
WHERE m.firstname = 'David'
  AND m.surname = 'Farrell';

-- Q13: Tennis court bookings on 2012-09-21
SELECT b.starttime,
       f.name
FROM cd.bookings b
JOIN cd.facilities f
  ON b.facid = f.facid
WHERE f.name IN ('Tennis Court 1', 'Tennis Court 2')
  AND b.starttime >= '2012-09-21'
  AND b.starttime < '2012-09-22'
ORDER BY b.starttime;

-- Q14: Members and their recommender
SELECT mems.firstname AS memfname,
       mems.surname AS memsname,
       recs.firstname AS recfname,
       recs.surname AS recsname
FROM cd.members mems
LEFT JOIN cd.members recs
  ON recs.memid = mems.recommendedby
ORDER BY memsname, memfname;

-- Q15: Members who recommended others
SELECT DISTINCT
       rc.firstname,
       rc.surname
FROM cd.members rc
JOIN cd.members mem
  ON mem.recommendedby = rc.memid
ORDER BY rc.surname, rc.firstname;

-- Q16: Members and recommender without joins
SELECT firstname || ' ' || surname AS full_name
FROM cd.members
ORDER BY firstname;

-- Q17: Count recommendations per member
SELECT firstname,
       recommendedby,
       COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY firstname, recommendedby
ORDER BY recommendedby;

-- Q18: Total slots booked per facility
SELECT facid,
       SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

-- Q19: Total slots booked per facility in September 2012
SELECT facid,
       SUM(slots) AS total_slots
FROM cd.bookings
WHERE starttime >= '2012-09-01'
  AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY total_slots;

-- Q20: Slots booked per facility per month in 2012
SELECT facid,
       EXTRACT(MONTH FROM starttime) AS month,
       SUM(slots) AS total_slots
FROM cd.bookings
WHERE starttime >= '2012-01-01'
  AND starttime < '2013-01-01'
GROUP BY facid, month
ORDER BY facid, month;

-- Q21: Members with at least one booking
SELECT COUNT(DISTINCT memid) AS member_count
FROM cd.bookings;

-- Q22: First booking after September 1st 2012
SELECT m.surname,
       m.firstname,
       m.memid,
       MIN(b.starttime) AS starttime
FROM cd.members m
JOIN cd.bookings b
  ON m.memid = b.memid
WHERE b.starttime >= '2012-09-01'
GROUP BY m.surname, m.firstname, m.memid
ORDER BY m.memid;

-- Q23: Member names with total member count
SELECT COUNT(*) OVER (),
       firstname,
       surname
FROM cd.members
ORDER BY joindate;

-- Q24: Numbered list of members by join date
SELECT ROW_NUMBER() OVER (ORDER BY joindate),
       firstname,
       surname
FROM cd.members
ORDER BY joindate;

-- Q25: Facility with highest slots booked
SELECT facid
FROM (
    SELECT facid,
           SUM(slots) AS total,
           RANK() OVER (ORDER BY SUM(slots) DESC) AS rank
    FROM cd.bookings
    GROUP BY facid
) ranked
WHERE rank = 1;

-- Q26: Format member names
SELECT surname || ', ' || firstname AS member_name
FROM cd.members
ORDER BY surname, firstname;

-- Q27: Telephone numbers with parentheses
SELECT memid,
       telephone
FROM cd.members
WHERE telephone LIKE '%(%'
ORDER BY memid;

-- Q28: Count members by starting letter of surname
SELECT SUBSTRING(surname FROM 1 FOR 1) AS letter,
       COUNT(*) AS count
FROM cd.members
GROUP BY letter
ORDER BY letter;
