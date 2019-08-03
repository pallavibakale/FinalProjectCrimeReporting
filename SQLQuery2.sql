create database crime_system

go 

use crime_system

go 


/* Reporter Information table for registration */
/* one to one with tbl_reporter */
create table tbl_contact_reporter(
contact_id int identity(1,1),
primary_no varchar(10) NOT NULL,
secondary_no varchar(10),
land_line varchar(15),
CONSTRAINT PK_contact PRIMARY KEY (contact_id)
);


go 

/* Contains the complete address of the reporter */
/* one to one with tbl_reporter */
create table tbl_address_reporter(
addr_id int identity(1,1),
flat_no varchar(6) ,
street varchar(20) NOT NULL,
landmark varchar(50) ,
city varchar(30) NOT NULL,
pincode int NOT NULL,
CONSTRAINT PK_addr PRIMARY KEY (addr_id)

);

go

/* Contains the information of the crime reporter */
/* one to many with tbl_complaint */
create table tbl_reporter(
rp_id int identity(1,1) NOT NULL ,
repo_name varchar(50) NOT NULL,
repo_aadhar_no varchar(12) NOT NULL, 
date_of_birth DATE NOT NULL,
addr_id int NOT NULL,
contact_id int NOT NULL,
CONSTRAINT PK_reporter PRIMARY KEY (rp_id),
CONSTRAINT FK_reporter_addr FOREIGN KEY(addr_id) REFERENCES tbl_address_reporter(addr_id),
CONSTRAINT FK_reporter_contact FOREIGN KEY (contact_id) REFERENCES tbl_contact_reporter(contact_id)
);

go 


/* Photos table for criminal photo upload */
/* one to one with tbl_criminal */
create table tbl_criminal_photos(
ph_id int identity(1,1),
p_file_name varchar(20),
p_file_data varbinary(MAX),
CONSTRAINT PK_photo PRIMARY KEY(ph_id)
);

go


/* Only  Super-Admin can access following table */
/* Contains the police station address information */

/* one to one with tbl_police_station */
create table tbl_address_police_station(
ps_addr_id int identity(1,1),
flat_no varchar(6) ,
street varchar(20) NOT NULL,
landmark varchar(50) ,
city varchar(30) NOT NULL,
pincode int NOT NULL,
CONSTRAINT PK_ps_addr PRIMARY KEY (ps_addr_id)
);

go 

/* Only  Super-Admin can access following table */
/* Contains the police station information */
create table tbl_police_station(
ps_id int identity(1,1),
police_station_name varchar(50) NOT NULL,
police_station_username  varchar(20) NOT NULL,
police_station_password varchar(20) NOT NULL,
ps_addr_id int not null,
CONSTRAINT PK_ps PRIMARY KEY (ps_id),
CONSTRAINT FK_ps_addr FOREIGN KEY(ps_addr_id) REFERENCES tbl_address_police_station(ps_addr_id)
);

go 



/* Complaint Table Common for reporter and Police-Station */

/* many to many with tbl_criminal */
/* many to one with tbl_reporter */
/* many to one with tbl_police_station */
create table tbl_complaint(
complaint_id int identity(1,1) NOT NULL,
com_type varchar(50) NOT NULL,
com_status varchar(10) NOT NULL,
com_desc varchar(500),
com_date date,
location varchar(50) NOT NULL,
pincode int not null,
rp_id int NOT NULL,
ps_id int NOT NULL,
CONSTRAINT PK_complaint PRIMARY KEY (complaint_id),
CONSTRAINT FK_reporter FOREIGN KEY(rp_id) REFERENCES tbl_reporter(rp_id),
CONSTRAINT FK_police_station FOREIGN KEY(ps_id) REFERENCES tbl_police_station(ps_id),
);

go


/* Criminal Information table for criminal registration */
/* Only police can register criminal */

/* many to many with tbl_complaint */
/* many to one with tbl_police_station */
/* many to one with reporter */
/* one to one with tbl_criminal_photos */
create table tbl_criminal(
criminal_id int identity(1,1),
criminal_name varchar(50),
date_of_birth date,
crime_commited varchar(300),
cases_pending varchar(300),
wanted_level int,
ph_id int,
CONSTRAINT PK_criminal PRIMARY KEY (criminal_id),
CONSTRAINT FK_criminal_photo FOREIGN KEY (ph_id) REFERENCES tbl_criminal_photos(ph_id)
);

go


/* Mapping for complaint and criminal */
/* required as many to many mapping between complaint and criminal */
create table tbl_complaint_criminal_map(
complaint_id int,
criminal_id int,
CONSTRAINT PK_complaint_criminal_map PRIMARY KEY(complaint_id,criminal_id),
CONSTRAINT FK_complaint_map FOREIGN KEY (complaint_id) REFERENCES tbl_complaint(complaint_id),
CONSTRAINT FK_criminal_map FOREIGN KEY (criminal_id) REFERENCES tbl_criminal(criminal_id)
);

go




/* Only  Super-Admin can access following table */
/* Contains the admin login information */
create table tbl_admin(
username varchar(20) NOT NULL,
password varchar(20) NOT NULL,
CONSTRAINT PK_admin PRIMARY KEY (username)
);

go







/***********************************************************************************************************/







/* register reporter */

create procedure registerReporter(
@repo_name  varchar(50), 
@repo_aadhar_no  varchar(12) , 
@date_of_birth  date, 
@flat_no  varchar(6), 
@street  varchar(20), 
@landmark  varchar(50), 
@city  varchar(30), 
@pincode  Int,
@primary_no varchar(10) , 
@secondary_no varchar(10), 
@land_line varchar(15)
)
as 
begin 
insert into tbl_contact_reporter(primary_no,secondary_no,land_line) values(@primary_no  , @secondary_no, @land_line) 
declare @contact_id int = @@identity
insert into tbl_address_reporter(flat_no,street,landmark,city,pincode) values(@flat_no , @street , @landmark , @city , @pincode  )
declare @addr_id int = @@identity
insert into tbl_reporter(repo_name,repo_aadhar_no,date_of_birth,address_id,contact_id) values( @repo_name, @repo_aadhar_no,@date_of_birth,@addr_id,@contact_id)
end;


/********************************************************************/



/* register complaint */

create procedure registerComplaint (
@com_type varchar(50),
@com_status varchar(10),
@com_desc varchar(500),
@com_date date,
@location varchar(50),
@pincode int,
@fk_reporter int,
@fk_police_station int = NULL
) 
as
begin
insert into tbl_complaint(com_type,com_status,com_desc,com_date,location,pincode,fk_reporter,fk_police_station) values (
@com_type,
@com_status,
@com_desc,
@com_date,
@location,
@pincode,
@fk_reporter,
@fk_police_station
)
end;



/****************************************************************/ 



/* register criminal */
/* only for police station */
create procedure registerCriminal
(
@name varchar(50),
@date_of_birth date,
@crime_commited varchar(300),
@cases_pending varchar(300),
@wanted_level int,
@p_file_name varchar(20),
@p_file_data varbinary(MAX)
)
as
begin
insert into photo(p_file_name,p_file_data) values (@p_file_name, @p_file_data)
declare @ph_id int = @@identity
insert into tbl_criminal(name,date_of_birth,crimes_commited,cases_pending,wanted_level,fk_criminal_photo) values 
(@name,@date_of_birth,@crime_commited,@cases_pending,@wanted_level,@ph_id)
end;



/*********************************************************/


/* register police_station */
/* only for super-admin */

create procedure registerPoliceStation (
@police_station_name varchar(50),
@flat_no varchar(6),
@street varchar(20),
@landmark varchar(50),
@city varchar(30),
@pincode int,
@username varchar(20),
@password varchar(20)
) 
as
begin
insert into tbl_address_police_station(flat_no,street,landmark,city,pincode) values 
(@flat_no, @street, @landmark, @city, @pincode)
declare @ps_addr_id int = @@identity
insert into tbl_police_station(police_station_name,police_station_username,police_station_password,fk_ps_addr)
values (@police_station_name,@username,@password,@ps_addr_id);
end;



/*********************************************************/


/* assign complaint to police station */

create procedure assignComplaintToPS(
@complaint_id int,
@pincode int,
@psid int out
)
as
begin

declare @addr_id int = (select ps_addr_id from tbl_address_police_station where pincode = @pincode);
declare @ps_id int = (select ps_id from tbl_police_station where  fk_ps_addr= @addr_id);
update tbl_complaint set fk_police_station = @ps_id where com_id=@complaint_id;
set @psid = (select fk_police_station from tbl_complaint where com_id=@complaint_id);
end;



/********************************************************/


/* assign complaint to criminal */

create procedure assignComplaintToCriminal ( 
@complaint_id int,
@criminal_id int
)
as
begin
insert into tbl_complaint_criminal_mapping values (@complaint_id,@criminal_id);
end;



/********************************************************/



/* change address of reporter */
/* accessed only by reporter */

create procedure changeReporterAddress ( 
@rp_id int,
@flat_no varchar(6),
@street varchar(20),
@landmark varchar(50),
@city varchar(30),
@pincode int
)
as
begin
declare @addrid int = (select address_id from tbl_reporter where rp_id=@rp_id);
update tbl_address_reporter set flat_no=@flat_no,street=@street,landmark=@landmark,city=@city,pincode=@pincode
where addr_id=@addrid;
end; 



/*****************************************************/



/* change contact of reporter */
/* accessed only by reporter */
create procedure changeReporterContact ( 
@rp_id int,
@primary_no varchar(10),
@secondary_no varchar(10),
@land_line varchar(15)
)
as
begin
update tbl_contact_reporter set primary_no=@primary_no,secondary_no=@secondary_no,land_line=@land_line
where contact_id=(select contact_id from tbl_reporter where rp_id=@rp_id);
end;


/***************************************************/


/* change username and password for police station */
/* accessed only by super-admin */
create procedure changePassword (
@username varchar(20),
@password varchar(20)
)
as
begin
update tbl_police_station set police_station_password=@password where police_station_username=@username
end;


/************************************************/


/* change status of complaint */
/* accessed only by police station */
create procedure changeComplaintStatus (
@complaint_id int,
@com_status varchar(10)
)
as
begin
update tbl_complaint set com_status=@com_status where com_id=@complaint_id
end;



/***********************************************/




exec registerReporter 
@repo_name = "pallavi",
@repo_aadhar_no  = "1234567891" , 
@date_of_birth  = "09/11/1996", 
@flat_no = "12", 
@street = "Spring flowers road", 
@landmark = "near krishna corner", 
@city = "pune", 
@pincode = 411008,
@primary_no = "1234567891" , 
@secondary_no = "1234567897", 
@land_line = "123456789456"

select * from tbl_reporter
select * from tbl_contact_reporter
select * from tbl_address_reporter


exec registerCriminal
@name = "suraj",
@date_of_birth = '1980-07-29',
@crime_commited = "purna dabba khane",
@cases_pending = "purna dabba khane",
@wanted_level = 10,
@p_file_name = "suraj.jpeg",
@p_file_data = null

select * from tbl_criminal


exec registerPoliceStation 
@police_station_name = "pashan",
@flat_no = "5",
@street = "pashan road",
@landmark = "pashan circle",
@city = "pune",
@pincode = "411008",
@username = "pashan",
@password = "pashan"

select * from tbl_police_station
select * from tbl_address_police_station

alter table tbl_complaint alter column ps_id int null 

exec registerComplaint
@com_type = "harasment",
@com_status = "in progress",
@com_desc = "students at acts are physically and mentally harassed",
@com_date = '2019-07-29',
@location = "cdac acts",
@pincode = 411008,
@fk_reporter = 1,
@fk_police_station  = null

select * from tbl_reporter;

select * from tbl_complaint

select * from tbl_admin

exec assignComplaintToPS
@complaint_id = 1,
@pincode = 411008,
@psid = null

select * from tbl_complaint

select * from tbl_criminal;

exec assignComplaintToCriminal
@complaint_id = 1,
@criminal_id = 1

select * from tbl_complaint_criminal_mapping

exec registerReporter @repo_name = "ankit",
@repo_aadhar_no  = "1234567890" , 
@date_of_birth  = "09/11/1996", 
@flat_no = "12", 
@street = "Spring flowers road", 
@landmark = "near krishna corner", 
@city = "pune", 
@pincode = 411008,
@primary_no = "1234567893" , 
@secondary_no = "1234567896", 
@land_line = "123456389456"

select * from tbl_reporter

exec changeReporterAddress
@rp_id = 2,
@flat_no = "7",
@street = "Spring flowers road",
@landmark = "near krishna corner",
@city = "pune",
@pincode = 123456

select * from tbl_address_reporter

exec changeReporterContact
@rp_id = 2,
@primary_no = "1111111111",
@secondary_no = null,
@land_line = null

select * from tbl_contact_reporter

alter table tbl_police_station add unique(police_station_username)

select * from tbl_police_station
exec changePassword 
@username = "pashan",
@password = "newpass"

select * from tbl_police_station

select * from tbl_complaint

exec changeComplaintStatus
@complaint_id = 1,
@com_status = "pending"

select * from tbl_complaint