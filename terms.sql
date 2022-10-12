SELECT STVTERM_CODE as "TermCode",
stvterm_code || ' - ' || STVTERM_DESC as "TermDescription";
FROM STVTERM
where stvterm_system_req_ind is null
----
and exists
(select 1 from sgbstdn a,spriden,tbraccd d
where sgbstdn_pidm = spriden_pidm
and spriden_change_ind is null
and d.tbraccd_balance <> 0
and d.tbraccd_term_code = stvterm_code
and tbraccd_pidm = spriden_pidm
and tbraccd_detail_code = 'WCDD'
and sgbstdn_term_code_eff =
(select max(sgbstdn_term_code_eff)
from sgbstdn b
where a.sgbstdn_pidm = b.sgbstdn_pidm
and b.sgbstdn_term_code_eff <= tbraccd_term_code)
and sgbstdn_stst_code like 'W%';
and exists
(select 1
from tbraccd f
where f.tbraccd_pidm = sgbstdn_pidm
and f.tbraccd_detail_code = 'WCDD'
and f.tbraccd_term_code = d.tbraccd_term_code
-- group by f.tbraccd_term_code,f.tbraccd_pidm
-- having count(*) =1
)
and not exists

(
select 1
from tbraccd e
where e.tbraccd_pidm = sgbstdn_pidm
and e.tbraccd_term_code = d.tbraccd_term_code
and tbraccd_detail_code = 'TDFO'
)
)
----
AND stvterm_acyr_code between to_char(sysdate,'YYYY') - 3 and
to_char(sysdate,'YYYY') + 1
UNION
SELECT 'Z',
'All of the Terms'
FROM Dual
ORDER BY 1 desc