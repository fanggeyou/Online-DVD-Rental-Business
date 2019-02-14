--Use Case #1a
CREATE OR REPLACE PROCEDURE RENT_MOVIE( -- Rent a new movie
rt_id_arg IN DECIMAL, -- The new rental id
cus_id_arg IN DECIMAL, -- The new customer if
del_id_arg IN DECIMAL, -- The new deliver id
rt_date_arg IN DATE,-- The new rental date
track_num_arg IN DECIMAL,-- The new tracking number
em_id_arg IN DECIMAL,-- The new employee id
d_id_arg IN DECIMAL)-- The new dvd id
IS -- Required by the syntax, but it doesn¡¯t do anything in particular
BEGIN
INSERT INTO RENTAL_TRANSACTIONS
(rent_id,cust_id,deliver_id,rent_date,tracking_num,emp_id)
VALUES(rt_id_arg,cus_id_arg,del_id_arg,rt_date_arg,track_num_arg,em_id_arg);
INSERT INTO DVD_RENT
(dvd_id,rent_id)
VALUES(d_id_arg,rt_id_arg);
END;
/


BEGIN
RENT_MOVIE(2,1,1,CAST('25-OCT-2017' AS DATE),2256673822,1,1);
END;
/

BEGIN
RENT_MOVIE(3,1,1,CAST('25-OCT-2017' AS DATE),2256778522,1,2);
END;
/


SELECT *
FROM RENTAL_TRANSACTIONS;


SELECT * 
FROM DVD_RENT;

-- Use Case #1b
SELECT Movie.movie_name
FROM Movie
JOIN Direct_Movie dm ON dm.movie_id = movie.movie_id
JOIN Directors ON dm.direct_id = directors.direct_id
WHERE directors.direct_fname = 'George' OR directors.direct_fname = 'Rich' AND 
movie.movie_id IN
(SELECT movie.movie_id
FROM Movie
JOIN DVD ON dvd.movie_id = movie.movie_id
JOIN DVD_Rent ON dvd_rent.dvd_id = dvd.dvd_id
JOIN Rental_Transactions rt ON rt.rent_id = dvd_rent.rent_id
JOIN Customers ON customers.cust_id = rt.cust_id
WHERE customers.cust_id = 2);

-- USE CASE #2a
CREATE OR REPLACE PROCEDURE ADD_QUEUE( -- Add a queue
que_id_arg IN DECIMAL, -- The new queue id
c_id_arg In DECIMAL, -- The new customer id
m_id_arg IN DECIMAL, -- The new movie id
add_date_arg IN DATE, -- The new adding date
re_id_arg IN DECIMAL, -- The new rental id
d_id_arg IN DECIMAL, -- The new deliver id
re_date_arg IN DATE, -- The new rental date
t_num_arg IN DECIMAL, -- The new tracking num
e_id_arg IN DECIMAL) -- The new employee id
IS 
BEGIN
INSERT INTO Queue
(queue_id, cust_id, movie_id, add_date)
VALUES(que_id_arg,c_id_arg,m_id_arg,add_date_arg);
INSERT INTO Rental_Transactions
(rent_id,cust_id,deliver_id,rent_date,tracking_num,emp_id)
VALUES(re_id_arg,c_id_arg,d_id_arg,re_date_arg,t_num_arg,e_id_arg);
END;
/



BEGIN
ADD_QUEUE(1,1,4,CAST('20-NOV-2017' AS DATE),
4,1,CAST('21-NOV-2017' AS DATE),24443145664,1);
END;
/


SELECT *
FROM Queue;



SELECT *
FROM rental_transactions;

-- Use Case #2b
SELECT movie_name FROM
(SELECT movie.movie_name, queue.add_date, rank() over 
(ORDER BY queue.add_date DESC) as rnk
FROM Movie
JOIN Queue ON movie.movie_id = queue.movie_id)
WHERE rnk <= 3;



-- USE CASE #3a 
CREATE OR REPLACE PROCEDURE ENROLL_PLAN( -- Enroll in a plan
c_id_arg IN DECIMAL, -- The new customer id
p_id_arg IN DECIMAL) -- The new plan id
IS 
BEGIN
UPDATE Customers SET plan_id = p_id_arg WHERE cust_id = c_id_arg;
END;
/


BEGIN
ENROLL_PLAN(3,1);
END;
/
BEGIN
ENROLL_PLAN(4,2);
END;
/


SELECT *
FROM Customers;

-- USE Case #3b
SELECT customers.cust_fname,customers.cust_lname
FROM Customers
JOIN Plan ON plan.plan_id = customers.plan_id
WHERE plan.plan_name = '2-at-a-time';

-- Use Case #4a
CREATE OR REPLACE PROCEDURE ADD_Quantity( -- Add copies of DVD
movie_name_arg IN VARCHAR, -- The new movie name
quantity_arg In DECIMAL) -- The new quantity acquired
IS 
BEGIN
UPDATE DVD SET quantity = quantity + quantity_arg WHERE movie_id = 
(SELECT movie_id FROM Movie WHERE movie_name = movie_name_arg);
END;
/


SELECT movie.movie_name, dvd.quantity
FROM DVD
JOIN Movie ON movie.movie_id = dvd.movie_id
WHERE movie.movie_name = 'Star Trek Into Darkness';



BEGIN
ADD_QUANTITY('Star Trek Into Darkness',3);
END;
/


SELECT *
FROM DVD;


SELECT movie.movie_name, dvd.quantity
FROM DVD
JOIN Movie ON movie.movie_id = dvd.movie_id
WHERE movie.movie_name = 'Star Trek Into Darkness';



SELECT movie.movie_name, dvd.quantity
FROM DVD
JOIN Movie ON movie.movie_id = dvd.movie_id
WHERE movie.movie_name = 'Dredd';


BEGIN
ADD_QUANTITY('Dredd',2);
END;
/

SELECT movie.movie_name, dvd.quantity
FROM DVD
JOIN Movie ON movie.movie_id = dvd.movie_id
WHERE movie.movie_name = 'Dredd';


SELECT *
FROM DVD;

-- Use Case #4b
SELECT movie.movie_name, dvd.quantity
FROM DVD
JOIN Movie ON movie.movie_id = dvd.movie_id
WHERE dvd.quantity = 0;


--Use Case #5a
CREATE OR REPLACE PROCEDURE UPDATE_DVD( -- Update copies of DVD
return_id_arg IN DECIMAL, -- The new movie name
c_id_arg IN DECIMAL, -- The new customer id
re_date_arg IN DATE, -- The new return date
de_id_arg IN DECIMAL, -- The new deliver id
t_num_arg IN VARCHAR, -- The new tracking number
emp_id_arg IN DECIMAL, -- The new employee id
dvd_id_arg IN DECIMAL, -- The new dvd id
q_arg In DECIMAL) -- The new quantity
IS 
BEGIN
INSERT INTO Return_Transactions
(return_id, cust_id, return_date, deliver_id, tracking_num, emp_id)
VALUES(return_id_arg,c_id_arg,re_date_arg,de_id_arg,t_num_arg,emp_id_arg);
INSERT INTO DVD_Return (dvd_id, return_id) VALUES(dvd_id_arg,return_id_arg);
UPDATE DVD SET quantity = quantity + q_arg WHERE dvd_id = dvd_id_arg;
END;
/


BEGIN
UPDATE_DVD(1,2,CAST('10-NOV-2017' AS DATE),1,'3389YHDA23',1,3,1);
END;
/

BEGIN
UPDATE_DVD(2,2,CAST('10-NOV-2017' AS DATE),1,'33895YSA23',1,4,1);
END;
/


SELECT * FROM DVD;


SELECT * FROM DVD_Return;


SELECT * FROM Return_Transactions;

-- Use Case #5b
SELECT customers.cust_id, customers.cust_fname, customers.cust_lname, movie.movie_name
FROM Movie
JOIN DVD ON movie.movie_id = dvd.movie_id
JOIN DVD_Return ON dvd_return.dvd_id = dvd.dvd_id
JOIN Return_Transactions ON return_transactions.return_id = dvd_return.return_id
JOIN Customers ON customers.cust_id = return_transactions.cust_id
WHERE Customers.cust_id = 2;


COMMIT;
