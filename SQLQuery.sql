 USE [mydb]
 
 select * from VersionNr
 select * from History                                                                        
 update dbo.VersionNr Set Nr = 0
 DELETE FROM History;

--1)change datatype of param
go
alter procedure change_type (@tableName varchar(15),
 @ColumnName varchar(20),@type varchar(20))
 as
begin

update dbo.VersionNr Set Nr = Nr+1

DECLARE @lastvers int =0
SELECT TOP 1 @lastvers=Version FROM History ORDER BY Version DESC 
print(@lastvers)

DECLARE @versiune int=0
SELECT TOP 1 @versiune = Nr FROM VersionNr

IF @lastvers < @versiune
	BEGIN
	INSERT INTO History(Version,ProcedureName,Param1,Param2,Param3) Values(@versiune,'change_type',@tableName,@ColumnName,@type) 
	END

declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'alter table ' +@tableName +' alter column ' +@ColumnName+ ' '+@type
print(@sqlQuery)
exec(@sqlQuery)

end
go

-- rollback procedure, change datatype back to last version
alter procedure reset_change_type(@tableName Varchar(20),@ColumnName Varchar(20))
AS
	Begin
	update dbo.VersionNr Set Nr = Nr-1

	IF EXISTS(SELECT TOP 1 Param3 FROM History WHERE ProcedureName='change_type'
		AND Version<(SELECT TOP 1 Nr FROM VersionNr) ORDER BY Version DESC)
		BEGIN
			DECLARE @oldType VARCHAR(20)
			SET @oldType=(SELECT TOP 1 Param3 FROM History
						Where ProcedureName='change_type' AND Version<(SELECT TOP 1 Nr FROM VersionNr))
		END
	ELSE
		SET @oldType=(Select TOP 1 Param3 From History
						Where (ProcedureName='change_type' AND Param1=@tableName AND Param2=@ColumnName) OR (ProcedureName='add_column' AND Param1=@tableName AND Param2=@ColumnName) )
	DECLARE @sqlQuery AS VARCHAR(100)
	SET @sqlQuery='ALTER TABLE '+@tableName+' ALTER Column '+@ColumnName+ ' ' +@oldType
	print(@sqlQuery)
	exec(@sqlQuery)
	END

exec change_type 'Utilizator', 'Age','varchar(20)'
exec reset_change_type 'Restaurant', 'Stars' -- rollback

    
--2)add default constraint for a column
go
alter procedure set_default (@tableName varchar(15), @constraint_name varchar(20),
 @ColumnName varchar(20), @default varchar(15))
 as
begin

update dbo.VersionNr Set Nr = Nr+1

DECLARE @lastvers int=0
SELECT TOP 1 @lastvers=Version FROM History ORDER BY Version DESC

DECLARE @versiune int=0
SELECT TOP 1 @versiune = Nr FROM VersionNr

IF @lastvers < @versiune
BEGIN
INSERT INTO History(Version,ProcedureName,Param1,Param2,Param3,Param4) Values(@versiune,'set_default',@tableName,@constraint_name,@ColumnName,@default)
END

declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT ' + @constraint_name + ' DEFAULT ' +  @default + ' FOR ' + @ColumnName
print(@sqlQuery)
exec(@sqlQuery)
end
go

exec set_default 'Utilizator', 'default_n', 'Timp',10


	

--2)rollback, delete default constraint 
go
alter procedure reset_set_default (@tableName varchar(15), --rollback
 @constraint_name varchar(15))
 as
begin

update dbo.VersionNr Set Nr = Nr-1 

declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT ' + @constraint_name
print(@sqlQuery)
exec(@sqlQuery)
end
go

--exec reset_set_default 'Livrator','default_n'


--3) create a table with the given params
go
alter procedure create_table (@tableName varchar(15), @Attribut1 nchar(10), @Attribut1_type nchar(15))
 as
begin

update dbo.VersionNr Set Nr = Nr+1

DECLARE @lastvers int=0
SELECT TOP 1 @lastvers=Version FROM History ORDER BY Version DESC 
--print(@lastvers)

DECLARE @versiune int=0
SELECT TOP 1 @versiune = Nr FROM VersionNr
--print(@versiune)

IF @lastvers < @versiune
BEGIN
	
	INSERT INTO History(Version,ProcedureName,Param1,Param2,Param3) Values(@versiune,'create_table',@tableName,@Attribut1,@Attribut1_type)
	
END

declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'CREATE TABLE ' + @tableName + '( ' + @Attribut1 +' '+ @Attribut1_type +', PRIMARY KEY ('+@Attribut1+') )'
print(@sqlQuery)
exec(@sqlQuery)

end
go

exec create_table 'Utilizator', 'ID_User','int'


--3)rollback, delete given table
go
alter procedure reset_create_table (@tableName varchar(15))
 as
begin

update dbo.VersionNr Set Nr = Nr-1 
declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'DROP TABLE ' + @tableName 
print(@sqlQuery)
exec(@sqlQuery)
end
go

exec reset_create_table 'Utilizator'
  

--4) add a new column with given params
go
alter procedure add_column (@tableName varchar(15), @Attribut nchar(20), @Attribut_type nchar(15))
 as
begin
update dbo.VersionNr Set Nr = Nr+1

DECLARE @lastvers int=0
SELECT TOP 1 @lastvers=Version FROM History ORDER BY Version DESC 
print(@lastvers)

DECLARE @versiune int
SELECT TOP 1 @versiune = Nr FROM VersionNr


IF @lastvers < @versiune
BEGIN

INSERT INTO History(Version,ProcedureName,Param1,Param2,Param3) Values(@versiune,'add_column',@tableName,@Attribut,@Attribut_type)
END

declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD ' + @Attribut +' '+ @Attribut_type
print(@sqlQuery)
exec(@sqlQuery)

end
go

exec add_column 'Utilizator', 'Timpii','float'

   

--4)rollback, delete column
go
 alter procedure reset_add_column (@tableName varchar(15), @Attribut nchar(20))
 as
begin

update dbo.VersionNr Set Nr = Nr-1
declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'ALTER TABLE ' + @tableName + ' DROP COLUMN ' + @Attribut
print(@sqlQuery)
exec(@sqlQuery)
end
go

exec reset_add_column 'Utilizator', 'Timp'

   

--5) add foreign key constraint
go
alter procedure add_FK_constraint (@tableName1 varchar(15), @tableName2 varchar(15), @Attribut1 nchar(15),@Attribut2 nchar(20),@FK_name nchar(15))
 as
begin
update dbo.VersionNr Set Nr = Nr+1

DECLARE @lastvers int=0
SELECT TOP 1 @lastvers=Version FROM History ORDER BY Version DESC 
print(@lastvers)

DECLARE @versiune int=0
SELECT TOP 1 @versiune = Nr FROM VersionNr

IF @lastvers < @versiune
BEGIN
INSERT INTO History(Version,ProcedureName,Param1,Param2,Param3,Param4,Param5) Values(@versiune,'add_FK_constraint',@tableName1,@tableName2,@Attribut1,@Attribut2,@FK_name)
END

declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'ALTER TABLE ' + @tableName1 + ' ADD CONSTRAINT '+ @FK_name  +
' FOREIGN KEY (' + @Attribut1+') REFERENCES '+@tableName2+'('+@Attribut2+')'
print(@sqlQuery)
exec(@sqlQuery)
end
go

--exec add_FK_constraint 'User1', 'Livrator','Id_Livrator','ID_Livrator','abc'



--5)rollback, delete foreign key constraint
go
alter procedure reset_add_FK_constraint (@tableName varchar(15), @FK_name nchar(15))
 as
begin

update dbo.VersionNr Set Nr = Nr-1 

declare @sqlQuery as varchar(MAX)
set @sqlQuery = 'ALTER TABLE ' + @tableName +' DROP CONSTRAINT '+ @FK_name 
print(@sqlQuery)
exec(@sqlQuery)
end
go

exec reset_add_FK_constraint 'Utilizator','abc'



CREATE TABLE VersionNr(
Nr int DEFAULT 0)  --Version 0

Insert into VersionNr(Nr) 
Values (0)


-- table that stores the history of the performed operations
CREATE TABLE History(
Version varchar(5),
ProcedureName varchar(20),
Param1 varchar(20),
Param2 varchar(20),
Param3 varchar(20),
Param4 varchar(20),
Param5 varchar(20))


-- procedure allows user to go from one version to another one by one
-- Do and Undo operations
go
alter procedure gotoVersion (@versiune_dorita int)
as
begin

DECLARE @versiune_curenta int
SELECT TOP 1 @versiune_curenta = Nr FROM VersionNr


DECLARE @query VARCHAR(50)


BEGIN
		IF @versiune_curenta < @versiune_dorita
		BEGIN
				WHILE @versiune_curenta < @versiune_dorita
					BEGIN   
					  
						SET @versiune_curenta=@versiune_curenta+1

						DECLARE @procedure_name VARCHAR(25)
						SELECT @procedure_name= ProcedureName FROM History where Version=@versiune_curenta
						DECLARE @arg1 VARCHAR(15)
						SELECT @arg1= Param1 FROM History where Version=@versiune_curenta
						DECLARE @arg2 VARCHAR(15)
						SELECT @arg2= Param2 FROM History where Version=@versiune_curenta
						DECLARE @arg3 VARCHAR(15)
						SELECT @arg3= Param3 FROM History where Version=@versiune_curenta
						DECLARE @arg4 VARCHAR(15)
						SELECT @arg4= Param4 FROM History where Version=@versiune_curenta
						DECLARE @arg5 VARCHAR(15)
						SELECT @arg5= Param5 FROM History where Version=@versiune_curenta

						IF @procedure_name like '%create_table%'
							exec create_table @arg1,@arg2,@arg3
						IF @procedure_name like '%add_column%'
							exec add_column @arg1,@arg2,@arg3
						IF @procedure_name like '%change_type%'
							exec change_type @arg1,@arg2,@arg3
						IF @procedure_name like '%set_default%'
							exec set_default @arg1,@arg2,@arg3,@arg4
						IF @procedure_name like '%add_FK_constraint%'
							exec add_FK_constraint @arg1,@arg2,@arg3,@arg4,@arg5

						print(@versiune_curenta)	
						
					
					END
		END

		ELSE IF @versiune_curenta > @versiune_dorita
		BEGIN
				WHILE @versiune_curenta > @versiune_dorita
					BEGIN   

					

						DECLARE @procedure_name1 VARCHAR(25)
						SELECT @procedure_name1= ProcedureName FROM History where Version=@versiune_curenta
						DECLARE @argg1 VARCHAR(15)
						SELECT @argg1= Param1 FROM History where Version=@versiune_curenta
						DECLARE @argg2 VARCHAR(15)
						SELECT @argg2= Param2 FROM History where Version=@versiune_curenta
						DECLARE @argg3 VARCHAR(15)
						SELECT @argg3= Param3 FROM History where Version=@versiune_curenta
						DECLARE @argg4 VARCHAR(15)
						SELECT @argg4= Param4 FROM History where Version=@versiune_curenta
						DECLARE @argg5 VARCHAR(15)
						SELECT @argg5= Param5 FROM History where Version=@versiune_curenta

					
					
					IF @procedure_name1 like '%create_table%'
						exec reset_create_table @argg1

					IF @procedure_name1 like '%add_column%'
						exec reset_add_column @argg1,@argg2
					
					IF @procedure_name1 like '%add_FK_constraint%'
						exec reset_add_FK_constraint @argg1,@argg5

					IF @procedure_name1 like '%set_default%'
						exec reset_set_default @argg1,@argg2

					IF @procedure_name1 like '%change_type%'
						exec reset_change_type @argg1,@argg2
	

					SET @versiune_curenta=@versiune_curenta-1
					
				
					END

		END		

END
end
go

exec gotoVersion 5

-- testing

 select * from VersionNr
 select * from History
 update dbo.VersionNr Set Nr = 0
 DELETE FROM History;

 exec create_table 'Utilizator', 'ID_User','int'
 exec add_column 'Utilizator', 'id_Livrator','float'
 exec add_column 'Utilizator', 'Age','char(20)'
 exec add_column 'Utilizator', 'Name','varchar(10)'
 exec set_default 'Utilizator', 'default_na', 'Name','''ana'''
 exec change_type 'Utilizator','Name','varchar(50)'

 exec reset_add_column 'Utilizator', 'Timpiii'
 exec reset_add_column 'Utilizator', 'Timpii'
 exec reset_add_column 'Utilizator', 'Timpi'
 exec reset_add_column 'Utilizator', 'Timp'
 exec reset_create_table 'Utilizator'
 exec reset_set_default 'Utilizator','default_n'


 exec gotoVersion 3