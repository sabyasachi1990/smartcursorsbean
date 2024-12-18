USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[usp_SearchFK]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec dbo.usp_SearchFK 'Common.Company'
CREATE proc [dbo].[usp_SearchFK] 
  @table varchar(256) -- use two part name convention
, @lvl int=0 -- do not change
, @ParentTable varchar(256)='' -- do not change
, @debug bit = 0
as
begin
	set nocount on;
	declare @dbg bit;
	set @dbg=@debug;
	if object_id('tempdb..#tbl', 'U') is null
		create table  #tbl  (id int identity, tablename varchar(256), lvl int, ParentTable varchar(256));
	declare @curS cursor;
	if @lvl = 0
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl, Null;
	else
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl,@ParentTable;
	if @dbg=1	
		print replicate('----', @lvl) + 'lvl ' + cast(@lvl as varchar(10)) + ' = ' + @table;
	
	if not exists (select * from sys.foreign_keys where referenced_object_id = object_id(@table))
		return;
	else
	begin -- else
		set @ParentTable = @table;
		set @curS = cursor for
		select tablename=object_schema_name(parent_object_id)+'.'+object_name(parent_object_id)
		from sys.foreign_keys 
		where referenced_object_id = object_id(@table)
		and parent_object_id <> referenced_object_id; -- add this to prevent self-referencing which can create a indefinitive loop;

		open @curS;
		fetch next from @curS into @table;

		while @@fetch_status = 0
		begin --while
			set @lvl = @lvl+1;
			-- recursive call
			exec dbo.usp_SearchFK @table, @lvl, @ParentTable, @dbg;
			set @lvl = @lvl-1;
			fetch next from @curS into @table;
		end --while
		close @curS;
		deallocate @curS;
	end -- else
	if @lvl = 0
		--update #tbl Set tablename ='Boardroom.[Transaction]' Where tablename='Boardroom.Transaction'
		--update #tbl Set ParentTable ='Boardroom.[Transaction]' Where ParentTable='Boardroom.Transaction'
		select * from #tbl;
	return;
	end


GO
