declare
p_tran_number_out tbraccd.tbraccd_tran_number%TYPE;
p_rowid_out varchar2(18);
pidm_var number(8);

cursor c_record_to_be_inserted is
select spriden_id in_id,
spriden_pidm in_pidm,
tbraccd_term_code in_term_code,
sgbstdn_term_code_eff in_term_code_eff,
sgbstdn_stst_code in_stst_code,
(select c.tbraccd_amount
from tbraccd c
where c.tbraccd_pidm = spriden_pidm
and c.tbraccd_term_code =d.tbraccd_term_code
and c.tbraccd_detail_code ='WCDD'
and rownum <2
) in_amount
from sgbstdn a,spriden,tbraccd d--,dbritan.tgzdepo
where sgbstdn_pidm = spriden_pidm
and spriden_change_ind is null
and :Banner_Insert is not null
and tbraccd_pidm = spriden_pidm
and tbraccd_detail_code = 'WCDD'
and
(
(d.tbraccd_term_code = :TermSelect.TermCode) --and :TermSelect.TermCode <> 'Z')
or (d.tbraccd_term_code like '%' and :TermSelect.TermCode = 'Z')
)

-- and tbraccd_term_code = term_code
and sgbstdn_term_code_eff =
(select max(sgbstdn_term_code_eff)
from sgbstdn b
where a.sgbstdn_pidm = b.sgbstdn_pidm
and b.sgbstdn_term_code_eff <= tbraccd_term_code)
and sgbstdn_stst_code like 'W%'
and exists
(select count(*)
from tbraccd f
where f.tbraccd_pidm = sgbstdn_pidm
--and tbraccd_term_code = '202110'
-- and f. tbraccd_term_code = term_code
and f.tbraccd_detail_code = 'WCDD'
and f.tbraccd_term_code = d.tbraccd_term_code
group by f.tbraccd_term_code,f.tbraccd_pidm
having count(*) =1
)
and not exists
(
select 1
from tbraccd e
where e.tbraccd_pidm = sgbstdn_pidm
and e.tbraccd_term_code = d.tbraccd_term_code
and tbraccd_detail_code = 'TDFO'
)

and spriden_id = :QuickRoster.ID;
-- and spriden_id in (:QuickRoster.ID);

BEGIN
--dbms_output.enable(buffer_size => 1000000); --NULL);
--dbms_output.put_line('This is the beginning');

FOR f_forfeiting_deposit in c_record_to_be_inserted
LOOP
begin
tb_receivable.p_create (
p_pidm => f_forfeiting_deposit.in_pidm,
p_term_code => f_forfeiting_deposit.in_term_code,
p_detail_code => 'TDFO',
p_user => 'IT_USER',
p_amount => f_forfeiting_deposit.in_amount,
p_effective_date => sysdate,
p_trans_date => sysdate,
p_srce_code => 'T',
p_acct_feed_ind => 'Y',
p_data_origin => 'PLSQL',
p_override_hold => 'Y',
p_tran_number_out => p_tran_number_out,
p_rowid_out => p_rowid_out);

exception
when others then
dbms_output.put_line('Pidm cannot be processed:'||pidm_var||':'||SQLCODE||':'||SQLERRM);
end;
end loop;
END;