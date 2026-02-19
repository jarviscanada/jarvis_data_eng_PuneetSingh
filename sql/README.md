## Table Setup (DDL)

### Schema: cd

The project uses a schema named `cd` which contains three tables: members, facilities, and bookings.

### Table: cd.members
- **Primary Key:** memid
- Stores member information
- `recommendedby` is a self-referencing foreign key pointing to `members.memid`

### Table: cd.facilities
- **Primary Key:** facid
- Stores facility details and costs

### Table: cd.bookings
- **Primary Key:** bookid
- **Foreign Keys:**
  - facid ? cd.facilities(facid)
  - memid ? cd.members(memid)
- Stores booking records for members and facilities

#### Question 1: Add a new facility (Spa)

```sql

insert into cd.facilities
(facid,Name,membercost,guestcost,initialoutlay,monthlymaintenance)
 values(9,'Spa',20,30,100000,800);
```

#### Question 2: Add a new facility (Spa) with auto-generated facid

```sql
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
```

#### Question 3: We made a mistake when entering the data for the second tennis court

We made a mistake when entering the data for the second tennis court.
The initial outlay was 10000 rather than 8000, so the data needs to be corrected.

```sql
update  cd.facilities
set initialoutlay=10000 
where facid= 1;

```
#### Question 4: Alter the price of the second tennis court

We want to alter the price of the second tennis court so that it costs
10% more than the first one. This is done without using constant values
for the prices so the statement can be reused.

```sql
DO $$

DECLARE
temp1 numeric;
temp2 numeric;

BEGIN

select membercost,guestcost into temp1,temp2 from cd.facilities 
where facid=0;

update cd.facilities 
set 

membercost = temp1 *1.1,
guestcost =temp2 *1.1
where facid=1;

END $$; ```
#### Question 5: Delete all bookings from the bookings table

As part of a clearout of the database, all records from the
`cd.bookings` table need to be removed.

```sql
DELETE FROM cd.bookings;
```

#### Question 6: Remove member 37 who has never made a booking

We want to remove member 37 from the database. Since this member has
never made a booking, the deletion can be safely performed by ensuring
that the member ID does not appear in the bookings table.

```sql
delete from cd.members 
where memid=37
```
#### Question 7: Facilities with member fee less than 1/50th of monthly maintenance

How can you produce a list of facilities that charge a fee to members,
and that fee is less than 1/50th of the monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance
of the facilities in question.

```sql
select facid,name,membercost,monthlymaintenance from cd.facilities 
where membercost>0 AND
membercost <monthlymaintenance* 1/50
```
#### Question 8: List all facilities with the word 'Tennis' in their name

How can you produce a list of all facilities with the word 'Tennis'
in their name?

```sql

select * from cd.facilities
where name like'%Tennis%'

```
#### Question 9: Retrieve details of facilities with ID 1 and 5

How can you retrieve the details of facilities with ID 1 and 5?
This is done without using the OR operator.

```select * from cd.facilities 
where facid in (1,5)

```
#### Question 10: List members who joined after the start of September 2012

How can you produce a list of members who joined after the start of
September 2012? Return the memid, surname, firstname, and joindate
of the members in question.

```sql
select memid, surname,firstname,joindate from cd.members
where joindate>= '2012-09-01';```

#### Question 11: Produce a combined list of all surnames and facility names

You, for some reason, want a combined list of all surnames and all
facility names. Yes, this is a contrived example :-).
Produce that list.

```sql
select surname from cd.members
union
select name from cd.facilities
```
#### Question 12: List booking start times for member David Farrell

How can you produce a list of the start times for bookings
by members named 'David Farrell'?

```sql

select starttime from cd.bookings mem
join cd.members b on mem.memid=b.memid
where b.firstname='David'
and b.surname='Farrell'


```
#### Question 13: List tennis court booking start times for 2012-09-21

How can you produce a list of the start times for bookings for tennis courts,
for the date '2012-09-21'? Return a list of start time and facility name
pairings, ordered by the time.

```sql
select bk.starttime start,fc.name name from cd.bookings bk
join cd.facilities fc
on
bk.facid=fc.facid

where fc.name in ('Tennis Court 1','Tennis Court 2')
and bk.starttime >='2012-09-21' and
bk.starttime <'2012-09-22'
order by bk.starttime;
```

#### Question 14: List all members with their recommender (if any)

How can you output a list of all members, including the individual
who recommended them (if any)? Ensure that results are ordered by
(surname, firstname).

```sql
select mems.firstname as memfname, mems.surname as memsname, recs.firstname as recfname, recs.surname as recsname
	from 
		cd.members mems
		left outer join cd.members recs
			on recs.memid = mems.recommendedby
order by memsname, memfname;
```
#### Question 15: List all members who have recommended another member

How can you output a list of all members who have recommended
another member? Ensure that there are no duplicates in the list,
and that results are ordered by (surname, firstname).

```sql
select distinct 
rc.firstname,
rc.surname 
from cd.members rc
inner join cd.members mem on
mem.recommendedby=rc.memid

order by 
rc.surname,
rc.firstname; 
```
#### Question 16: List all members and their recommender without using joins

How can you output a list of all members, including the individual who
recommended them (if any), without using any joins? Ensure that there are
no duplicates in the list, and that each firstname + surname pairing is
formatted as a column and ordered.

```sql
SELECT
  firstname || ' ' || surname AS full_name
FROM cd.members
order by firstname;
```
#### Question 17: Count the number of recommendations each member has made

Produce a count of the number of recommendations each member has made.
The results are ordered by member ID.

```sql
select firstname,recommendedby, count(*)

from cd.members
where recommendedby is not null
group by firstname
order by recommendedby
```
#### Question 18: List the total number of slots booked per facility

Produce a list of the total number of slots booked per facility.
For now, just produce an output table consisting of facility id
and slots, sorted by facility id.

```sql
select facid, sum(slots) TotalSlots from cd.bookings
where starttime>='2012-09-01' AND
starttime<'2012-10-1'
group by facid
order by TotalSlots

```
#### Question 19: List total slots booked per facility in September 2012

Produce a list of the total number of slots booked per facility
in the month of September 2012. Produce an output table consisting
of facility id and slots, sorted by the number of slots.

```sql
select facid, sum(slots) TotalSlots from cd.bookings
where starttime>='2012-09-01' AND
starttime<'2012-10-1'
group by facid
order by TotalSlots

```
#### Question 20: Total slots booked per facility per month in 2012

Produce a list of the total number of slots booked per facility per month
in the year of 2012. Produce an output table consisting of facility id
and slots, sorted by the id and month.

```sql
select facid,extract(month from starttime) AS month, Sum(slots) TotalSlots from cd.bookings
where starttime>='2012-01-01'AND
starttime<'2013-01-01'
group by facid,month
order by facid,month;  
```
#### Question 21: Count members who have made at least one booking

Find the total number of members (including guests)
who have made at least one booking.

```sql
SELECT COUNT(DISTINCT memid) AS member_count
FROM cd.bookings;

```
#### Question 22: List each member's first booking after September 1st 2012

Produce a list of each member name, id, and their first booking
after September 1st 2012. Order by member ID.

```sql
select mems.surname, mems.firstname, mems.memid, min(bks.starttime) as starttime
	from cd.bookings bks
	inner join cd.members mems on
		mems.memid = bks.memid
	where starttime >= '2012-09-01'
	group by mems.surname, mems.firstname, mems.memid
order by mems.memid; 

```
#### Question 23: List member names with total member count on each row

Produce a list of member names, with each row containing the total member count.
Order by join date, and include guest.

```sql
select count(*) over(), firstname, surname
	from cd.members
order by joindate 
```
#### Question 24: Produce a numbered list of members ordered by join date

Produce a monotonically increasing numbered list of members
(including guests), ordered by their date of joining.
Remember that member IDs are not guaranteed to be sequential.

```sql
select row_number() over(order by joindate), firstname, surname
	from cd.members
order by joindate
```
#### Question 25: Facility with the highest number of slots booked

Output the facility id that has the highest number of slots booked.
Ensure that in the event of a tie, all tieing results get output.

```sql
select facid, total from (
	select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
        	from cd.bookings
		group by facid
	) as ranked
	where rank = 1
```
#### Question 26: Format the names of members

Output the names of all members, formatted as 'Surname, Firstname'.

```sql
SELECT surname || ', ' || firstname AS member_name
FROM cd.members
ORDER BY surname, firstname;

```
#### Question 27: Find telephone numbers with parentheses

You've noticed that the club's member table has telephone numbers
with very inconsistent formatting. You'd like to find all the
telephone numbers that contain parentheses, returning the member ID
and telephone number sorted by member ID.

```sql
SELECT memid,
       telephone
FROM cd.members
WHERE telephone LIKE '%(%'
ORDER BY memid;
```

#### Question 28: Count members by starting letter of surname

You'd like to produce a count of how many members you have whose
surname starts with each letter of the alphabet. Sort by the letter,
and don't worry about printing out a letter if the count is 0.

```sql
select 
substr (mems.surname,1,1) as letter,
count(*) as count 
    from cd.members mems
    group by letter
    order by letter   



```






