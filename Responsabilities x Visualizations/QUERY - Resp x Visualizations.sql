SELECT
    VW.NAME                 AS "NOME_VIEW",
    --VW.DESC_TEXT            AS "DESCRIPTION",
    --VW.LOCAL_ACCESS_FLG     AS "DEFAULT_LOCAL_ACCESS"
    RSP.NAME                AS "NOME_RESP"
FROM SIEBEL.S_APP_VIEW_RESP VRS
INNER JOIN SIEBEL.S_APP_VIEW VW ON VRS.VIEW_ID = VW.ROW_ID
INNER JOIN SIEBEL.S_RESP RSP ON RSP.ROW_ID = VRS.RESP_ID
WHERE VW.NAME LIKE 'LOY Program Corporate View';