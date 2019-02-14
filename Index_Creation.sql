REM
REM DROP INDEXES
REM
DROP INDEX I_MemberName;
DROP INDEX I_PersonName;
DROP INDEX I_DVDTitle;
REM
REM CREATE INDEXES
REM
CREATE INDEX I_MemberName ON Member(MemberFirstName,MemberLastName);
CREATE INDEX I_PersonName ON MoviePerson(PersonFirstName,PersonLastName);
CREATE UNIQUE INDEX I_DVDTitle ON DVD(DVDTitle);

COMMIT;
