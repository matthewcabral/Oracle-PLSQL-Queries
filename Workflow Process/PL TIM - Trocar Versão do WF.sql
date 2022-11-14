DECLARE
	-- VARIAVEIS
    V_NOME_WF VARCHAR(100):='FIBER Async Order Submit';
    V_MENOR_VERSAO INTEGER;
    V_MAIOR_VERSAO INTEGER;
    V_COUNT INTEGER;
    
	-- CURSOR QUE VERIFICA QUAL VERSAO DO WF ESTA ATIVA
    CURSOR WF_VERSAO_ATIVA IS
        SELECT
            WF.ROW_ID,
            WF.VERSION,
            WF.STATUS_CD,
            WF.INACTIVE_FLG
        FROM SIEBEL.S_WFR_PROC WF
        WHERE WF.PROC_NAME = V_NOME_WF
        AND WF.STATUS_CD = 'COMPLETED'
        ORDER BY WF.VERSION DESC;
    
    -- CURSOR QUE VERIFICA AS VERSÕES INATIVAS
    CURSOR WF_VERSAO_INATIVA IS
        SELECT
            WF.ROW_ID
        FROM SIEBEL.S_WFR_PROC WF
        WHERE WF.PROC_NAME = V_NOME_WF
        AND WF.STATUS_CD = 'NOT_IN_USE'
        ORDER BY WF.VERSION DESC;
    
	-- CURSOR QUE VERIFICA QUAL VERSAO DO WF SERA TROCADA PELA NOVA
    CURSOR WF_NOVA_VERSAO IS
       SELECT
            WF.ROW_ID,
            WF.VERSION,
            WF.STATUS_CD,
            WF.INACTIVE_FLG
        FROM SIEBEL.S_WFR_PROC WF
        WHERE WF.PROC_NAME = V_NOME_WF
        AND WF.VERSION = V_MENOR_VERSAO;
	
	-- CURSOR QUE VERIFICA QUAL A MAIOR VERSAO DO WF
    CURSOR WF_MAIOR_VERSAO IS
       SELECT
            WF.ROW_ID,
            WF.VERSION,
            WF.STATUS_CD,
            WF.INACTIVE_FLG
        FROM SIEBEL.S_WFR_PROC WF
        WHERE WF.PROC_NAME = V_NOME_WF
        AND WF.VERSION = V_MAIOR_VERSAO + 1;
           
	-- FUNCAO QUE VERIFICA A MENOR VERSAO DO WF
    FUNCTION VERIFY_MIN_VERSION RETURN INTEGER IS
        N INTEGER;
        BEGIN
            SELECT
                MIN(WF.VERSION)
            INTO N
            FROM SIEBEL.S_WFR_PROC WF
            WHERE WF.PROC_NAME = V_NOME_WF;
            RETURN N;
        END;
    
    -- FUNCAO QUE VERIFICA A MAIOR VERSAO DO WF
    FUNCTION VERIFY_MAX_VERSION RETURN INTEGER IS
        N INTEGER;
        BEGIN
            SELECT
                MAX(WF.VERSION)
            INTO N
            FROM SIEBEL.S_WFR_PROC WF
            WHERE WF.PROC_NAME = V_NOME_WF;
            RETURN N;
        END;
    
	-- PROCEDURE USADA PARA TROCA DAS VERSOES
    PROCEDURE TROCAR_VERSAO (R_ID IN VARCHAR, FLG IN VARCHAR, STATUS IN VARCHAR, VER IN VARCHAR) IS
        BEGIN
            UPDATE SIEBEL.S_WFR_PROC WF
            SET WF.INACTIVE_FLG = FLG,
                WF.STATUS_CD = STATUS,
                WF.VERSION = VER
            WHERE ROW_ID = R_ID;
        END;
    
    PROCEDURE RENAME_WF (R_ID IN VARCHAR, WF_NAME IN VARCHAR) IS
        BEGIN
            UPDATE SIEBEL.S_WFR_PROC WF
            SET WF.PROC_NAME = WF_NAME
            WHERE ROW_ID = R_ID;
        END;
        
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inicio da execucao...');
    DBMS_OUTPUT.PUT_LINE('');
	-- APENAS PARA CONTROLE EM EXIBICAO DOS DADOS NA TELA
    V_MENOR_VERSAO := VERIFY_MIN_VERSION;
    V_MAIOR_VERSAO := VERIFY_MAX_VERSION;
    DBMS_OUTPUT.PUT_LINE('Menor Versao:' || V_MENOR_VERSAO);
    DBMS_OUTPUT.PUT_LINE('Maior Versao:' || V_MAIOR_VERSAO);
    DBMS_OUTPUT.PUT_LINE('');
    
	-- LOOP UTILITARIO USADO PARA PERCORRER O CURSOR DE WF DE MENOR VERSAO E TROCAR PELA MAIOR VERSAO + 1
    FOR J IN WF_NOVA_VERSAO LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Menor Versao: ' ||
            'ROW_ID: ' || J.ROW_ID || '; ' ||
            'VERSAO: ' || J.VERSION || '; ' ||
            'STATUS: '|| J.STATUS_CD || '; ' ||
            'INATIVE_FLAG: '|| J.INACTIVE_FLG
        );
        TROCAR_VERSAO(J.ROW_ID, 'Y', 'NOT_IN_USE', V_MAIOR_VERSAO + 1);
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('A menor versão foi alterada para a versão: ' || V_MAIOR_VERSAO + 1 || ' Temporariamente...');
    DBMS_OUTPUT.PUT_LINE('');
    
    V_COUNT := 0;
	-- LOOP USADO PARA PERCORRER O CURSOR DE WF DE VERSAO ATIVA E TROCAR PELA MENOR VERSAO (=0)
    FOR I IN WF_VERSAO_ATIVA LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Versao ativa: ' ||
            'ROW_ID: ' || I.ROW_ID || '; ' ||
            'VERSAO: ' || I.VERSION || '; ' ||
            'STATUS: '|| I.STATUS_CD || '; ' ||
            'INATIVE_FLAG: '|| I.INACTIVE_FLG
        );
        IF V_COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Atualizando versao ' || I.VERSION || ' para a versão correta: 0');
            TROCAR_VERSAO(I.ROW_ID, 'N', 'COMPLETED', '0');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Desativando versao ' || I.VERSION || ' ativa');
            TROCAR_VERSAO(I.ROW_ID, 'Y', 'NOT_IN_USE', I.VERSION);
        END IF;
        V_COUNT := V_COUNT + 1;
    END LOOP;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('');
    V_COUNT := 0;
	-- LOOP USADO PARA PERCORRER O CURSOR DE WF DE MAIOR VERSAO E TROCAR PELA MAIOR VERSAO ANTERIOR
    FOR J IN WF_MAIOR_VERSAO LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Versao temporaria: ' ||
            'ROW_ID: ' || J.ROW_ID || '; ' ||
            'VERSAO: ' || J.VERSION || '; ' ||
            'STATUS: '|| J.STATUS_CD || '; ' ||
            'INATIVE_FLAG: '|| J.INACTIVE_FLG
        );
        DBMS_OUTPUT.PUT_LINE('Atualizando a versao temporaria ' || V_MAIOR_VERSAO + 1 || ' para a versao correta: ' || V_MAIOR_VERSAO);
        TROCAR_VERSAO(J.ROW_ID, 'Y', 'NOT_IN_USE', V_MAIOR_VERSAO);
    END LOOP;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('');
    -- LOOP USADO PARA PERCORRER O CURSOR E TROCAR O NOME DO WF
    FOR K IN WF_VERSAO_INATIVA LOOP
        DBMS_OUTPUT.PUT_LINE('Trocando nome do WF para: ' || V_NOME_WF || '_old');
        DBMS_OUTPUT.PUT_LINE('ROW_ID: ' || K.ROW_ID);
        
        RENAME_WF(K.ROW_ID, V_NOME_WF || '_OLD');
    END LOOP;
    COMMIT;
    
	-- LOOP USADO APENAS PARA EXIBICAO DAS ALTERACOES NA TELA
    FOR L IN WF_NOVA_VERSAO LOOP
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('                               RESULTADO FINAL                               ');
        DBMS_OUTPUT.PUT_LINE(
            'ROW_ID: ' || L.ROW_ID || '; ' ||
            'VERSAO: ' || L.VERSION || '; ' ||
            'STATUS: '|| L.STATUS_CD || '; ' ||
            'INATIVE_FLAG: '|| L.INACTIVE_FLG
        );
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Fim da execucao');
    
END;
