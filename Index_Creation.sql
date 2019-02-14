-- Additional Index
CREATE INDEX D_FNEX ON Directors(direct_fname);
CREATE INDEX D_LNEX ON Directors(direct_lname);
CREATE INDEX ADD_DATEX ON Queue(add_date);
CREATE UNIQUE INDEX P_NAMEX ON Plan(plan_name);
CREATE INDEX M_NAMEX ON Movie(movie_name);
CREATE INDEX QUANT_EX ON DVD(quantity);


-- Index Foreign Keys
CREATE INDEX P_IDEX ON Customers(plan_id);
CREATE INDEX C_IDEX ON Queue(cust_id);
CREATE INDEX M_IDEX ON Queue(movie_id);

CREATE INDEX A_IDEX ON Act_Movie(actor_id);
CREATE INDEX AM_IDEX ON Act_Movie(movie_id);
CREATE INDEX DM_IDEX ON Direct_Movie(movie_id);
CREATE INDEX D_IDEX ON Direct_Movie(direct_id);
CREATE INDEX PRO_IDEX ON Produce_Movie(pro_id);
CREATE INDEX PM_IDEX ON Produce_Movie(movie_id);

CREATE INDEX DVDM_IDEX ON DVD(movie_id);
CREATE INDEX DVDD_IDEX ON DVD(dist_id);
CREATE INDEX RETURND_IDEX ON DVD_Return(dvd_id);
CREATE INDEX RETURNR_IDEX ON DVD_Return(return_id);
CREATE INDEX RT_C_IDEX ON Return_Transactions(cust_id);
CREATE INDEX RT_E_IDEX ON Return_Transactions(emp_id);
CREATE INDEX RT_D_IDEX ON Return_Transactions(deliver_id);
CREATE INDEX RNT_C_IDEX ON Rental_Transactions(cust_id);
CREATE INDEX RNT_E_IDEX ON Rental_Transactions(emp_id);
CREATE INDEX RNT_D_IDEX ON Rental_Transactions(deliver_id);

CREATE INDEX RENTD_IDEX ON DVD_Rent(dvd_id);
CREATE INDEX RENTR_IDEX ON DVD_Rent(rent_id);
CREATE INDEX DEPART_IDEX ON Employee(depart_id);


commit;
