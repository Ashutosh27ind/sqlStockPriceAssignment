#********** START OF THE ASSIGNMENT ***********
/*
-- MySQL Stock Price Assignment
-- Author : Ashutosh Kumar
-- Date: 12-Dec-2019               */

-- Create new schema for the project to work:
CREATE SCHEMA `Assignment` ;

-- Make the newly created schema as the default schema:
USE Assignment;
SELECT DATABASE();

-- Creating the tables for each company stock data:
-- Validating the BASE tables are created with the names as :bajaj, eicher, hero, infosys, tcs, tvs
-- We are using the MySQL Import Wizard to create table for each stock:
-- (Reference: http://www.mysqltutorial.org/import-csv-file-mysql-table/)
-- Also we will be taking only two columns date and close price from the CSV data file while importing:

#****************************************************************************
#******************Creating temporary tables for each brand: ****************
create table bajaj_temp 
select str_to_date(a.`Date`,'%d-%M-%Y') as `Date`, a.`close price`, 
	    NULL as `20 Day MA` ,
        NULL as `50 Day MA`
from assignment.bajaj a order by `Date`;

create table eicher_temp
select str_to_date(a.`Date`,'%d-%M-%Y') as `Date`, a.`close price`, 
		NULL as `20 Day MA` ,
        NULL as `50 Day MA`
from assignment.eicher a order by `Date`;

create table hero_temp
select str_to_date(a.`Date`,'%d-%M-%Y') as `Date`, a.`close price`, 
		NULL as `20 Day MA` ,
        NULL as `50 Day MA`
from assignment.hero a order by `Date`;

create table infosys_temp
select str_to_date(a.`Date`,'%d-%M-%Y') as `Date`, a.`close price`, 
		NULL as `20 Day MA` ,
        NULL as `50 Day MA`
from assignment.infosys a order by `Date`;

create table tcs_temp
select str_to_date(a.`Date`,'%d-%M-%Y') as `Date`, a.`close price`, 
		NULL as `20 Day MA` ,
        NULL as `50 Day MA`
from assignment.tcs a order by `Date`;

create table tvs_temp
select str_to_date(a.`Date`,'%d-%M-%Y') as `Date`, a.`close price`, 
		NULL as `20 Day MA` ,
        NULL as `50 Day MA`
from assignment.tvs a order by `Date`;
#**********************************************************************************

#**********************************************************************************

###################################### TASK 1 #####################################

#**************Creating tables for each brand from temporary tables: **************
create table bajaj1 
select  a.`Date`, a.`close price`, 
	    avg(a.`close price`) over (order by date rows between 19 preceding and current row)  as `20 Day MA` ,
        avg(a.`close price`) over (order by date rows between 49 preceding and current row) as `50 Day MA`
from assignment.bajaj_temp a order by `Date`;

create table eicher1
select a.`Date`, a.`close price`, 
		avg(a.`close price`) over (order by date rows between 19 preceding and current row)  as `20 Day MA` ,
        avg(a.`close price`) over (order by date rows between 49 preceding and current row) as `50 Day MA`
from assignment.eicher_temp a order by `Date`;

create table hero1
select a.`Date`, a.`close price`, 
		avg(a.`close price`) over (order by date rows between 19 preceding and current row)  as `20 Day MA` ,
        avg(a.`close price`) over (order by date rows between 49 preceding and current row) as `50 Day MA`
from assignment.hero_temp a order by `Date`;

create table infosys1
select a.`Date`, a.`close price`, 
		avg(a.`close price`) over (order by date rows between 19 preceding and current row)  as `20 Day MA` ,
        avg(a.`close price`) over (order by date rows between 49 preceding and current row) as `50 Day MA`
from assignment.infosys_temp a order by `Date`;

create table tcs1
select a.`Date`, a.`close price`, 
		avg(a.`close price`) over (order by date rows between 19 preceding and current row)  as `20 Day MA` ,
        avg(a.`close price`) over (order by date rows between 49 preceding and current row) as `50 Day MA`
from assignment.tcs_temp a order by `Date`;

create table tvs1
select a.`Date`, a.`close price`, 
		avg(a.`close price`) over (order by date rows between 19 preceding and current row)  as `20 Day MA` ,
        avg(a.`close price`) over (order by date rows between 49 preceding and current row) as `50 Day MA`
from assignment.tvs_temp a order by `Date`;
#*******************************************************************************

#*******************************************************************************
#********** Dropping the temp tables as these are no longer needed: ************
drop table if exists bajaj_temp;
drop table if exists eicher_temp;
drop table if exists hero_temp;
drop table if exists infosys_temp;
drop table if exists tcs_temp;
drop table if exists tvs_temp;
#*******************************************************************************

#*******************************************************************************

#################################### TASK 2 ###################################

#*****************************Master Table Creation*****************************
-- Let's create a master table to store the close price of all the six stocks:

create table master_price as 
select b.`Date` as `Date`, b.`close price` as 'Bajaj',  tc.`close price` as 'TCS', tv.`close price` as 'TVS', 
i.`close price` as 'Infosys', e.`close price` as 'Eicher', h.`close price` as 'Hero'
from bajaj1 b, tcs1 tc, tvs1 tv, infosys1 i, eicher1 e, hero1 h
where b.`Date` = tc.`Date`
and tc.`Date` = tv.`Date`
and tv.`Date` = i.`Date`
and i.`Date` = e.`Date`
and e.`Date` = h.`Date`;
#*******************************************************************************

-- validating the data:
select * from master_price order by date desc;

-- As per the assignment instruction "Please note that for the days where it is not possible to calculate the
-- required Moving Averages, it is better to ignore these rows rather than trying to deal with NULL by filling it 
-- with average value as that would make no practical sense."
-- So we will be updating the `20 Day MA` with NULL for less than 20 days and `50 Day MA` with NULL for less than 50 days 
-- as it does not make any sense to keep the moving average for these untill required number of days are reached

-- Turning OFF SQL Safe Update option, so UPDATE can be done without  key in the where clause:
# SET SQL_SAFE_UPDATES = 1;

#************************TABLE UPDATE USING STORED PROCEDURE *********************
drop procedure if exists UPDATE_TABLE;

delimiter |

CREATE PROCEDURE UPDATE_TABLE(in tbname varchar(20) )
BEGIN
 SET @update20day = CONCAT("UPDATE ", concat(tbname,'1'), " set `20 Day MA` = NULL limit 19 " );
 SET @update50day = CONCAT("UPDATE ", concat(tbname,'1'), " set `50 Day MA` = NULL limit 49 " );
 prepare u from @update20day;
 execute u;
 deallocate prepare u;
 prepare up from @update50day;
 execute up;
 deallocate prepare up;

END|
delimiter ;
#**********************************************************************************

#**********************************************************************************
-- Calling the procedure and passing the table names to update NULL for moving average:
call UPDATE_TABLE('bajaj');
call UPDATE_TABLE('eicher');
call UPDATE_TABLE('hero');
call UPDATE_TABLE('infosys');
call UPDATE_TABLE('tcs');
call UPDATE_TABLE('tvs');

#***********************************************************************************

####################################### TASK 3 #####################################

#***********************Generating SIGNAL through STORED PROCEDURE******************
-- Creating tables for the signal to BUY/SELL/HOLD:
-- Creating tables with suffix as "2" for each brand:UPDATE_TABLE

drop procedure if exists CREATE_TABLE_SIGNAL;

delimiter |
CREATE PROCEDURE CREATE_TABLE_SIGNAL(in tbname varchar(20) )
BEGIN
  SET @createtable = CONCAT("CREATE TABLE ", concat(tbname,'2'), " (
select `Date`,`Close Price`,if((signn=sign_change) or (signn is null) or (sign_change is null),'HOLD',if(signn='+','BUY','SELL')) as `Signal`
from(
select `Date`,`Close Price`, if (`20 Day MA` - `50 Day MA` > 0 , '+','-') as signn, lag(if(`20 Day MA` - `50 Day MA` > 0 , '+','-')) over (order by `Date`) as sign_change
from " , concat(tbname,'1') , " ) temp)" );
 prepare c from @createtable;
 execute c;
 deallocate prepare c;
END|
delimiter ;

#***********************************************************************************
#*****************Calling stored procesure to create signal table*******************
call CREATE_TABLE_SIGNAL('bajaj');
call CREATE_TABLE_SIGNAL('eicher');
call CREATE_TABLE_SIGNAL('hero');
call CREATE_TABLE_SIGNAL('infosys');
call CREATE_TABLE_SIGNAL('tcs');
call CREATE_TABLE_SIGNAL('tvs');

#*********************************************************************************

####################################### TASK 4 #####################################

#**************UDF to take the date and return the Signal for Bajaj **************
drop function if exists bajaj_stock_signal;

delimiter //
create function bajaj_stock_signal(input_date date) returns varchar(10) deterministic 
begin
declare signal_temp varchar(5);
select `signal` into signal_temp
from bajaj2
where `Date` = input_date;
return signal_temp;
end
//
delimiter ;

#*******************************************************************************

#***********Calling the function to determine sample signal for a date**********
select bajaj_stock_signal(str_to_date('11-07-2016','%d-%m-%Y')) as 'STOCK SIGNAL';
-- O/p: HOLD 
#*******************************************************************************

#*******************************************************************************
#*************************** END OF THE ASSIGNMENT *****************************

#***********Below SQL queries are for summary and not part of assignment********
select max(Bajaj),max(TCS),max(TVS),max(Infosys),max(Eicher),max(Hero) from master_price;
select avg(Bajaj),avg(TCS),avg(TVS),avg(Infosys),avg(Eicher),avg(Hero) from master_price;


#*******************************************************************************