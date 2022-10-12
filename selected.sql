select spriden_id id,
spriden_last_name lname,
spriden_first_name fname,
spriden_pidm pidm,
sgbstdn_term_code_eff eff_term_code,
sgbstdn_stst_code stst_code,
(select tbraccd_amount
from tbraccd c
where c.tbraccd_pidm = spriden_pidm
and c.tbraccd_term_code =d.tbraccd_term_code
and c.tbraccd_detail_code ='WCDD'
and rownum <2
) account_amount,
d.tbraccd_balance balance,
d.tbraccd_term_code term_code
from sgbstdn a,spriden,tbraccd d--,dbritan.tgzdepo
where sgbstdn_pidm = spriden_pidm
and d.tbraccd_pidm = spriden_pidm
and spriden_change_ind is null
and d.tbraccd_detail_code = 'WCDD'
and (
(d.tbraccd_term_code = :TermSelect.TermCode and :TermSelect.TermCode <> 'Z')
or (d.tbraccd_term_code like '%' and :TermSelect.TermCode = 'Z')
)
and sgbstdn_term_code_eff =
(select max(b.sgbstdn_term_code_eff)
from sgbstdn b
where a.sgbstdn_pidm = b.sgbstdn_pidm
and b.sgbstdn_term_code_eff <= d.tbraccd_term_code

)
and sgbstdn_stst_code like 'W%'
and tbraccd_balance <> 0
and exists
(select count(*)
from tbraccd f
where f.tbraccd_pidm = sgbstdn_pidm
and f.tbraccd_term_code = d.tbraccd_term_code
and f.tbraccd_detail_code = 'WCDD'
group by f.tbraccd_term_code,f.tbraccd_pidm
having count(*) =1
)
and not exists
(select 1
from tbraccd e
where e.tbraccd_pidm = sgbstdn_pidm
and e.tbraccd_term_code = d.tbraccd_term_code
and e.tbraccd_detail_code = 'TDFO'
)

and to_char(spriden_pidm) = :QuickRoster.PIDM
order by spriden_pidm