INSERT INTO plan VALUES(1,'3-at-a-time',17.99,'Up to 3 DVDs at a time');
INSERT INTO plan VALUES(2,'2-at-a-time',11.99, 'Limit 4 DVDs per month');


INSERT INTO customers VALUES(1,'John','Smith',1,'jsmith41','smith@gmail.com',NULL,NULL,1234567654321,222);
INSERT INTO customers VALUES(2,'Lily','Colin',1,'12lilycolin','colin@gmail.com',NULL,NULL,344522345521,444);
INSERT INTO customers
VALUES(3,'Lauren','Kim',NULL,'778kim','lkim@gmail.com',NULL,NULL,2334322188392231,234);
INSERT INTO customers
VALUES(4,'Kelly','Peterson',NULL,'peterson77','kkp@gmail.com',NULL,NULL,2330000188300231,111);


INSERT INTO movie VALUES(1,'X-Men: Days of Future Past',CAST('18-DEC-2015' AS DATE),'Action movie');
INSERT INTO movie VALUES(2,'The Angry Birds Movie',CAST('11-DEC-2016' AS DATE),'Cartoon');
INSERT INTO movie VALUES(3,'Star Wars: Episode 3 - Revenge of the Sith',CAST('20-OCT-2005' AS DATE),'Action movie');
INSERT INTO movie VALUES(4,'A Matter of Faith',CAST('25-JAN-2014' AS DATE),'Story-telling');
INSERT INTO movie VALUES(5,'Star Trek Into Darkness',CAST('16-MAY-2013' AS DATE),'Action movie');
INSERT INTO movie VALUES(6,'Dredd',CAST('12-SEP-2012' AS DATE),'Science fiction movie');
INSERT INTO movie VALUES(7,'The Martian',CAST('2-OCT-2015' AS DATE),'Science fiction movie');


INSERT INTO Queue
VALUES (2,1,1,CAST('30-MAY-2016' AS DATE));
INSERT INTO Queue
VALUES (3,1,2,CAST('30-OCT-2016' AS DATE));
INSERT INTO Queue
VALUES (4,1,3,CAST('15-AUG-2017' AS DATE));


INSERT INTO directors VALUES(1,'George','Lucas');
INSERT INTO directors VALUES(2,'Rich','Christiano');

INSERT INTO direct_movie VALUES(1,3);
INSERT INTO direct_movie VALUES(2,4);

INSERT INTO delivery_services VALUES(1,'UPS');


INSERT INTO department VALUES(1,'Transaction Process');


INSERT INTO employee VALUES(1,'Kelly','Kim',1,'kkim@gmail.com',6667896230);


INSERT INTO rental_transactions VALUES(1,2,1,CAST('25-JAN-2017' AS DATE),2231332114,1);


INSERT INTO dvd_distributor VALUES(1,'PK DVD Distributor','pkdist@gmail.com',7656782521);


INSERT INTO DVD VALUES(1,1,20,1);
INSERT INTO DVD VALUES(2,2,15,1);
INSERT INTO DVD VALUES(3,3,20,1);
INSERT INTO DVD VALUES(4,4,22,1);
INSERT INTO DVD VALUES(5,5,10,1);
INSERT INTO DVD VALUES(6,6,8,1);
INSERT INTO DVD VALUES(7,7,0,1);



INSERT INTO DVD_Rent VALUES(3,1);
INSERT INTO DVD_Rent VALUES(4,1);


commit;