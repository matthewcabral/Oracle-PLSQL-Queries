SELECT
    EVTD.NAME                   AS "NOME_EVENTO",
    EVT.EVT_SEQ_NUM             AS "SEQUENCE",
    EVT.OBJ_TYPE_CD             AS "TIPO_OBJETO",
    EVT.OBJ_NAME                AS "NOME_OBJETO",
    EVT.EVT_NAME                AS "EVENTO",
    EVT.EVT_SUB_NAME            AS "SUBEVENTO",
    CONJ.NAME                   AS "NOME_CONJ_ACOES",
    ACAO.NAME                   AS "ACAO",
    ACAO.ACTN_TYPE_CD           AS "TIPO_ACAO",
    ACAO.SVC_METHOD_NAME        AS "METODO_BS",
    ACAO.SVC_CONTEXT            AS "CONTEXTO_BS"
FROM SIEBEL.S_CT_EVENT EVT
LEFT JOIN SIEBEL.S_CT_EVENT_DEF EVTD ON EVTD.ROW_ID = EVT.EVT_DEF_ID
INNER JOIN SIEBEL.S_CT_ACTION_SET CONJ ON CONJ.ROW_ID = EVT.CT_ACTN_SET_ID
INNER JOIN SIEBEL.S_CT_ACTION ACAO ON ACAO.CT_ACTN_SET_ID = CONJ.ROW_ID
--WHERE ACAO.SVC_METHOD_NAME LIKE '%GVTCheckOpenOrder%';
WHERE 1=1
AND CONJ.NAME LIKE 'GOL%Corporate Smiles Club';
-- EVT.OBJ_TYPE_CD = ''    -- Applet, BusComp, Application
-- EVT.OBJ_NAME = ''       -- Nome do objeto
-- EVT.EVT_NAME = ''       -- Evento
-- EVT.EVT_SUB_NAME = ''   -- Sub-Evento

/*----------------------------------------------------------------
Applet Event:
    DisplayApplet
    DisplayRecord
    InvokeMethod
    PreInvokeMethod
    UPTClientScript
    UPTGeneric
    UPTServerScript
BusComp Event:
    Associate
    ChangeRecord
    CopyRecord
    DeleteRecord
    InvokeMethod
    NewRecord
    PreAssociate
    PreCopyRecord
    PreDeleteRecord
    PreGetFieldValue
    PreInvokeMethod
    PreNewRecord
    PreQuery
    PreSetFieldValue
    PreWriteRecord
    Query
    SetFieldValue
    UPTClientScript
    UPTGeneric
    UPTServerScript
    WriteRecord
    WriteRecordNew
    WriteRecordUpdated
Application Event:
    ApplicationUnload
    InvokeMethod
    InvokeServiceMethod
    Login
    Logout
    Recording
    SetAttribute
    Timeout
    TaskViewBuildViewError
    UPTClientScript
    UPTGeneric
    UPTServerScript
    UPTTopLevelObject
    ViewActivated
    ViewDeactivated
    WebLogin
    WebLogout
    WebSessionEnd
    WebSessionStart
    WebTimeout
----------------------------------------------------------------*/

/*
Screen:
    Runtime Events Administration Screen
View:
    Personalization Events View
Business Object:
    Personalization Events
Applets:	
    Applet[0]: Personalization Event List Applet;
Business Components:
    BusComp[0]: Personalization Event;
*/