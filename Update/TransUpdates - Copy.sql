###Pay count by data_id, month
select data_id,
       posting_month,
       count(distinct pay_id) payment_count
from vwInventory_transactions
where pay_type in (1000,1001,1002,1003)
group by data_id, posting_month;

#PIF amounts
select x.data_id,
       sum(t.pay_amount) PIF_amount
from (select it.data_id
            from vwInventory_transactions it
            where it.pay_type=1001
            group by it.data_id) x
left join vwInventory_transactions t on x.data_id=t.data_id and t.pay_type between 1000 and 1003
group by x.data_id
;
      
-- select t.*,
--        x.pay_amount PIF_amount
-- from invn_view_work.Trans_data_id_month t
-- inner join (select it.data_id, 
--               i.purchase_id,
--               it.posting_month,
--               sum(it.pay_amount) pay_amount
--       from vwInventory_transactions it
--       left join vwInventory i on i.data_id=it.data_id
--       where it.pay_type=1001
--       group by data_id, it.posting_month) x on x.data_id=t.data_id and x.pay_month=t.posting_month
--       ;

#SIF amounts
select x.data_id,
       sum(t.pay_amount) SIF_amount
from (select it.data_id
            from vwInventory_transactions it
            where it.pay_type=1002
            group by it.data_id) x
left join vwInventory_transactions t on x.data_id=t.data_id and t.pay_type between 1000 and 1003
group by x.data_id
;
      
-- select t.*,
--        x.pay_amount SIF_amount
-- from invn_view_work.Trans_data_id_month t
-- inner join (select it.data_id, 
--               i.purchase_id,
--               it.posting_month,
--               sum(it.pay_amount) pay_amount
--       from vwInventory_transactions it
--       left join vwInventory i on i.data_id=it.data_id
--       where it.pay_type=1002
--       group by data_id, it.posting_month) x on x.data_id=t.data_id and x.pay_month=t.posting_month
--       ;

#alter statements
alter table invn_view_work.Trans_data_id_month add column payments INT(2);
alter table invn_view_work.Trans_data_id_month add column PIF_pmt double(20,2);
alter table invn_view_work.Trans_data_id_month add column PIF_amount double(20,2);
alter table invn_view_work.Trans_data_id_month add column SIF_pmt double(20,2);
alter table invn_view_work.Trans_data_id_month add column SIF_amount double(20,2);

#update statements
-- Payment count
update invn_view_work.Trans_data_id_month t 
inner join (select data_id,
                   posting_month,
                   count(distinct pay_id) payment_count
            from vwInventory_transactions
            where pay_type in (1000,1001,1002,1003)
            group by data_id, posting_month) x on t.data_id=x.data_id and t.posting_month=x.posting_month
set t.payments = x.payment_count;

-- PIF Payment
update invn_view_work.Trans_data_id_month t 
inner join (select it.data_id,
                   max(it.posting_month) posting_month
            from vwInventory_transactions it
            where it.pay_type=1001
            group by it.data_id) x on t.data_id=x.data_id and t.posting_month=x.posting_month
set t.PIF_pmt = 1;

-- PIF Amount
update invn_view_work.Trans_data_id_month t 
inner join (select x.data_id,
                   sum(t.pay_amount) PIF_amount
            from (select it.data_id
                  from vwInventory_transactions it
                  where it.pay_type=1001
                  group by it.data_id) x
            left join vwInventory_transactions t on x.data_id=t.data_id and t.pay_type between 1000 and 1003
            group by x.data_id) x on t.data_id=x.data_id and t.PIF_pmt=1
set t.PIF_amount = x.PIF_amount;

-- SIF Payment
update invn_view_work.Trans_data_id_month t 
inner join (select it.data_id,
                   max(it.posting_month) posting_month
            from vwInventory_transactions it
            where it.pay_type=1002
            group by it.data_id) x on t.data_id=x.data_id and t.posting_month=x.posting_month
set t.SIF_pmt = 1;

-- SIF Amount
update invn_view_work.Trans_data_id_month t 
inner join (select x.data_id,
                   sum(t.pay_amount) SIF_amount
            from (select it.data_id
                  from vwInventory_transactions it
                  where it.pay_type=1002
                  group by it.data_id) x
            left join vwInventory_transactions t on x.data_id=t.data_id and t.pay_type between 1000 and 1003
            group by x.data_id) x on t.data_id=x.data_id and t.SIF_pmt=1
set t.SIF_amount = x.SIF_amount;

#Nulls to 0
update invn_view_work.Trans_data_id_month
set payments=0
where payments is null;

update invn_view_work.Trans_data_id_month
set PIF_amount=0
where PIF_amount is null;

update invn_view_work.Trans_data_id_month
set PIF_pmt=0
where PIF_pmt is null;

update invn_view_work.Trans_data_id_month
set SIF_amount=0
where SIF_amount is null;

update invn_view_work.Trans_data_id_month
set SIF_pmt=0
where SIF_pmt is null;