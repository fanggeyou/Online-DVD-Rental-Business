
CREATE TABLE History(
HistoryId	NUMBER(10)	NOT NULL,
DVDID	NUMBER(16)	NOT NULL,
MemberID NUMBER(12)	NOT NULL,
CopyID	NUMBER(10) NOT NULL,
RentalID NUMBER(16)	NOT NULL,
MembershipId	NUMBER(10)	NOT NULL,
RentalRequestDate DATE NOT NULL,
RentalShippedDate DATE,
RentalReturnedDate DATE,
CONSTRAINT History_HistoryID_PK PRIMARY KEY (HistoryID),
CONSTRAINT History_DVDID_FK FOREIGN KEY (DVDId) REFERENCES DVD(DVDId),
CONSTRAINT History_MemberId_FK FOREIGN KEY (MemberId) REFERENCES Member(MemberId),
CONSTRAINT History_CopyId_FK FOREIGN KEY (CopyId) REFERENCES DVD_Copy(CopyId),
CONSTRAINT History_RentalId_FK FOREIGN KEY (RentalId) REFERENCES Rental(RentalId),
CONSTRAINT History_MembershipId_FK FOREIGN KEY (MembershipId) REFERENCES Membership(MembershipId)
);

CREATE SEQUENCE history_ID --name
START WITH 3
INCREMENT BY 1
NOCACHE;


ALTER TABLE History ADD ChangeType VARCHAR(255);
ALTER TABLE History ADD ChangeTime DATE;


SELECT * FROM History;

----
CREATE OR REPLACE TRIGGER no_delete_history_trg
BEFORE DELETE ON History
BEGIN
  raise_application_error (-20100, 'You can not delete records from this table');
END;

INSERT INTO history(historyid,dvdid,memberid,copyid,rentalid,membershipid,
rentalrequestdate, rentalshippeddate, rentalreturneddate)
VALUES(1,4,1,5,1,1,to_date('02/02/2004','MM/DD/YYYY'),
	to_date('02/02/2004','MM/DD/YYYY'),to_date('02/09/2004','MM/DD/YYYY'));
  
DELETE FROM history WHERE dvdid = 4;
UPDATE history SET changeType = 'INSERT', changetime = SYSDATE WHERE historyid = 1;

----
CREATE OR REPLACE TRIGGER update_shipdate_trg
AFTER UPDATE OF rentalshippeddate, copyid ON Rental
FOR EACH ROW
DECLARE
ms_id NUMBER(10);
BEGIN
    SELECT membershipid INTO ms_id FROM member WHERE memberid = :NEW.memberid;
    INSERT INTO history(historyid,dvdid,memberid,copyid,rentalid,membershipid,
    rentalrequestdate,rentalshippeddate,rentalreturneddate,changetype,changetime)
    VALUES(history_id.NEXTVAL,:OLD.dvdid,:OLD.memberid,:NEW.copyid,:OLD.rentalid,
    ms_id,:OLD.rentalrequestdate,:NEW.rentalshippeddate,:OLD.rentalreturneddate,
    'UPDATE',SYSDATE);
END;

INSERT INTO dvd_copy(copyid,dvdid,copystatus) VALUES(9,7,'Rented');

UPDATE rental SET rentalshippeddate = to_date('03/05/2004','MM/DD/YYYY'), copyid = 9
WHERE rentalid = 10;

SELECT * FROM history;


----
CREATE OR REPLACE TRIGGER update_returndate_trg
AFTER UPDATE OF rentalreturneddate ON Rental
FOR EACH ROW
DECLARE
ms_id NUMBER(10);
BEGIN
    SELECT membershipid INTO ms_id FROM member WHERE memberid = :NEW.memberid;
    INSERT INTO history(historyid,dvdid,memberid,copyid,rentalid,membershipid,
    rentalrequestdate,rentalshippeddate,rentalreturneddate,changetype,changetime)
    VALUES(history_id.NEXTVAL,:OLD.dvdid,:OLD.memberid,:NEW.copyid,:OLD.rentalid,
    ms_id,:OLD.rentalrequestdate,:OLD.rentalshippeddate,:NEW.rentalreturneddate,
    'UPDATE',SYSDATE);
END;


UPDATE rental SET rentalreturneddate = to_date('03/05/2004','MM/DD/YYYY')
WHERE rentalid = 8;

SELECT * FROM history;



----
CREATE OR REPLACE TRIGGER no_more_movie_trg
BEFORE UPDATE OF rentalshippeddate ON Rental
FOR EACH ROW
DECLARE num_onhand NUMBER(10); dvd_num NUMBER(10); PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  SELECT COUNT(memberid) INTO num_onhand
  FROM rental WHERE rentalreturneddate IS NULL AND memberid = :OLD.memberid
  GROUP BY memberid;
  SELECT DVDATTIME INTO dvd_num FROM membership JOIN member 
  ON membership.membershipid = member.membershipid
  WHERE member.memberid = :OLD.memberid;
  IF num_onhand > dvd_num THEN 
    raise_application_error (-20010, 'You have reached monthly DVD limits');
  
  END IF;
END;

DELETE FROM rental WHERE rentalid = 13;

INSERT INTO dvd_copy(copyid,dvdid,copystatus) VALUES(10,5,'Rented');
INSERT INTO dvd_copy(copyid,dvdid,copystatus) VALUES(11,4,'Rented');

INSERT INTO rental(rentalid,memberid,dvdid,rentalrequestdate,rentalshippeddate,
rentalreturneddate,copyid) 
VALUES(11,15,1,to_date('03/08/2004','MM/DD/YYYY'),to_date('03/09/2004','MM/DD/YYYY'),NULL,3);
INSERT INTO rental(rentalid,memberid,dvdid,rentalrequestdate,rentalshippeddate,
rentalreturneddate,copyid) 
VALUES(12,15,5,to_date('03/08/2004','MM/DD/YYYY'),to_date('03/09/2004','MM/DD/YYYY'),NULL,10);
INSERT INTO rental(rentalid,memberid,dvdid,rentalrequestdate,rentalshippeddate,
rentalreturneddate,copyid) 
VALUES(13,15,4,to_date('03/08/2004','MM/DD/YYYY'),NULL,NULL,11);

COMMIT;

SELECT * FROM rental;

UPDATE rental SET rentalshippeddate = to_date('03/10/2004','MM/DD/YYYY')
WHERE rentalid = 13;


----
ALTER TABLE rentalqueue ADD queuerank NUMBER(10);

CREATE OR REPLACE PROCEDURE ADD_QUEUE (
m_id_arg IN NUMBER,
d_id_arg IN NUMBER,
rank_arg IN NUMBER,
m_d OUT VARCHAR)
IS 
BEGIN
  SELECT CONCAT(memberid,dvdid) INTO m_d 
  FROM rentalqueue WHERE memberid = m_id_arg AND dvdid = d_id_arg;
    raise_application_error (-20010, 'You have already added this movie');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    INSERT INTO rentalqueue(memberid, dvdid, dateaddedinqueue, queuerank)
    VALUES(m_id_arg, d_id_arg, SYSDATE, rank_arg);
END;
/



SET SERVEROUTPUT ON
DECLARE
   m_d VARCHAR(20);
BEGIN
  ADD_QUEUE(m_id_arg=>12,d_id_arg=>5,rank_arg=>1,m_d=>m_d);
  
END;
/


SET SERVEROUTPUT ON
DECLARE
  m_d VARCHAR(20);
BEGIN
  ADD_QUEUE(m_id_arg=>3,d_id_arg=>1,rank_arg=>1,m_d=>m_d);
  
END;
/

SELECT * FROM rentalqueue;




----
CREATE OR REPLACE PROCEDURE REMOVE_QUEUE (
m_id_arg IN NUMBER,
d_id_arg IN NUMBER,
rank_num OUT NUMBER)
IS 
BEGIN
  SELECT queuerank INTO rank_num
  FROM rentalqueue WHERE memberid = m_id_arg AND dvdid = d_id_arg;
  DELETE FROM rentalqueue WHERE memberid = m_id_arg AND dvdid = d_id_arg;
  FOR line IN (SELECT memberid, queuerank FROM rentalqueue 
  WHERE memberid = m_id_arg AND queuerank > rank_num) LOOP
  UPDATE rentalqueue SET queuerank := queuerank-1;
  END LOOP;
END;
/


INSERT INTO rentalqueue(memberid, dvdid, dateaddedinqueue, queuerank)
VALUES (1,3,to_date('04/08/2004','MM/DD/YYYY'),1);
INSERT INTO rentalqueue(memberid, dvdid, dateaddedinqueue, queuerank)
VALUES (1,4,to_date('05/16/2004','MM/DD/YYYY'),2);
INSERT INTO rentalqueue(memberid, dvdid, dateaddedinqueue, queuerank)
VALUES (1,6,to_date('05/22/2004','MM/DD/YYYY'),3);

SELECT * FROM rentalqueue;


SET SERVEROUTPUT ON
DECLARE
  rank_num NUMBER(10);
BEGIN
  REMOVE_QUEUE(m_id_arg=>1,d_id_arg=>4,rank_num=>rank_num);
  
END;
/



COMMIT;



