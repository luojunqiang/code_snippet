drop trigger trig_ddl_audit;
drop table ddl_audit_log;

create table ddl_audit_log (
    oper_user   VARCHAR2(30),
    oper_time   TIMESTAMP(3),
    oper_type   VARCHAR2(30),
    rejected    VARCHAR2(1),
    obj_owner   VARCHAR2(30),
    obj_type    VARCHAR2(30),
    obj_name    VARCHAR2(30),
    os_user     VARCHAR2(30),
    host        VARCHAR2(30),
    ip_addr     VARCHAR2(30),
    program     VARCHAR2(30),
    inst_name   VARCHAR2(30),
    sql_text    VARCHAR2(1000)
);

create or replace package pkg_audit is
    check_danger_ddl boolean := true;

    procedure disable_check;
    procedure enable_check;
    procedure log_ddl(
        oper_user varchar2,
        oper_type varchar2, 
        obj_owner varchar2, 
        obj_type varchar2, 
        obj_name varchar2, 
        rejected varchar2);
end pkg_audit;
/
show errors

create or replace package body pkg_audit is
    procedure disable_check
    is
    begin
        check_danger_ddl := false;
    end;
    
    procedure enable_check
    is
    begin
        check_danger_ddl := true;
    end;
    
    procedure log_ddl(
        oper_user varchar2,
        oper_type varchar2, 
        obj_owner varchar2, 
        obj_type varchar2, 
        obj_name varchar2, 
        rejected varchar2)
    is
        PRAGMA AUTONOMOUS_TRANSACTION;
        sql_text ora_name_list_t;
        sql_count pls_integer;
        sql_stmt varchar2(1000);
        sql_stmt_len pls_integer := 0;
    begin
        sql_count := ora_sql_txt(sql_text);
        for i in 1..sql_count loop
            sql_stmt := sql_stmt || sql_text(i);
            if length(sql_stmt) >= 1000 then
                sql_stmt := substr(sql_stmt, 1, 1000);
                exit;
            end if;
        end loop;
        
        insert into ddl_audit_log
          (oper_user, oper_time, oper_type, rejected, 
           obj_owner, obj_type, obj_name, os_user, host, 
           ip_addr, program, inst_name, sql_text)
        values(
            oper_user,
            systimestamp,
            oper_type,
            rejected,
            obj_owner,
            obj_type,
            obj_name,
            sys_context('USERENV','OS_USER',30),
            sys_context('USERENV','HOST',30),
            sys_context('USERENV','IP_ADDRESS',30),
            sys_context('USERENV','MODULE',30),
            sys_context('USERENV','INSTANCE_NAME',30),
            sql_stmt --sys_context('USERENV','CURRENT_SQL',1000)
        );
        commit;
    end;
begin
    null;
end pkg_audit;
/
show errors

create or replace trigger trig_ddl_audit
    before ddl on schema 
declare
begin
    if pkg_audit.check_danger_ddl 
        and ora_sysevent in ('DROP', 'TRUNCATE')
        and ora_login_user = ora_dict_obj_owner 
        and ora_dict_obj_type='TABLE' 
        and ora_dict_obj_name not like '%#%'
    then
        pkg_audit.log_ddl(
            ora_login_user,
            ora_sysevent,
            ora_dict_obj_owner,
            ora_dict_obj_type,
            ora_dict_obj_name,
            'Y'
        );
        RAISE_APPLICATION_ERROR(-20999, 'Attempt to '||ora_sysevent||' a production table denied. Please contact DBA!');
    else
        pkg_audit.log_ddl(
            ora_login_user,
            ora_sysevent,
            ora_dict_obj_owner,
            ora_dict_obj_type,
            ora_dict_obj_name,
            'N'
        );
    end if;
end ddl_trigger;
/
show errors

CREATE TABLE TEST
 AS SELECT * FROM DUAL;
drop table test;
rename test to test#;
drop table test#;
select * from ddl_audit_log;
