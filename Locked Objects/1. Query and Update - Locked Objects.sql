--------------------------------------- APPLET ---------------------------------------
SELECT
    AP.ROW_ID,
    AP.NAME,
    AP.OBJ_LOCKED_FLG,
    AP.OBJ_LOCKED_BY,
    SUS.ROW_ID AS "ID_USUARIO",
    SUS.LOGIN AS "LOGIN",
    SCO.FST_NAME AS "NOME",
    SCO.LAST_NAME AS "SOBRENOME"
FROM SIEBEL.S_APPLET AP
INNER JOIN SIEBEL.S_USER SUS ON SUS.ROW_ID = AP.OBJ_LOCKED_BY
INNER JOIN SIEBEL.S_CONTACT SCO ON SCO.ROW_ID = SUS.PAR_ROW_ID
WHERE AP.NAME = 'Quote Item List Applet';

UPDATE SIEBEL.S_APPLET AP
SET OBJ_LOCKED_FLG = 'N'
WHERE ROW_ID = '8-G4MXSA7';

--------------------------------------- BUSINESS COMPONENT ---------------------------------------
SELECT
    BC.ROW_ID,
    BC.NAME,
    BC.TABLE_NAME,
    BC.OBJ_LOCKED_FLG,
    BC.OBJ_LOCKED_BY,
    SUS.ROW_ID AS "ID_USUARIO",
    SUS.LOGIN AS "LOGIN",
    SCO.FST_NAME AS "NOME",
    SCO.LAST_NAME AS "SOBRENOME"
FROM SIEBEL.S_BUSCOMP BC
INNER JOIN SIEBEL.S_USER SUS ON SUS.ROW_ID = BC.OBJ_LOCKED_BY
INNER JOIN SIEBEL.S_CONTACT SCO ON SCO.ROW_ID = SUS.PAR_ROW_ID
WHERE BC.NAME = 'NV Opportunity Navigation Flow BC';

UPDATE SIEBEL.S_BUSCOMP BC
SET OBJ_LOCKED_FLG = 'N'
WHERE ROW_ID = '8-G4MXSA7';

--------------------------------------- BUSINESS OBJECT ---------------------------------------
SELECT
    BO.ROW_ID,
    BO.NAME,
    BO.OBJ_LOCKED_FLG,
    BO.OBJ_LOCKED_BY,
    SUS.ROW_ID AS "ID_USUARIO",
    SUS.LOGIN AS "LOGIN",
    SCO.FST_NAME AS "NOME",
    SCO.LAST_NAME AS "SOBRENOME"
FROM SIEBEL.S_BUSOBJ BO
INNER JOIN SIEBEL.S_USER SUS ON SUS.ROW_ID = BO.OBJ_LOCKED_BY
INNER JOIN SIEBEL.S_CONTACT SCO ON SCO.ROW_ID = SUS.PAR_ROW_ID
WHERE BO.NAME = 'Account';

UPDATE SIEBEL.S_BUSOBJ BO
SET OBJ_LOCKED_FLG = 'N'
WHERE ROW_ID = '8-G4MXSA7';

--------------------------------------- BUSINESS SERVICE ---------------------------------------
SELECT
    BS.ROW_ID,
    BS.NAME,
    BS.OBJ_LOCKED_FLG,
    BS.OBJ_LOCKED_BY,
    SUS.ROW_ID AS "ID_USUARIO",
    SUS.LOGIN AS "LOGIN",
    SCO.FST_NAME AS "NOME",
    SCO.LAST_NAME AS "SOBRENOME"
FROM SIEBEL.S_SERVICE BS
INNER JOIN SIEBEL.S_USER SUS ON SUS.ROW_ID = BS.OBJ_LOCKED_BY
INNER JOIN SIEBEL.S_CONTACT SCO ON SCO.ROW_ID = SUS.PAR_ROW_ID
WHERE BS.NAME = 'CEG Report File Generator';

UPDATE SIEBEL.S_SERVICE BS
SET OBJ_LOCKED_FLG = 'N'
WHERE ROW_ID = '2-T5G9-1IRA2';

--------------------------------------- PRODUTO ---------------------------------------
SELECT
    PROD.ROW_ID,
    PROD.NAME,
    VOD.ROW_ID AS "ID_VOD",
    VOD.LOCKED_FLG,
	VOD.LOCKED_BY
FROM SIEBEL.S_PROD_INT PROD
INNER JOIN SIEBEL.S_VOD VOD ON VOD.OBJECT_NUM = PROD.CFG_MODEL_ID
WHERE NAME IN ('Fixo e Móvel Ilimitado Local Empresas Oferta - FSP');

UPDATE SIEBEL.S_VOD VOD
SET VOD.LOCKED_FLG = 'N',
	VOD.LOCKED_BY = NULL
WHERE VOD.ROW_ID IN ('8-8S90VKF');

--------------------------------------- PROJETO ---------------------------------------
SELECT
    PROJ.ROW_ID,
    PROJ.NAME AS "PROJETO",
    PROJ.LOCKED_FLG AS "BLOQUEADO",
    SUS.ROW_ID AS "ID_USUARIO",
    SUS.LOGIN AS "LOGIN",
    SCO.FST_NAME AS "NOME",
    SCO.LAST_NAME AS "SOBRENOME"
FROM SIEBEL.S_PROJECT PROJ
INNER JOIN SIEBEL.S_USER SUS ON SUS.ROW_ID = PROJ.LOCKED_BY
INNER JOIN SIEBEL.S_CONTACT SCO ON SCO.ROW_ID = SUS.PAR_ROW_ID
--WHERE PROJ.NAME = 'GVT External Systems';
WHERE SUS.LOGIN LIKE 'E80603505%';

UPDATE SIEBEL.S_PROJECT PROJ
SET PROJ.LOCKED_FLG = 'N'
WHERE PROJ.ROW_ID = '';
--IN ('8-I5GE-BUY','8-I5GE-BUH');

--------------------------------------- SCREEN ---------------------------------------
SELECT
    SC.ROW_ID,
    SC.NAME,
    SC.OBJ_LOCKED_FLG,
    SC.OBJ_LOCKED_BY,
    SUS.ROW_ID AS "ID_USUARIO",
    SUS.LOGIN AS "LOGIN",
    SCO.FST_NAME AS "NOME",
    SCO.LAST_NAME AS "SOBRENOME"
FROM SIEBEL.S_SCREEN SC
INNER JOIN SIEBEL.S_USER SUS ON SUS.ROW_ID = SC.OBJ_LOCKED_BY
INNER JOIN SIEBEL.S_CONTACT SCO ON SCO.ROW_ID = SUS.PAR_ROW_ID
WHERE SC.NAME = 'Accounts Screen';

UPDATE SIEBEL.S_SCREEN SC
SET OBJ_LOCKED_FLG = 'N'
WHERE ROW_ID = '2-T5G9-1I7QO';

--------------------------------------- WORKFLOW ---------------------------------------
SELECT
    WF.ROW_ID,
    WF.PROC_NAME,
    WF.VERSION,
    WF.OBJ_LOCKED_FLG,
	WF.OBJ_LOCKED_DATE
FROM SIEBEL.S_WFR_PROC WF
WHERE WF.PROC_NAME = 'GVT Order Creation WF'
ORDER BY WF.VERSION DESC;

update SIEBEL.S_WFR_PROC W
set W.OBJ_LOCKED_FLG = 'N',
	W.OBJ_LOCKED_DATE = null
where
    W.ROW_ID = '8-GUN0A61';