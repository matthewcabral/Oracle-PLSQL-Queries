SELECT
    --WS.NAMESPACE        AS "NAMESPACE",
    WS.NAME             AS "NAME",
    WS.STATUS_CD        AS "STATUS",
    PRT.NAME            AS "SERVICE_PORT_NAME",
    PTY.IMPL_TYPE_CD    AS "IMPLEMENTATION_TYPE",
    PTY.IMPL_OBJ_NAME   AS "BS_BP_NAME",
    PRT.PORT_TRANSPORT  AS "TRANSPORT",
    PRT.PORT_ADDRESS    AS "ADDRESS"
FROM SIEBEL.S_WS_WEBSERVICE WS
RIGHT JOIN SIEBEL.S_WS_PORT PRT ON PRT.WEB_SERVICE_ID = WS.ROW_ID
LEFT JOIN SIEBEL.S_WS_PORT_TYPE PTY ON PTY.ROW_ID = PRT.WS_PORT_TYPE_ID
WHERE 1=1
AND WS.NAME LIKE '%Voucher%';
--AND PRT.NAME LIKE '%RenewClubSmilesNew%';
AND PTY.IMPL_OBJ_NAME LIKE 'GOL Send TXN Email Responsys';
--AND WS.NAME LIKE '%Member%';
AND PTY.NAME LIKE 'GOL List Signature%WF';