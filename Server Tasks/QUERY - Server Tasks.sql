SELECT
    BATCH.ROW_ID,
    ACT.DISPLAY_NAME        AS "COMP_JOB",
    BATCH.ENTERPRISE_NAME   AS "ENTERPRISE",
    BATCH.EXEC_SRVR_NAME    AS "EXEC_SRVR",
    BATCH.REQ_MODE          AS "MODE",
    BATCH.STATUS            AS "STATUS",
    EMP.LOGIN               AS "REQ_BY",
    BATCH.DESC_TEXT         AS "DESCRIPTION",
    BATCH.COMPLETION_TEXT   AS "COMPLETION_TEXT",
    BATCH.CREATED           AS "SUBMIT_DATE",
    BATCH.ACTL_START_DT     AS "START_DT",
    BATCH.ACTL_END_DT       AS "END_DT",
    BATCH.PARAM_VAL         AS "PARAMETROS",
    COMP.DISPLAY_NAME       AS "COMPONENTE",
    ACTP.NAME               AS "PARAMETRO_NOME",
    PAR.VALUE               AS "META"
FROM SIEBEL.S_SRM_REQUEST BATCH
LEFT JOIN SIEBEL.S_SRM_ACTION ACT ON ACT.ROW_ID = BATCH.ACTION_ID
LEFT JOIN SIEBEL.S_SRM_ACTION COMP ON COMP.ROW_ID = ACT.PAR_ACTION_ID
LEFT JOIN SIEBEL.S_SRM_REQ_PARAM PAR ON PAR.REQ_ID = BATCH.ROW_ID
LEFT JOIN SIEBEL.S_SRM_ACT_PARAM ACTP ON ACTP.ROW_ID = PAR.ACTPARAM_ID
LEFT JOIN SIEBEL.S_USER EMP ON EMP.ROW_ID = BATCH.REQUESTED_BY
WHERE 1=1
AND BATCH.ROW_ID = '1-1PGYTACO';
AND ACT.DISPLAY_NAME = 'Workflow Process Manager'
--AND PAR.VALUE LIKE '%GOL Vouc Execute Schedulled WF%';
AND BATCH.DESC_TEXT LIKE '%GOL Execute Voucher Queue WF%'
AND BATCH.CREATED >= SYSDATE - 0.1;
--AND PAR.VALUE LIKE '%1-1O2NWRST%';
ORDER BY BATCH.CREATED DESC;
PAR.VALUE = 'CEG Cria Retorno OS Exame Medidor';