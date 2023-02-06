--A1
select [State] from DIM_LOCATION as dl left join FACT_TRANSACTIONS as ft on dl.IDLocation=ft.IDLocation
where year(date)>=2005
group by [State]

--A2
select top 1 [State],sum(Quantity) 'total' from   DIM_LOCATION as dl left join  FACT_TRANSACTIONS as ft on ft.IDLocation=dl.IDLocation left join DIM_MODEL as dml on dml.IDModel=ft.IDModel
left join DIM_MANUFACTURER as dm on dm.IDManufacturer=dml.IDManufacturer
where Country='US' and Manufacturer_Name='Samsung'
group by [State]
order by total  desc

--A3
select count(IDCustomer) 'Number of Transcaction',ft.IDModel,ZipCode,[State] from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_LOCATION as dl on dl.IDLocation=ft.IDLocation
group by ft.IDModel,[State],ZipCode
order by ft.IDModel asc

--A4
select top 1 Manufacturer_Name 'Cheap Smartphone' from DIM_MODEL as dml left join DIM_MANUFACTURER as dmr on dmr.IDManufacturer=dml.IDManufacturer
where Unit_price= (select min(Unit_price) from DIM_MODEL)
group by Manufacturer_Name

--A5
select top 5 Model_Name,Manufacturer_Name,sum(Quantity)'sales quantity',avg(TotalPrice)'avg price' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_MANUFACTURER as dmr on dmr.IDManufacturer=dml.IDManufacturer
group by Manufacturer_Name,Model_Name
order by [avg price] desc

--A6
select dc.IDCustomer,Customer_Name,YEAR,avg(TotalPrice)'Average Amount' from DIM_CUSTOMER as dc left join  FACT_TRANSACTIONS as ft on dc.IDCustomer=ft.IDCustomer left join DIM_DATE as dd on dd.DATE=ft.Date
where TotalPrice>500 and YEAR(dd.DATE) like 2009
group by dc.IDCustomer,Customer_Name,YEAR

--A7
select m.Model_Name from  (select top 5 Model_Name,YEAR,sum(Quantity)'top quantity' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel  left join DIM_DATE as dd on dd.DATE=ft.Date
where YEAR(dd.DATE)=2008
group by Model_Name,YEAR
order by [top quantity] desc) as m 
left join
(select  top 5 Model_Name,YEAR,sum(Quantity)'top quantity' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_DATE as dd on ft.Date=dd.DATE
where YEAR(dd.DATE)=2009
group by Model_Name,YEAR
order by [top quantity]desc) as mm on m.Model_Name=mm.Model_Name
left join 
(select top 5 Model_Name,YEAR,sum(Quantity)'top quantity' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_DATE as dd on dd.DATE=ft.Date
where YEAR(dd.DATE)=2010 
group by Model_Name,YEAR
order by [top quantity]desc ) as mmm on mm.Model_Name=mmm.Model_Name

--A8
select m.Manufacturer_Name from ( select top 2 Manufacturer_Name,sum(TotalPrice)'top sales' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_MANUFACTURER as dmr on dml.IDManufacturer=dmr.IDManufacturer
where year(Date)=2009
group by Manufacturer_Name
order by [top sales] desc) as m 
left join 
(select top 2 Manufacturer_Name,sum(TotalPrice)'top sales' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_MANUFACTURER as dmr on dml.IDManufacturer=dmr.IDManufacturer
where year(Date)= 2010
group by Manufacturer_Name
order by [top sales]desc) as mm on m.Manufacturer_Name=mm.Manufacturer_Name

--A9
select Manufacturer_Name from (select Manufacturer_Name,sum(TotalPrice)'total' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_MANUFACTURER as dmr on dml.IDManufacturer=dmr.IDManufacturer
where year(Date)=2010
group by Manufacturer_Name) as m 
except
select Manufacturer_Name from (select Manufacturer_Name,sum(TotalPrice)'total' from FACT_TRANSACTIONS as ft left join DIM_MODEL as dml on ft.IDModel=dml.IDModel left join DIM_MANUFACTURER as dmr on dml.IDManufacturer=dmr.IDManufacturer
where year(date)=2009
group by Manufacturer_Name) as mm 

--A10
select TBL1.IDCustomer,TBL1.Customer_Name , TBL1.[Year],TBL1.Avg_Spend,TBL1.Avg_Qty,case when TBL2.[Year] is not null then
((TBL1.Avg_Spend-TBL2.Avg_Spend)/TBL2.Avg_Spend )* 100 
else NULL
end as 'YOY in Average Spend' from
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL1 
left join 
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL2 
on TBL1.IDCustomer=TBL2.IDCustomer and TBL2.[Year]=TBL1.[Year]-1

