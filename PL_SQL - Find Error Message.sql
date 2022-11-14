DECLARE
    V_MESSAGE		VARCHAR2(300) := 'Member does not have sufficient number of points available to redeem';
    LOCALE          VARCHAR2(300);
    DVM_COUNT       INTEGER;
    LOV_COUNT       INTEGER;
    MC_COUNT        INTEGER;
    MSG_TYPE_COUNT  INTEGER;
    WF_COUNT        INTEGER;
	BCS_COUNT 		INTEGER;
	BSS_COUNT 		INTEGER;
    
    CURSOR C_VERIFY_DVM IS
        SELECT
            SVS.NAME            AS "CONJUNTO",
            SVS.REV_NUM         AS "REVISAO",
            SVS.STATUS_CD       AS "STATUS",
            SVR.SEQ_NUM         AS "SEQUENCIA",
            SVR.NAME            AS "REGRA",
            SVR.RULE_EXPR       AS "ESPRESSAO",
            SVR.BUSCOMP_NAME    AS "BUSCOMP",
            SVR.EFF_START_DT    AS "EFETIVA_DE",
            SVR.EFF_END_DT      AS "EFETIVA_ATE",
            SVR.RETURN_CD       AS "CODIGO_MENSAGEM",
            SVR.ERR_MSG_TXT     AS "MESSAGEM_INGLES",
            SVL.MSG_TEXT        AS "MENSAGEM_TRADUZIDA"
        FROM SIEBEL.S_VALDN_RULE SVR
        LEFT JOIN SIEBEL.S_VALDN_RL_SET SVS  ON SVS.ROW_ID = SVR.RULE_SET_ID
        LEFT JOIN SIEBEL.S_ISS_VALDN_MSG SVM ON SVM.ROW_ID = SVR.VALDN_MSG_ID
        LEFT JOIN SIEBEL.S_ISS_VMSG_LANG SVL ON SVL.PAR_ROW_ID = SVM.ROW_ID
        WHERE SVS.STATUS_CD IN ('Ativo', 'Active')
        AND (
            SVR.ERR_MSG_TXT LIKE '%' || V_MESSAGE || '%' --MENSAGEM NAO TRADUZIDA
            OR SVL.MSG_TEXT LIKE '%' || V_MESSAGE || '%'
            OR SVM.MSG_TEXT LIKE '%' || V_MESSAGE || '%'
        );
        
    CURSOR C_VERIFY_LOV_DESC IS
        SELECT
            LOV.TYPE                AS "TIPO",
            LOV.NAME                AS "COD_IND_IDIOMA",
            LOV.VAL                 AS "EXIBIR_VALOR",
            SLA.NAME                AS "NOME_IDIOMA",
            LOV.LANG_ID                AS "COD_IDIOMA",
            LOV.SUB_TYPE            AS "SUBTIPO",
            LOV.ORDER_BY            AS "ORDEM",
            LOV.DESC_TEXT            AS "DESCRICAO"
        FROM SIEBEL.S_LST_OF_VAL LOV
        LEFT JOIN SIEBEL.S_LST_OF_VAL PLOV ON PLOV.ROW_ID = LOV.PAR_ROW_ID
        LEFT JOIN SIEBEL.S_LANG SLA ON SLA.LANG_CD = LOV.LANG_ID
        LEFT JOIN SIEBEL.S_LIT SLT ON SLT.ROW_ID = LOV.BITMAP_ID
        WHERE LOV.ACTIVE_FLG = 'Y'
        AND LOV.DESC_TEXT LIKE '%' || V_MESSAGE || '%'
        --AND LOV.WS_ID = '1@981'
        ORDER BY LOV.CREATED DESC;
        
        
    CURSOR C_VERIFY_MESSAGE_CAT IS
        SELECT
            CAT.NAME    AS "CATEGORIA",
            MSG.NAME    AS "NOME",
            CASE
                WHEN ALIAS.TEXT IS NOT NULL THEN ALIAS.TEXT
                WHEN EXT.STRING_VALUE IS NOT NULL THEN EXT.STRING_VALUE
                ELSE DFLT.STRING_VALUE
            END AS "TEXTO"    
        FROM SIEBEL.S_ERR_MSG_CAT CAT
        RIGHT JOIN SIEBEL.S_ERR_MSG MSG ON MSG.ERR_MSG_CAT_ID = CAT.ROW_ID
        LEFT JOIN SIEBEL.S_ERR_MSG_INTL ALIAS ON ALIAS.ERR_MSG_ID = MSG.ROW_ID
        LEFT JOIN SIEBEL.S_SYM_STR_INTL EXT ON EXT.SYM_STR_KEY = MSG.TEXT_REF AND EXT.REPOSITORY_ID = MSG.REPOSITORY_ID
        LEFT JOIN SIEBEL.S_SYM_STR_INTL DFLT ON DFLT.SYM_STR_KEY = MSG.TEXT_REF AND DFLT.REPOSITORY_ID = MSG.REPOSITORY_ID
        WHERE (
            ALIAS.TEXT LIKE '%' || V_MESSAGE || '%'
            OR EXT.STRING_VALUE LIKE '%' || V_MESSAGE || '%'
            OR DFLT.STRING_VALUE LIKE '%' || V_MESSAGE || '%'
        );
        
    CURSOR C_VERIFY_MSG_TYPE_COUNT IS
        SELECT
            SINAL.MSG_NAME            AS "NOME",
            SINAL.DISPLAY_MODE_CD    AS "MODO_EXIBICAO",
            SINAL.MSG_TYPE_CD        AS "GRUPO",
            SINAL.SHORT_TEXT        AS "TEXTO_CURTO",
            SINAL.LONG_TEXT            AS "TEXTO_INTEGRAL"
        FROM SIEBEL.S_PROD_MSG SINAL
        WHERE (
            SINAL.SHORT_TEXT LIKE '%' || V_MESSAGE || '%'
            OR SINAL.LONG_TEXT LIKE '%' || V_MESSAGE || '%'
        );
    
    CURSOR C_VERIFY_WF IS
        SELECT
            WF.PROC_NAME    AS "NOME_WORKFLOW",
            WF.VERSION        AS "VERSAO",
            WF.STATUS_CD    AS "STATUS",
            STP.NAME        AS "STEP",
            STP.TYPE_CD        AS "TIPO",
            IO.VAL            AS "VALOR_SEARCH_SPEC"
        FROM SIEBEL.S_WFR_PROC WF
        RIGHT JOIN SIEBEL.S_WFR_STP STP ON STP.PROCESS_ID = WF.ROW_ID
        RIGHT JOIN SIEBEL.S_WFR_STP_ARG IO ON IO.STEP_ID = STP.ROW_ID
        WHERE IO.VAL LIKE '%' || V_MESSAGE || '%'
        AND WF.STATUS_CD = 'COMPLETED';
    
	CURSOR C_VERIFY_BC_SCRIPT IS
		SELECT
			BC.ROW_ID           AS "ID_BC",
			BC.NAME             AS "NOME_BC",
			BC.TABLE_NAME       AS "TABLE_BC",
			SCR.NAME            AS "NOME_SCRIPT",
			SCR.SCRIPT          AS "SCRIPT"
		FROM SIEBEL.S_BUSCOMP BC
		LEFT JOIN SIEBEL.S_BUSCOMP_SCRIPT SCR ON SCR.BUSCOMP_ID = BC.ROW_ID
		WHERE SCR.SCRIPT LIKE '%' || V_MESSAGE || '%';
	
	CURSOR C_VERIFY_BS_SCRIPT IS
		SELECT
			BS.ROW_ID           AS "ID_BS",
			BS.NAME             AS "NOME_BS",
			SCR.NAME            AS "NOME_SCRIPT",
			SCR.SCRIPT          AS "SCRIPT"
		FROM SIEBEL.S_SERVICE BS
		LEFT JOIN SIEBEL.S_SERVICE_SCRPT SCR ON SCR.SERVICE_ID = BS.ROW_ID
		WHERE SCR.SCRIPT LIKE '%' || V_MESSAGE || '%';
	
    FUNCTION VERIFY_DVM RETURN INTEGER IS 
        N INTEGER;
        BEGIN
            SELECT
                COUNT(*)
            INTO N
            FROM SIEBEL.S_VALDN_RULE SVR
            LEFT JOIN SIEBEL.S_VALDN_RL_SET SVS  ON SVS.ROW_ID = SVR.RULE_SET_ID
            LEFT JOIN SIEBEL.S_ISS_VALDN_MSG SVM ON SVM.ROW_ID = SVR.VALDN_MSG_ID
            LEFT JOIN SIEBEL.S_ISS_VMSG_LANG SVL ON SVL.PAR_ROW_ID = SVM.ROW_ID
            WHERE SVS.STATUS_CD IN ('Ativo', 'Active')
            AND (
                SVR.ERR_MSG_TXT LIKE '%' || V_MESSAGE || '%' --MENSAGEM NAO TRADUZIDA
                OR SVL.MSG_TEXT LIKE '%' || V_MESSAGE || '%'
                OR SVM.MSG_TEXT LIKE '%' || V_MESSAGE || '%'
            );           
        RETURN N;
    END;
    
    FUNCTION VERIFY_LOV_DESC RETURN INTEGER IS
        N INTEGER;
        BEGIN
            SELECT
                COUNT(*)
            INTO N
            FROM SIEBEL.S_LST_OF_VAL LOV
            WHERE LOV.ACTIVE_FLG = 'Y'
            AND LOV.DESC_TEXT LIKE '%' || V_MESSAGE || '%'
            --AND LOV.WS_ID = '1@981'
            ORDER BY LOV.CREATED DESC;
        RETURN N;
    END;
    
    FUNCTION VERIFY_MESSAGE_CAT RETURN INTEGER IS 
        N INTEGER;
        BEGIN
            SELECT
                COUNT(*)
            INTO N
            FROM SIEBEL.S_ERR_MSG_CAT CAT
            RIGHT JOIN SIEBEL.S_ERR_MSG MSG ON MSG.ERR_MSG_CAT_ID = CAT.ROW_ID
            LEFT JOIN SIEBEL.S_ERR_MSG_INTL ALIAS ON ALIAS.ERR_MSG_ID = MSG.ROW_ID
            LEFT JOIN SIEBEL.S_SYM_STR_INTL EXT ON EXT.SYM_STR_KEY = MSG.TEXT_REF AND EXT.REPOSITORY_ID = MSG.REPOSITORY_ID
            LEFT JOIN SIEBEL.S_SYM_STR_INTL DFLT ON DFLT.SYM_STR_KEY = MSG.TEXT_REF AND DFLT.REPOSITORY_ID = MSG.REPOSITORY_ID
            WHERE (
                ALIAS.TEXT LIKE '%' || V_MESSAGE || '%'
                OR EXT.STRING_VALUE LIKE '%' || V_MESSAGE || '%'
                OR DFLT.STRING_VALUE LIKE '%' || V_MESSAGE || '%'
            );        
        RETURN N;
    END;
    
    FUNCTION VERIFY_MSG_TYPE_COUNT RETURN INTEGER IS 
        N INTEGER;
        BEGIN
            SELECT
                COUNT(*)
            INTO N
            FROM SIEBEL.S_PROD_MSG SINAL
            WHERE (
                SINAL.SHORT_TEXT LIKE '%' || V_MESSAGE || '%'
                OR SINAL.LONG_TEXT LIKE '%' || V_MESSAGE || '%'
            );
        RETURN N;
    END;
    
    FUNCTION VERIFY_WF RETURN INTEGER IS 
        N INTEGER;
        BEGIN
            SELECT
                COUNT(*)
            INTO N
            FROM SIEBEL.S_WFR_PROC WF
            RIGHT JOIN SIEBEL.S_WFR_STP STP ON STP.PROCESS_ID = WF.ROW_ID
            RIGHT JOIN SIEBEL.S_WFR_STP_ARG IO ON IO.STEP_ID = STP.ROW_ID
            WHERE IO.VAL LIKE '%' || V_MESSAGE || '%'
            AND WF.STATUS_CD = 'COMPLETED';
        RETURN N;
    END;
	
	FUNCTION VERIFY_BC_SCRIPT RETURN INTEGER IS 
        N INTEGER;
        BEGIN
            SELECT
                COUNT(*)
            INTO N
            FROM SIEBEL.S_BUSCOMP BC
			LEFT JOIN SIEBEL.S_BUSCOMP_SCRIPT SCR ON SCR.BUSCOMP_ID = BC.ROW_ID
			WHERE SCR.SCRIPT LIKE '%' || V_MESSAGE || '%';
        RETURN N;
    END;
	
	FUNCTION VERIFY_BS_SCRIPT RETURN INTEGER IS 
        N INTEGER;
        BEGIN
            SELECT
                COUNT(*)
            INTO N
            FROM SIEBEL.S_SERVICE BS
			LEFT JOIN SIEBEL.S_SERVICE_SCRPT SCR ON SCR.SERVICE_ID = BS.ROW_ID
			WHERE SCR.SCRIPT LIKE '%' || V_MESSAGE || '%';
        RETURN N;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Início da execução...');
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('Verificando DVM');
    DVM_COUNT := VERIFY_DVM;
    DBMS_OUTPUT.PUT_LINE('Verificando LOV Description');
    LOV_COUNT := VERIFY_LOV_DESC;
    DBMS_OUTPUT.PUT_LINE('Verificando Message Category');
    MC_COUNT := VERIFY_MESSAGE_CAT;
    DBMS_OUTPUT.PUT_LINE('Verificando Message Type');
    MSG_TYPE_COUNT := VERIFY_MSG_TYPE_COUNT;
    DBMS_OUTPUT.PUT_LINE('Verificando WF');
    WF_COUNT := VERIFY_WF;
	DBMS_OUTPUT.PUT_LINE('Verificando Server Script de BC');
	BCS_COUNT := VERIFY_BC_SCRIPT;
	DBMS_OUTPUT.PUT_LINE('Verificando Server Script de BS');
	BSS_COUNT := VERIFY_BS_SCRIPT;
	
	DBMS_OUTPUT.PUT_LINE(' ');
	DBMS_OUTPUT.PUT_LINE(' ');
	DBMS_OUTPUT.PUT_LINE('================== RESULTADO ==================');
	DBMS_OUTPUT.PUT_LINE('Total de DVMs encontradas: ' || TO_CHAR(DVM_COUNT));
	DBMS_OUTPUT.PUT_LINE('Total de LOVs encontradas: ' || TO_CHAR(LOV_COUNT));
	DBMS_OUTPUT.PUT_LINE('Total de Message Categories encontradas: ' || TO_CHAR(MC_COUNT));
	DBMS_OUTPUT.PUT_LINE('Total de Message Type encontradas: ' || TO_CHAR(MSG_TYPE_COUNT));
	DBMS_OUTPUT.PUT_LINE('Total de WFs encontrados: ' || TO_CHAR(WF_COUNT));
	DBMS_OUTPUT.PUT_LINE('Total de Server Script de BCs encontrados: ' || TO_CHAR(BCS_COUNT));
	DBMS_OUTPUT.PUT_LINE('Total de Server Script de BSs encontrados: ' || TO_CHAR(BSS_COUNT));
	DBMS_OUTPUT.PUT_LINE('===============================================');
	DBMS_OUTPUT.PUT_LINE(' ');
	DBMS_OUTPUT.PUT_LINE(' ');
	    
    IF (DVM_COUNT > 0) THEN
        DBMS_OUTPUT.PUT_LINE('Data Validation encontrado');
        DBMS_OUTPUT.PUT_LINE('CONJUNTO;REVISAO;STATUS;SEQUENCIA;REGRA;ESPRESSAO;BUSCOMP;EFETIVA_DE;EFETIVA_ATE;CODIGO_MENSAGEM;MESSAGEM_INGLES;MENSAGEM_TRADUZIDA');
        FOR I IN C_VERIFY_DVM LOOP
            DBMS_OUTPUT.PUT_LINE(
                I.CONJUNTO
                || ';' || I.REVISAO
                || ';' || I.STATUS
                || ';' || I.SEQUENCIA
                || ';' || I.REGRA
                || ';' || I.ESPRESSAO
                || ';' || I.BUSCOMP
                || ';' || I.EFETIVA_DE
                || ';' || I.EFETIVA_ATE
                || ';' || I.CODIGO_MENSAGEM
                || ';' || I.MESSAGEM_INGLES
                || ';' || I.MENSAGEM_TRADUZIDA
            );
        END LOOP;
    ELSIF (LOV_COUNT > 0) THEN
        DBMS_OUTPUT.PUT_LINE('LOV Description Encontrado');
        DBMS_OUTPUT.PUT_LINE('TIPO;COD_IND_IDIOMA;EXIBIR_VALOR;NOME_IDIOMA;COD_IDIOMA;SUBTIPO;ORDEM;DESCRICAO');
        FOR I IN C_VERIFY_LOV_DESC LOOP
            DBMS_OUTPUT.PUT_LINE(
                I.TIPO
                || ';' || I.COD_IND_IDIOMA
                || ';' || I.EXIBIR_VALOR
                || ';' || I.NOME_IDIOMA
                || ';' || I.COD_IDIOMA
                || ';' || I.SUBTIPO
                || ';' || I.ORDEM
                || ';' || I.DESCRICAO
            );
        END LOOP;
    ELSIF (MC_COUNT > 0) THEN
        DBMS_OUTPUT.PUT_LINE('Message Category encontrado');
        DBMS_OUTPUT.PUT_LINE('CATEGORIA;NOME;TEXTO');
        FOR I IN C_VERIFY_MESSAGE_CAT LOOP
            DBMS_OUTPUT.PUT_LINE(
                I.CATEGORIA
                || ';' || I.NOME
                || ';' || I.TEXTO
            );
        END LOOP;
            
    ELSIF (MSG_TYPE_COUNT > 0) THEN
        DBMS_OUTPUT.PUT_LINE('Tipo de Mensagem encontrado');
        DBMS_OUTPUT.PUT_LINE('NOME;MODO_EXIBICAO;GRUPO;TEXTO_CURTO;TEXTO_INTEGRAL');
        FOR I IN C_VERIFY_MSG_TYPE_COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                I.NOME
                || ';' || I.MODO_EXIBICAO
                || ';' || I.GRUPO
                || ';' || I.TEXTO_CURTO
                || ';' || I.TEXTO_INTEGRAL
            );
        END LOOP;
                
    ELSIF (WF_COUNT > 0) THEN
        DBMS_OUTPUT.PUT_LINE('WF Stop encontrado');
        DBMS_OUTPUT.PUT_LINE('NOME_WORKFLOW;VERSAO;STATUS;STEP;TIPO;VALOR_SEARCH_SPEC');
        FOR I IN C_VERIFY_WF LOOP
            DBMS_OUTPUT.PUT_LINE(
                I.NOME_WORKFLOW
                || ';' || I.VERSAO
                || ';' || I.STATUS
                || ';' || I.STEP
                || ';' || I.TIPO
                || ';' || I.VALOR_SEARCH_SPEC
            );
        END LOOP;
		
	ELSIF (BCS_COUNT > 0) THEN
        DBMS_OUTPUT.PUT_LINE('Server Script de BC encontrado');
        DBMS_OUTPUT.PUT_LINE('ID_BC;NOME_BC;TABLE_BC;NOME_SCRIPT;SCRIPT');
        FOR I IN C_VERIFY_BC_SCRIPT LOOP
            DBMS_OUTPUT.PUT_LINE(
                I.ID_BC
                || ';' || I.NOME_BC
                || ';' || I.TABLE_BC
                || ';' || I.NOME_SCRIPT
                || ';' || I.SCRIPT
            );
        END LOOP;
		
	ELSIF (BSS_COUNT > 0) THEN
        DBMS_OUTPUT.PUT_LINE('Server Script de BS encontrado');
        DBMS_OUTPUT.PUT_LINE('ID_BS;NOME_BS;NOME_SCRIPT;SCRIPT');
        FOR I IN C_VERIFY_BS_SCRIPT LOOP
            DBMS_OUTPUT.PUT_LINE(
                I.ID_BS
                || ';' || I.NOME_BS
                || ';' || I.NOME_SCRIPT
                || ';' || I.SCRIPT
            );
        END LOOP;	
		
    ELSE
        DBMS_OUTPUT.PUT_LINE('Mensagem não encontrada!');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Fim da execução...');
END;