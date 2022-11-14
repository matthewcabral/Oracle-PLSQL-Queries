SELECT
    WFI.EXEC_INST_VAL   AS "INSTANCE_ID",
    WFN.NAME            AS "WF_NAME",
    WFI.CURR_STEP_NAME  AS "CURRENT_STEP",
    WFI.START_TS        AS "START_DT",
    WFI.END_TS          AS "END_DT",
    WFN.VERSION         AS "VERSAO",
    WFS.STEP_NAME       AS "STEP",
    WFP.NAME            AS "PROPERTY_NAME",
    WFP.TYPE_CD         AS "PROPERTY_TYPE",
    WFP.PROP_VAL        AS "PROPERTY_VALUE"
FROM SIEBEL.S_WFA_INST_LOG WFI
LEFT JOIN SIEBEL.S_WFA_DEFN_LOG WFN ON WFN.ROW_ID = WFI.DEFINITION_ID
LEFT JOIN SIEBEL.S_WFA_INSTP_LOG WFS ON WFS.INST_LOG_ID = WFI.ROW_ID
LEFT JOIN SIEBEL.S_WFA_STPRP_LOG WFP ON WFP.STEP_LOG_ID = WFS.ROW_ID
WHERE 1=1
AND WFI.CREATED >= SYSDATE - 1
AND (
    WFN.NAME = 'GOL Gift Process Miles Purchase WF'
)
AND (
    WFS.STEP_NAME = 'Start'
    --OR WFS.STEP_NAME = 'Send Email Responsys'
)
AND WFP.NAME = 'SourceMember'
AND WFP.PROP_VAL IN (
    '107508656'/*,
    '230530786',
    '230573571'*/
)
--AND WFI.END_TS >= SYSDATE - 1
ORDER BY WFI.END_TS DESC;

-- WF DEPLOYMENT
SELECT
    DPL.ROW_ID,
    DPL.NAME,
    DPL.VERSION,
    DPL.BUSOBJ_NAME AS "BO",
    DPL.DEPLOY_STATUS_CD AS "STATUS",
    DPL.MONITOR_LVL_CD AS "NVL_MONITORAMENTO"
FROM SIEBEL.S_WFA_DPLOY_DEF DPL
--WHERE DPL.NAME LIKE 'GOL Mark Club Smiles Related Plan WF'
--AND DPL.DEPLOY_STATUS_CD = 'ACTIVE';
WHERE DPL.NAME IN (
    'GOL MilesBack Recurrence WF',
    'GOL Create Accrual Txn MilesBack',
    'GOL MilesBack Recurrence Async WF'
)
AND DPL.DEPLOY_STATUS_CD = 'ACTIVE';

UPDATE SIEBEL.S_WFA_DPLOY_DEF DPL
SET DPL.MONITOR_LVL_CD = 'DETAIL'
--WHERE DPL.NAME LIKE 'GOL Mark Club Smiles Related Plan WF'
--AND DPL.DEPLOY_STATUS_CD = 'ACTIVE';
WHERE DPL.NAME IN (
    'GOL MilesBack Recurrence WF',
    'GOL Create Accrual Txn MilesBack',
    'GOL MilesBack Recurrence Async WF'
)
AND DPL.DEPLOY_STATUS_CD = 'ACTIVE';

    -- COMPRA DE MILHAS
    /*
    'GOL ListPurchaseOptions V2 WF',
    'GOL Miles Purchase - Process Accrual Txn V2 WF',
    'GOL Miles Purchase - Query Txn V2 WF'
    */
    -- ADESAO
    /*
    'GOL Club Smiles - Club Signature Maintenance WF',
    'GOL Club Smiles - Club Signature Maintenance WF V2',
    'GOL Club Smiles Promotional Rules Workflow',
    'GOL Vantagens Upsert Order WF',
    'LOY Engine - Process Object',
    'GOL MGM Validate Indication Code',
    'GOL Process Transaction with Retry',
    'GOL MGM Conversion Confirmation',
    'GOL MGM Create Indication',
    'GOL MGM Send Member Email',
    */
    -- R12 -- CLUBE CORPORATIVO
    /*
    'GOL Corporate Smiles Club Execute Employee Import WF',
    'GOL Corporate Smiles Club Import Employee File WF',
    'GOL Corporate Smiles Club Import Employee Records WF',
    'GOL Corporate Smiles Club Upsert Employee WF',
    'GOL Corporate Smiles Club Expire Inactive Employees WF',
    'GOL Corporate Smiles Club Plan Validations WF',
    'GOL List Signatures WF',
    'GOL List Signatures APP WF',
    'GOL Mark Club Smiles Related Plan WF',
    'GOL Member Add Completed WF',
    'GOL Member Add Simplifield WF'
    */
    -- RECORRENCIA
    /*
    'GOL Pre-Cancel Club Smiles Mensal WF',
    'GOL Club Smiles - Get Recent Payment Data',
    'GOL Clube Smiles - Get All Accrued Miles',
    'GOL Club Smiles Recurrence Process V2',
    'GOL Commit Cancel Club Smiles WF',
    'GOL Close Service Request WF',
    'GOL Run Related Plan Modification WF',
    'GOL Execute Related Plan Modification WF',
    'GOL Club Smiles Recurrence Process Optimizer V2',
    'GOL Club Smiles - Send Payment Recurrence',
    'GOL Invoke BS - Recurrence Process',
    'GOL Club Smiles Recurrence Process Annual V1',
    'GOL Commit Cancel Club Smiles Annual V1',
    'GOL Close Service Request WF',
    'GOL Run Related Plan Modification Annual V1',
    'GOL Club Smiles - Execute Related Annual Plan Modification V1',
    'GOL Run Renew Plan Annual',
    'GOL Club Smiles - Execute Renew Annual Plan Modification',
    'GOL Club Smiles - Suspend Expired Annual Plans',
    'GOL Club Smiles - Auto Renew Fail - Update Status',
    'GOL Club Smiles Recurrence Process Optimizer Annual V1',
    'GOL Invoke BS - Recurrence Process Annual',
    'GOL Club Smiles - Send Renew Member Plan',
    */
    -- RENOVACAO
    /*
    'GOL Club Smiles - Renew Signature Annual',
    'GOL Club Smiles - Club Signature Change Plan Annual',
    'GOL Club Smiles - Bonus Antecipation Annual Signature',
    'GOL Close Service Request WF',
    'GOL Vantagens Upsert Order WF',
    'LOY Engine - Process Object',
    'GOL Club Smiles - Create Signature Payment Plan Annual Upgrade',
    'GOL Carrega Ofertas Disponiveis Validadte WF',
    'GOL Send TXN Email',
    'GOL Send TXN Email Responsys',
    'GOL Marketing Campaign Load Contact - Fam Acc - Send Invitation'
    */
    -- ADESAO 25K
    /*
    'GOL Club Offer Async Send Email WF',
    'GOL Get Views SPA',
    'GOL Club Offers Import Records WF'
    */
    -- FAMILY ACCOUNT
    /*
    'GOL Family Account - Answer Invitation',
    'GOL Family Account - Cancel All',
    'GOL Family Account - Cancel Downgrade',
    'GOL Family Account - Cancel Family Account',
    'GOL Family Account - Cancel Management',
    'GOL Family Account - Cancel Management Adm',
    'GOL Family Account - Cancel Transaction CF',
    'GOL Family Account - Cancel Vinculation',
    'GOL Family Account - Cancel Vinculation No Rule',
    'GOL Family Account - Cancelamento Club Smiles',
    'GOL Family Account - Cancelamento Club Smiles Commit',
    'GOL Family Account - Cancelamento Club Smiles Recorrente',
    'GOL Family Account - Change Member',
    'GOL Family Account - Change Member Adm',
    'GOL Family Account - Club Verification',
    'GOL Family Account - Create Adm',
    'GOL Family Account - Create Family Account',
    'GOL Family Account - Create Txn Manual Debit',
    'GOL Family Account - Create Txn Manual Debit',
    'GOL Family Account - Create Txn Manual Debit OLD int_r012020v3',
    'GOL Family Account - Eligibility WF',
    'GOL Family Account - Extrato',
    'GOL Family Account - Get Family Account',
    'GOL Family Account - Get Family Account',
    'GOL Family Account - Get Member Fields',
    'GOL Family Account - Get Member Fields By CPF',
    'GOL Family Account - Invitation Adm',
    'GOL Family Account - Invitation Update Status',
    'GOL Family Account - Link Invitation',
    'GOL Family Account - Manual Link No Rules',
    'GOL Family Account - Manual Unlink No Rules',
    'GOL Family Account - Point Tranfer Adjustment',
    'GOL Family Account - Process Txn',
    'GOL Family Account - Process Txn',
    'GOL Family Account - Process Txn OLD int_r012020v3',
    'GOL Family Account - Reactivate',
    'GOL Family Account - Send Invitation',
    'GOL Family Account - Total Points to Master',
    'GOL Family Account - Unlink Family Member',
    'GOL Family Account - Unlink Family Member',
    'GOL Family Account - Update Blocked Invitation',
    'GOL Family Account - Update Family Account',
    'GOL Family Account - Update Member',
    'GOl Family Account - Update Member',
    'GOL Family Account - Update Member No Rules',
    'GOL Family Account - Validate Create WF',
    'GOL Family Account - Validate Family Account Transfer',
    'GOL Family Account - Validate Member WF',
    'GOL Family Account - Validate Point Transfer Transaction',
    'GOL Family Account - Validate Vinculate Send WF',
    'GOL Family Account - Validate Vinculate WF',
    'GOL Marketing Campaign Create Contact Family Account',
    'GOL Marketing Campaign Load Contact - Family Account'
    */
    -- BONUS VIP
    /*
    'GOL Bonus VIP Optin WF',
    'GOL Bonus VIP Get Member BVIP WF',
    'GOL Accrual Partner No Air - Accrual Process',
    'GOL Search Active Bonus VIP',
    'GOL Member Teto Bonus VIP Limit WF',
    'GOL Create Bonus VIP Txn WF',
    'GOL Bonus VIP WF',
    'GOL Bonus VIP Txn Opr WF',
    'GOL Bonus VIP Send Email WF',
    'GOL Bonus VIP Scheduler WF',
    'GOL Bonus VIP Get Member Plan WF',
    'GOL Bonus VIP Get Info WF',
    'GOL Bonus VIP Cobranded Retro Bonus WF',
    'GOL Bonus VIP Cobranded Retro Bonus Get Txns WF'
    */
    -- MILHAS GIFT
    /*
    'GOL Gift List Miles Purchase Options - Fase 2 WF',
    'GOL Gift Purchase Transaction WF',
    'GOL Gift Process Miles Purchase WF',
    'GOL Insert Fraud Job Schedule',
    'GOL Fraude Get Transactions From Job'
    */
    -- EXTENSAO DE MILHAS
    /*
    'GOL Get Miles Extension WF',
    'GOL Process Miles Extension WF'
    */
    -- MILHASBACK RECORRENCIA
    /*
    'GOL MilesBack Recurrence WF',
    'GOL Create Accrual Txn MilesBack',
    'GOL MilesBack Recurrence Async WF'
    */