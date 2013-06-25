
select xmlroot(
         xmlconcat(
           xmlpi(name "xml-stylesheet", 'type="text/xsl" href="pgxml2html.xsl"'),
           xmlelement(name database,
             xmlagg(a.schemadef))), version '1.0')
from
(
  select xmlelement(name schema,
           xmlattributes(table_schema,
                         count(*) as n_tables),
           xmlagg(a.tabledef)) as schemadef
  from
  (
    select a.table_schema,
           xmlelement(name table,
             xmlattributes(
               a.table_name,
               c.n_live_tup as n_rows),
             xmlagg(
               xmlelement(name column,
                 xmlattributes(
                   a.column_name,
                   a.column_default,
                   a.is_nullable,
                   case when a.data_type in ('character', 'character varying') then 'char('  || a.character_maximum_length || ')'
                        when a.data_type in ('numeric') then 'decimal(' || a.numeric_precision || ', ' || a.numeric_scale || ')'
                        else a.data_type end as data_type,
                   coalesce(round(b.null_frac * c.n_live_tup), 0) as n_null,
                   b.avg_width,
                   coalesce(round(case when b.n_distinct < 0 then -b.n_distinct * c.n_live_tup else b.n_distinct end), 0) as n_distinct,
                   abs(b.correlation) as correlation),
                 (select xmlagg(
                           xmlelement(name mcv,
                             xmlattributes(mcvs.freq,
                                           round(mcvs.freq * c.n_live_tup) as n),
                             mcvs.val) order by mcvs.freq desc)
                  from (select unnest(b.most_common_vals::text::text[]) as val,
                               unnest(b.most_common_freqs) as freq) as mcvs)) order by a.ordinal_position asc)) tabledef
    from information_schema.columns a
           left join pg_stats b
             on a.table_schema = b.schemaname
             and a.table_name = b.tablename
             and a.column_name = b.attname
           join pg_stat_user_tables c
             on a.table_schema = c.schemaname
             and a.table_name = c.relname
    where c.n_live_tup > 0
    group by a.table_schema,
             a.table_name,
             c.n_live_tup
             order by c.n_live_tup desc
             limit 10
  ) a
  group by table_schema
) a
;


select a.table_schema,
       a.table_name,
       c.n_live_tup as n_rows,
       a.column_name,
       a.column_default,
       a.is_nullable,
       case when a.data_type in ('character', 'character varying') then 'char('  || a.character_maximum_length || ')'
            when a.data_type in ('numeric') then 'decimal(' || a.numeric_precision || ', ' || a.numeric_scale || ')'
            else a.data_type end as data_type,
       round(b.null_frac * c.n_live_tup) as n_null,
       b.avg_width,
       round(case when b.n_distinct < 0 then -b.n_distinct * c.n_live_tup else b.n_distinct end) as n_distinct,
       abs(b.correlation) as correlation
from information_schema.columns a
       left join pg_stats b
         on a.table_schema = b.schemaname
         and a.table_name = b.tablename
         and a.column_name = b.attname
       join pg_stat_user_tables c
         on a.table_schema = c.schemaname
         and a.table_name = c.relname
where a.table_name like 'cpm%'
;
