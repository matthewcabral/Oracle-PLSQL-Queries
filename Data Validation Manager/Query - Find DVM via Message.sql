SELECT 
    SVS.NAME            AS "CONJUNTO",
    --SVS.REV_NUM         AS "REVISAO",
    --SVS.STATUS_CD       AS "STATUS",
    SVR.SEQ_NUM         AS "SEQUENCIA", 
    SVR.NAME            AS "REGRA", 
    SVR.RULE_EXPR       AS "ESPRESSAO",
    SVR.BUSCOMP_NAME    AS "BUSCOMP",
    SVR.EFF_START_DT    AS "EFETIVA_DE", 
    SVR.EFF_END_DT      AS "EFETIVA_ATE", 
    SVR.RETURN_CD       AS "CODIGO_MENSAGEM", 
    --SVR.ERR_MSG_TXT     AS "MESSAGEM_INGLES",
    SVR.IMMD_DSPLY_FLG  AS "IMMEDIATE_DISPLAY",
    SVR.STOP_ON_ERR_FLG AS "STOP_ON_ERROR"
    --SVL.MSG_TEXT        AS "MENSAGEM_TRADUZIDA"
FROM SIEBEL.S_VALDN_RULE SVR
LEFT JOIN SIEBEL.S_VALDN_RL_SET SVS  ON SVS.ROW_ID = SVR.RULE_SET_ID
LEFT JOIN SIEBEL.S_ISS_VALDN_MSG SVM ON SVM.MSG_TYPE_CD = SVR.RETURN_CD
--LEFT JOIN SIEBEL.S_ISS_VMSG_LANG SVL ON SVL.PAR_ROW_ID = SVM.ROW_ID
WHERE 1=1
--SVS.status_cd = 'Ativo'
--AND (SVR.EFF_END_DT > SYSDATE OR SVR.EFF_END_DT IS NULL) 
-- and v.RULE_EXPR like '%CEG Opcao Fatura%'
AND SVS.NAME = 'GOL Import Corporate Smiles Club';
AND (
	SVR.ERR_MSG_TXT LIKE '%HomeAssist%' --MENSAGEM NÃO TRADUZIDA
	OR SVL.MSG_TEXT LIKE '%HomeAssist%'
);



SELECT
    SVM.MSG_TYPE_CD         AS "MESSAGE_CODE",
    SVM.MSG_LVL_CD          AS "MESSAGE_LEVEL",
    SVM.MSG_SRC_TYPE_CD     AS "MESSAGE_SOURCE",
    SVM.MSG_TEXT            AS "MESSAGE_TEXT",
    SVM.DESC_TEXT           AS "DESCRIPTION",
    SVL.LANG_ID             AS "LANGUAGE",
    SVL.MSG_TEXT            AS "MESSAGE_TEXT"
FROM SIEBEL.S_ISS_VALDN_MSG SVM
LEFT JOIN SIEBEL.S_ISS_VMSG_LANG SVL ON SVL.PAR_ROW_ID = SVM.ROW_ID
WHERE SVM.MSG_TYPE_CD LIKE 'CORP_SC%'
ORDER BY SVM.MSG_TYPE_CD, SVL.LANG_ID ASC;