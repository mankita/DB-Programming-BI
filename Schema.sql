
use MetroAlt

--Select * from Position

go
Create schema Emp_DriverSchema;
go


--View to check shift and Route Details for every Driver on any date

Create view Emp_DriverSchema.Driver_PerDayRouteDetails
As
Select distinct e.EmployeeKey, e.EmployeeFirstName,e.EmployeeLastName, bs.BusScheduleAssignmentDate, bs.BusRouteKey, BusKey,BusRouteZone, BusDriverShiftName
from Employee e
inner join BusScheduleAssignment bs
on e.EmployeeKey = bs.EmployeeKey
inner join BusDriverShift bd
on bs.BusDriverShiftKey = bd.BusDriverShiftKey
inner join BusRoute  bsr
on bs.BusRouteKey = bsr.BusRouteKey
go

select * from Driver_PerDayRouteDetails
go

--Procedure 1
create proc Emp_DriverSchema.usp_DriverRouteDetails
@employeekey int,
@BusScheduleAssignmentDate date
as
Select distinct e.EmployeeKey, e.EmployeeFirstName,e.EmployeeLastName, bs.BusScheduleAssignmentDate, bs.BusRouteKey, BusKey,BusRouteZone, BusDriverShiftName
from Employee e
inner join BusScheduleAssignment bs
on e.EmployeeKey = bs.EmployeeKey
inner join BusDriverShift bd
on bs.BusDriverShiftKey = bd.BusDriverShiftKey
inner join BusRoute  bsr
on bs.BusRouteKey = bsr.BusRouteKey
 where @employeekey= e.EmployeeKey and @BusScheduleAssignmentDate= bs.BusScheduleAssignmentDate

 exec Emp_DriverSchema.usp_DriverRouteDetails 1, '2014-02-01'

 --Procedure 2
create proc Emp_DriverSchema.[usp_BusRoute]
@BusKey int,
@BusStopCity NVARCHAR(255)
As
Select distinct bsa.BusKey, BusStopAddress, BusStopCity, BusStopZipCode
from BusStop bs
inner join BusRouteStops brs
on bs.BusStopKey = brs.BusStopKey
inner join BusScheduleAssignment bsa
on bsa.BusRouteKey = brs.BusRouteKey
where @BusKey=BusKey and @BusStopCity=BusStopCity


exec Emp_DriverSchema.[usp_BusRoute] 5, 'Seattle' 

--View 3
Create view Emp_DriverSchema.Driver_PerYearDriverEarning
as
select count(BusDriverShiftKey) [TotalShifts],  ep.EmployeeKey, 
Year(BusScheduleAssignmentDate) [Year], (count(BusDriverShiftKey) * EmployeeHourlyPayRate * 8) as TotalEarned from BusScheduleAssignment bss
inner join EmployeePosition ep
on ep.EmployeeKey = bss.EmployeeKey
inner join Employee e
on e.EmployeeKey = ep.EmployeeKey
group by ep.EmployeeKey, Year(BusScheduleAssignmentDate), EmployeeHourlyPayRate

Select * from  Emp_DriverSchema.Driver_PerYearDriverEarning



--Procedure 3
create proc  Emp_DriverSchema.[usp_DriverEarning]
@DriverKey int,
@Year int,
@hiredate date
as
select count(BusDriverShiftKey) [TotalShifts],  ep.EmployeeKey, 
Year(BusScheduleAssignmentDate) [Year], (count(BusDriverShiftKey) * EmployeeHourlyPayRate * 8) as TotalEarned from BusScheduleAssignment bss
inner join EmployeePosition ep
on ep.EmployeeKey = bss.EmployeeKey
inner join Employee e
on e.EmployeeKey = ep.EmployeeKey
--where @DriverKey = ep.EmployeeKey and @Year= Year(BusScheduleAssignmentDate) and @hiredate= EmployeeHireDate
group by ep.EmployeeKey, Year(BusScheduleAssignmentDate), EmployeeHourlyPayRate

--Driver Earning Per Year
exec Emp_DriverSchema.[usp_DriverEarning] 1,2014,'1998-04-14'


--Creating role and assigning permissions


 Create role DriverRole
--1
Grant Select on Schema::Emp_DriverSchema to DriverRole
--2
Grant Execute on Emp_DriverSchema.[usp_BusRoute] to  DriverRole
--3

--Create a stored procedure that lets a manager update an Employee's information.
--on Manager Schema

Create proc ManagerSchema.usp_EmployeeUpdateAddress
@EmployeeKey int,
@EmployeeLastName nvarchar(255) = null, 
@EmployeeFirstName nvarchar(255), 
@EmployeeAddress nvarchar(255), 
@EmployeeCity nvarchar(255), 
@ZipCode nchar(11), 
@Phone int,
@Email nvarchar(255),
@HireDate date
As
Update Employee
Set 
EmployeeLastName=@EmployeeLastName,
EmployeeFirstName=@EmployeeFirstName,
EmployeeAddress=@EmployeeAddress, 
EmployeeCity=@EmployeeCity,
EmployeeZipCode=@ZipCode,
EmployeePhone=@Phone, 
EmployeeEmail=@Email, 
EmployeeHireDate=@HireDate
Where EmployeeKey =@EmployeeKey 

Select * from Employee

Exec ManagerSchema.usp_EmployeeUpdateAddress
@EmployeeKey =2,
@EmployeeLastName = 'Norr',
@EmployeeFirstName = 'Kevin',
@EmployeeAddress = '523, Broadway E',
@EmployeeCity = 'Seattle',
@ZipCode =98102,
@Phone =206356991,
@Email='kevin.norr@metroalt.com',
@HireDate='2013-07-15'

--Create a stored procedure that assigns a driver to a route for a day. 
--select * from BusScheduleAssignment
Create proc ManagerSchema.usp_InsertDriverRoute
@BusScheduleAssignmentKey int, 
@BusDriverShiftKey int, 
@EmployeeKey int, 
@BusRouteKey int, 
@BusScheduleAssignmentDate date, 
@BusKey int
As
Insert into BusScheduleAssignment
(EmployeeKey,BusScheduleAssignmentKey, BusDriverShiftKey,BusRouteKey,BusScheduleAssignmentDate,BusKey)
values(@EmployeeKey,@BusScheduleAssignmentKey, @BusDriverShiftKey, @BusRouteKey,  @BusScheduleAssignmentDate, @BusKey)


--Create a stored procedure that returns how many hours an employee worked during two dates. 


alter proc ManagerSchema.usp_EmployeeHours
@employeekey int,
@begindate date,
@enddate date
as
select e.EmployeeKey,count(BusDriverShiftKey) [TotalShifts],(count(BusDriverShiftKey) * 8) [TotalHours]
from BusScheduleAssignment bs
inner join Employee e
on e.employeeKey = bs.EmployeeKey
where 
e.EmployeeKey =@employeekey and BusScheduleAssignmentDate between @begindate and @enddate
group by e.EmployeeKey

exec ManagerSchema.usp_EmployeeHours
'6', '2012-01-04','2012-01-10'

























