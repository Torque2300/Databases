--6-1
begin;
select balance from _A where login = 'Holya' for update;
select balance from _A where login = 'Bair' for update;
begin;
--6-1