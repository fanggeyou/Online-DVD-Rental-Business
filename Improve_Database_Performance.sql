
--Q1--
CREATE MATERIALIZED VIEW Similar_DVD
REFRESH FORCE  -- review refresh increment
START WITH SYSDATE NEXT SYSDATE+1
WITH PRIMARY KEY
AS
SELECT DVD.DVDTitle AS "DVD Title",  
		SUBSTR(MoviePerson.PersonFirstName,1,10) || ' ' ||
		SUBSTR(MoviePerson.PersonLastName,1,10) AS "Director Name"
FROM DVD, MoviePersonRole, Role, MoviePerson
WHERE DVD.DVDId = MoviePersonRole.DVDId
		AND MoviePersonRole.RoleId = Role.RoleId
		AND MoviePersonRole.PersonId = MoviePerson.PersonId
		AND Role.RoleName = 'Director'
		AND ((MoviePerson.PersonLastName = 'Spielberg') 
		     OR (MoviePerson.PersonLastName = 'Hitchcock' 
		AND MoviePerson.PersonFirstName = 'Alfred'));
;


SELECT DVD.DVDTitle AS "DVD Title",  
		SUBSTR(MoviePerson.PersonFirstName,1,10) || ' ' ||
		SUBSTR(MoviePerson.PersonLastName,1,10) AS "Director Name"
FROM DVD, MoviePersonRole, Role, MoviePerson
WHERE DVD.DVDId = MoviePersonRole.DVDId
		AND MoviePersonRole.RoleId = Role.RoleId
		AND MoviePersonRole.PersonId = MoviePerson.PersonId
		AND Role.RoleName = 'Director'
		AND ((MoviePerson.PersonLastName = 'Spielberg') 
		     OR (MoviePerson.PersonLastName = 'Hitchcock' 
		AND MoviePerson.PersonFirstName = 'Alfred'));
    
--solution    
CREATE INDEX Person_FL ON MoviePerson (PersonFirstName, PersonLastName);  

CREATE INDEX Role_name ON Role (RoleName);

   
SELECT DVD.DVDTitle AS "DVD Title",  
		SUBSTR(MoviePerson.PersonFirstName,1,10) || ' ' ||
		SUBSTR(MoviePerson.PersonLastName,1,10) AS "Director Name"
FROM DVD 
JOIN MoviePersonRole ON DVD.DVDId = MoviePersonRole.DVDId
JOIN Role ON MoviePersonRole.RoleId = Role.RoleId
JOIN MoviePerson ON MoviePersonRole.PersonId = MoviePerson.PersonId
WHERE Role.RoleName = 'Director' AND ((MoviePerson.PersonLastName = 'Spielberg') 
OR (MoviePerson.PersonLastName = 'Hitchcock' 
AND MoviePerson.PersonFirstName = 'Alfred'));


--Q2--
SELECT DVDTitle AS "DVD Title"
FROM DVD 
WHERE DVDId NOT IN 
(SELECT DISTINCT DVDId FROM Rental WHERE MemberId = 123);

--solution
CREATE INDEX DVD_index ON Rental (DVDID);

CREATE INDEX Member_index ON Rental (MemberID);


WITH r AS
(SELECT dvdid FROM rental WHERE memberid = 123
GROUP BY dvdid)
SELECT d.DVDTitle AS "DVD Title"
FROM DVD d LEFT OUTER JOIN r ON d.dvdid = r.dvdid
WHERE r.dvdid IS NULL;



--Q3--
SELECT DVDId, DVDTitle AS "DVD Title"
FROM DVD
WHERE DVDId IN (SELECT DVDId FROM Rental 
			WHERE RentalReturnedDate IS NULL);

--solution
CREATE INDEX Return_Date_index ON Rental (rentalReturnedDate,1);

SELECT dvd.DVDId, dvd.DVDTitle AS "DVD Title"
FROM DVD JOIN rental ON dvd.dvdid = rental.dvdid
WHERE rental.RentalReturnedDate IS NULL;


--Q4--
SELECT SUBSTR(Member.MemberFirstName,1,10) || ' ' || 
		SUBSTR(Member.MemberLastName,1,10) AS Name,
		SUBSTR(Member.MemberAddress,1,30) AS Address, 
		SUBSTR(City.CityName,1,12) AS City,
		SUBSTR(State.StateName,1,12) AS State,
 		Zipcode.ZipCode AS Zip 
FROM Member, City, State, ZipCode 
WHERE Member.MemberFirstName = 'Susan'
AND Member.MemberLastName = 'Smith' 
AND Member.MemberAddressId = ZipCode.ZipCodeId
AND ZipCode.CityId = City.CityId
AND ZipCode.StateId = State.StateId;


--solution
CREATE INDEX Member_name_index ON member (MemberFirstName, MemberLastName);


SELECT SUBSTR(Member.MemberFirstName,1,10) || ' ' || 
		SUBSTR(Member.MemberLastName,1,10) AS Name,
		SUBSTR(Member.MemberAddress,1,30) AS Address, 
		SUBSTR(City.CityName,1,12) AS City,
		SUBSTR(State.StateName,1,12) AS State,
 		Zipcode.ZipCode AS Zip 
FROM Member
JOIN Zipcode ON Member.MemberAddressId = ZipCode.ZipCodeId
JOIN City ON ZipCode.CityId = City.CityId
JOIN State ON ZipCode.StateId = State.StateId
WHERE Member.MemberFirstName = 'Susan'
AND Member.MemberLastName = 'Smith' ;


--Q5--
SELECT DISTINCT DVD.DVDId, DVD.DVDTitle, Genre.GenreName 
FROM Rental, DVD, Genre
WHERE MemberId = 
(SELECT MemberId FROM Member
WHERE MemberFirstName = 'Alfred'
AND MemberLastName = 'Newman')
	AND Rental.DVDId = DVD.DVDId
AND DVD.GenreId = Genre.GenreId
	AND Genre.GenreName = 'Horror';

--solution
CREATE INDEX genre_name_index ON Genre (GenreName);

SELECT DISTINCT DVD.DVDId, DVD.DVDTitle, Genre.GenreName 
FROM Rental
JOIN DVD ON Rental.DVDId = DVD.DVDId
JOIN Genre ON DVD.GenreId = Genre.GenreId
JOIN Member ON rental.memberid = member.memberid
WHERE member.MemberFirstName = 'Alfred'
AND member.MemberLastName = 'Newman'
AND Genre.GenreName = 'Horror';



--Q6--
CREATE VIEW DVDView AS 
		SELECT DVDId, DVDTitle, Genre.GenreName AS Genre, 
			Rating.RatingName AS Rating
		FROM DVD, Genre, Rating 
		WHERE DVD.GenreId = Genre.GenreId
		AND DVD.RatingId = Rating.RatingId;

--solution
CREATE INDEX dvd_genre_index ON DVD (GenreId);
CREATE INDEX dvd_rating_index ON DVD (RatingId);


CREATE VIEW DVDView AS 
		SELECT DVDId, DVDTitle, Genre.GenreName AS Genre, 
			Rating.RatingName AS Rating
		FROM DVD
    JOIN Genre ON DVD.GenreId = Genre.GenreId
    JOIN Rating ON DVD.RatingId = Rating.RatingId;



--Q7--
CREATE OR REPLACE PROCEDURE Lost_DVD -- P prefix denotes parameters
(P_RentalId IN NUMBER, -- The rental for which DVD was lost
	P_MemberId IN NUMBER, -- The member
	P_Amount IN NUMBER, -- The amount to charge
	P_Trans_Date IN DATE) --The transaction date and time
AS -- The V prefix denotes variables.
V_DVDId NUMBER := 0.0;
V_PaymentId NUMBER := 0;
V_UntilDate DATE := NULL;

BEGIN

-- Get DVDId
      SELECT DVDId into V_DVDId From RENTAL WHERE RentalId = P_RentalId;

-- Get PaymentId
       SELECT COUNT(*)+1 into V_PaymentId FROM Payment;
	
-- Get AmountPaidUntilDate
	SELECT AmountPaidUntilDate INTO V_UntilDate FROM Payment 
		WHERE MemberId = P_MemberId
AND PaymentId = 
(SELECT MAX(PaymentId) FROM Payment WHERE MemberId=P_MemberId);

-- Now, make the changes to the database…
INSERT INTO Payment(PaymentId, MemberId, AmountPaid,
     	AmountPaidDate,AmountPaidUntilDate)
	VALUES(V_PaymentId,P_MemberId,P_Amount,P_Trans_Date,V_UntilDate);


UPDATE Rental SET RentalReturnedDate = P_Trans_Date
WHERE RentalId = P_RentalId;

UPDATE DVD SET DVDQuantityOnRent = DVDQuantityOnRent - 1
WHERE DVDId = V_DVDId;

UPDATE DVD SET DVDLostQuantity = DVDLostQuantity + 1
WHERE DVDId = V_DVDId;

END Lost_DVD;
--solution
CREATE SEQUENCE payment_ID --name
START WITH 17
INCREMENT BY 1
NOCACHE;

CREATE OR REPLACE PROCEDURE Lost_DVD -- P prefix denotes parameters
(P_RentalId IN NUMBER, -- The rental for which DVD was lost
	P_MemberId IN NUMBER, -- The member
	P_Amount IN NUMBER, -- The amount to charge
	P_Trans_Date IN DATE) --The transaction date and time
AS -- The V prefix denotes variables.
V_DVDId NUMBER := 0.0;
V_UntilDate DATE := NULL;
BEGIN
-- Get DVDId
      SELECT DVDId into V_DVDId From RENTAL WHERE RentalId = P_RentalId;
-- Get AmountPaidUntilDate
	SELECT p1.AmountPaidUntilDate INTO V_UntilDate FROM Payment p1
		JOIN Member ON p1.memberid = member.memberid
    LEFT OUTER JOIN Payment p2 ON p1.memberid = p2.memberid
    WHERE member.MemberId = 1
    AND p1.paymentid > p2.paymentid;
-- Now, make the changes to the database…
INSERT INTO Payment(PaymentId, MemberId, AmountPaid,
     	AmountPaidDate,AmountPaidUntilDate)
	VALUES(payment_ID.NEXTVAL,P_MemberId,P_Amount,P_Trans_Date,V_UntilDate);

UPDATE Rental SET RentalReturnedDate = P_Trans_Date
WHERE RentalId = P_RentalId;

UPDATE DVD SET DVDQuantityOnRent = DVDQuantityOnRent - 1
WHERE DVDId = V_DVDId;

UPDATE DVD SET DVDLostQuantity = DVDLostQuantity + 1
WHERE DVDId = V_DVDId;

END Lost_DVD;



SELECT p1.AmountPaidUntilDate FROM Payment p1
		JOIN Member ON p1.memberid = member.memberid
    LEFT OUTER JOIN Payment p2 ON p1.memberid = p2.memberid
    WHERE member.MemberId = 1
    AND p1.paymentid > p2.paymentid;



COMMIT;
