DECLARE
-- VARIAVEIS
    V_NOME_WF VARCHAR(100):='TCC WF SOA149 Consulta Envio Relatorio Detalhado';--'Check Eligibility % Compatibility - Default';
    V_DEFAULT_COMMENT VARCHAR(200):='WF alterado para corre��o de problemas de versionamento';
	V_WF_ROW_ID VARCHAR(15);
    V_WF_NAME VARCHAR(200);
    V_STATUS VARCHAR(20);
	V_INATIVE_FLG CHAR(1);
    V_MENOR_VERSAO INTEGER;
    V_MAIOR_VERSAO INTEGER;
	V_HAS_VERSAO_INATIVA INTEGER;
	V_HAS_VERSAO_ATIVA INTEGER;
	V_HAS_VERSAO_ATIVA_NUM INTEGER;
    V_COUNT_ATIVO INTEGER;
	V_COUNT_ATIVO_LOCAL INTEGER;
    V_COUNT_ATIVO_ZERO INTEGER;
    V_COUNT_INATIVO INTEGER;
    V_IGUAL VARCHAR(10);
    V_VERSION INTEGER;
	V_WF_VERSION INTEGER;
	V_WS_ID VARCHAR(15):='1@981';

    CURSOR WF_V_ATIVA IS
        SELECT
            WF.ROW_ID,
            WF.PROC_NAME,
			WF.NAME,
            WF.VERSION,
            WF.STATUS_CD,
            WF.INACTIVE_FLG,
			WF.WS_ID
        FROM SIEBEL.S_WFR_PROC WF
        WHERE WF.PROC_NAME LIKE V_NOME_WF
        AND WF.STATUS_CD = V_STATUS
        AND ((WF.VERSION = '0' AND V_IGUAL = 'TRUE') OR (WF.VERSION <> '0' AND V_IGUAL <> 'TRUE'))
        AND WF.INACTIVE_FLG = V_INATIVE_FLG
		AND WF.WS_ID = V_WS_ID
        ORDER BY WF.PROC_NAME ASC, WF.VERSION DESC;

	CURSOR WF_VERSION IS
        SELECT
            WF.ROW_ID,
            WF.PROC_NAME,
			WF.NAME,
            WF.VERSION,
            WF.STATUS_CD,
            WF.INACTIVE_FLG,
			WF.WS_ID
        FROM SIEBEL.S_WFR_PROC WF
        WHERE (
            WF.PROC_NAME LIKE V_NOME_WF
            OR WF.PROC_NAME LIKE V_NOME_WF || '%OLD%'
        )
		AND WF.VERSION <> V_WF_VERSION
		--AND WF.WS_ID = V_WS_ID
        ORDER BY WF.PROC_NAME ASC, WF.VERSION DESC;
	
	CURSOR C_MAIOR_VERSAO IS
		SELECT
			WF.ROW_ID,
			WF.PROC_NAME,
			WF.NAME,
			WF.VERSION,
			WF.STATUS_CD,
			WF.INACTIVE_FLG,
			WF.WS_ID
		FROM SIEBEL.S_WFR_PROC WF
		WHERE WF.PROC_NAME LIKE V_NOME_WF || '%OLD%'
		AND WF.VERSION = V_MAIOR_VERSAO
		--AND WF.WS_ID = V_WS_ID
		ORDER BY WF.PROC_NAME ASC, WF.VERSION DESC;

	CURSOR C_GET_VERSION_ACTIVE IS
		SELECT
			WF.ROW_ID,
			WF.PROC_NAME,
			WF.NAME,
			WF.VERSION,
			WF.STATUS_CD,
			WF.INACTIVE_FLG,
			WF.WS_ID
		FROM SIEBEL.S_WFR_PROC WF
		INNER JOIN SIEBEL.S_WORKSPACE WS ON WS.ROW_ID = WF.WS_ID
		WHERE WF.PROC_NAME = V_NOME_WF
			AND WF.VERSION = V_HAS_VERSAO_ATIVA_NUM
			AND WF.INACTIVE_FLG = 'N'
		ORDER BY WF.VERSION DESC;
        
    CURSOR C_VERIFY_HAS_VERSION_INATIVE (V_WF_NAME IN VARCHAR, V_VER IN VARCHAR) IS
        SELECT
            WF.ROW_ID,
            WF.PROC_NAME,
            WF.NAME,
            WF.VERSION,
            WF.STATUS_CD,
            WF.INACTIVE_FLG
        FROM SIEBEL.S_WFR_PROC WF
        INNER JOIN SIEBEL.S_WORKSPACE WS ON WS.ROW_ID = WF.WS_ID
        WHERE (
            WF.PROC_NAME = V_WF_NAME
            AND WF.VERSION = V_VER
            AND WF.INACTIVE_FLG = 'Y'
        )
        OR (
            (
                WF.PROC_NAME LIKE V_WF_NAME || '%OLD%'
                OR WF.PROC_NAME LIKE V_WF_NAME || '%old%'
                OR WF.PROC_NAME LIKE V_WF_NAME || '%Old%'
            )
            AND WF.VERSION = V_VER
        )
        ORDER BY WF.VERSION DESC;
		
    CURSOR RESULT_FINAL IS
        SELECT
            WF.ROW_ID,
            WF.PROC_NAME,
			WF.NAME,
            WF.VERSION,
            WF.STATUS_CD,
            WF.INACTIVE_FLG,
			WF.WS_ID
        FROM SIEBEL.S_WFR_PROC WF
        WHERE (
			WF.PROC_NAME LIKE V_NOME_WF
			OR WF.PROC_NAME LIKE V_NOME_WF || '_OLD'
		)
		AND WF.WS_ID = V_WS_ID
        ORDER BY WF.PROC_NAME ASC, WF.VERSION DESC;

    -- FUNCAO QUE VERIFICA A MENOR VERSAO DO WF
    FUNCTION VERIFY_MIN_VERSION RETURN INTEGER IS  
        N INTEGER;
        BEGIN
            SELECT
                MIN(WF.VERSION)
            INTO N
            FROM SIEBEL.S_WFR_PROC WF
            WHERE WF.PROC_NAME LIKE V_NOME_WF
			AND WF.WS_ID = V_WS_ID;
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
            WHERE WF.PROC_NAME LIKE V_NOME_WF
			AND WF.WS_ID = V_WS_ID;
            RETURN N;
        END;
	
	FUNCTION VERIFY_HAS_MAX_VERSION_INATIVE (V_WF_NAME IN VARCHAR, V_VER IN VARCHAR) RETURN INTEGER IS
		N INTEGER;
		BEGIN
			SELECT
				COUNT(*)
			INTO N
			FROM SIEBEL.S_WFR_PROC WF
			INNER JOIN SIEBEL.S_WORKSPACE WS ON WS.ROW_ID = WF.WS_ID
			WHERE (
				WF.PROC_NAME = V_WF_NAME
				AND WF.VERSION = V_VER
				AND WF.INACTIVE_FLG = 'Y'
			)
			OR (
				(
                    WF.PROC_NAME LIKE V_WF_NAME || '%OLD%'
                    OR WF.PROC_NAME LIKE V_WF_NAME || '%old%'
                    OR WF.PROC_NAME LIKE V_WF_NAME || '%Old%'
                )
				AND WF.VERSION = V_VER
			)
			ORDER BY WF.VERSION DESC;
            RETURN N;
		END;
		
	FUNCTION VERIFY_HAS_VERSION_ACTIVE (V_WF_NAME IN VARCHAR, V_VER IN VARCHAR) RETURN INTEGER IS
		N INTEGER;
		BEGIN
			SELECT
				COUNT(*)
			INTO N
			FROM SIEBEL.S_WFR_PROC WF
			INNER JOIN SIEBEL.S_WORKSPACE WS ON WS.ROW_ID = WF.WS_ID
			WHERE (
				WF.PROC_NAME = V_WF_NAME
				AND WF.VERSION = V_VER
				AND WF.INACTIVE_FLG = 'N'
			)
			ORDER BY WF.VERSION DESC;
            RETURN N;
		END;
		
	-- FUNCAO QUE VERIFICA A VERSAO DO WF
    FUNCTION COMPARE_VERSION (V_VER IN VARCHAR) RETURN INTEGER IS
        RESULTADO INTEGER;
		N INTEGER;
        BEGIN
			SELECT
				WF.VERSION
			INTO N
			FROM SIEBEL.S_WFR_PROC WF
			WHERE WF.PROC_NAME LIKE V_NOME_WF
			AND WF.VERSION = V_VER
			AND WF.STATUS_CD = 'COMPLETED'			
			AND WF.INACTIVE_FLG = 'N'
			AND WF.WS_ID = V_WS_ID;
		
			IF(N = V_MAIOR_VERSAO) THEN
				RESULTADO := 0;
			ELSE
				RESULTADO := 1;
			END IF;
			
            RETURN RESULTADO;
        END;

    PROCEDURE P_UPDATE_OLD IS
        BEGIN
            UPDATE SIEBEL.S_WFR_PROC WF
            SET WF.INACTIVE_FLG = 'Y',
                WF.STATUS_CD = 'NOT_IN_USE'
            WHERE WF.PROC_NAME LIKE V_NOME_WF || '_OLD';
        END;
        
    -- PROCEDURE USADA PARA TROCA DAS VERSOES
    PROCEDURE ALTERAR_WF (V_ID IN VARCHAR, V_NOME IN VARCHAR, V_FLG IN VARCHAR, V_STATUS IN VARCHAR, V_VER IN VARCHAR) IS
        BEGIN
            UPDATE SIEBEL.S_WFR_PROC WF
            SET WF.PROC_NAME = V_NOME,
				WF.NAME = V_NOME || ': ' || V_VER,
                WF.DESC_TEXT = V_DEFAULT_COMMENT,
				WF.INACTIVE_FLG = V_FLG,
                WF.STATUS_CD = V_STATUS,
                WF.VERSION = V_VER
            WHERE ROW_ID = V_ID;
        END;

    PROCEDURE P_UPDATE_WF_NAME (R_ID IN VARCHAR, WF_NAME IN VARCHAR, WF_VERSION IN VARCHAR) IS
        BEGIN
            UPDATE SIEBEL.S_WFR_PROC WF
                SET WF.NAME = WF_NAME || ': ' || WF_VERSION
            WHERE ROW_ID = R_ID;
        END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inicio da execucao...');
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('VERIFICANDO A MAIOR E MENOR VERSAO DO WF: ' || V_NOME_WF);
    V_MENOR_VERSAO := VERIFY_MIN_VERSION;
    V_MAIOR_VERSAO := VERIFY_MAX_VERSION;
    -- APENAS PARA CONTROLE EM EXIBICAO DOS DADOS NA TELA
    DBMS_OUTPUT.PUT_LINE('MENOR VERSAO: ' || V_MENOR_VERSAO);
    DBMS_OUTPUT.PUT_LINE('MAIOR VERSAO: ' || V_MAIOR_VERSAO);
    DBMS_OUTPUT.PUT_LINE('');

	DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE POSSUI VERSAO ATIVA = 0...');
	V_COUNT_ATIVO_ZERO := 0;
	-- VERIFICA SE O WF TEM VERSAO ATIVA = 0
	V_IGUAL := 'TRUE';
	V_STATUS := 'COMPLETED';
	V_INATIVE_FLG := 'N';
	FOR i IN WF_V_ATIVA LOOP
		DBMS_OUTPUT.PUT_LINE(
			'VERSAO ATIVA: ' ||
			'ROW_ID: ' || i.ROW_ID || '; ' ||
			'NOME PROC: ' || i.PROC_NAME || '; ' ||
			'NOME: ' || i.NAME || '; ' ||
			'VERSAO: ' || i.VERSION || '; ' ||
			'STATUS: '|| i.STATUS_CD || '; ' ||
			'INATIVE_FLAG: '|| i.INACTIVE_FLG
		);
		V_COUNT_ATIVO_ZERO := V_COUNT_ATIVO_ZERO + 1;
        --P_UPDATE_WF_NAME (i.ROW_ID, i.NAME, i.VERSION);
        --COMMIT;
        DBMS_OUTPUT.PUT_LINE(
			'ATUALIZANDO O NOME DA VERSAO: ' ||
			'ROW_ID: ' || i.ROW_ID || '; ' ||
			'NOME PROC: ' || i.PROC_NAME || '; ' ||
			'NOME: ' || i.PROC_NAME || ': ' || i.VERSION || '; ' ||
			'VERSAO: ' || i.VERSION || '; ' ||
			'STATUS: '|| i.STATUS_CD || '; ' ||
			'INATIVE_FLAG: '|| i.INACTIVE_FLG
		);
	END LOOP;
	
	IF(V_COUNT_ATIVO_ZERO > 0) THEN
		DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO_ZERO);
		DBMS_OUTPUT.PUT_LINE('');
		
		-- VERIFICO SE POSSUI ALGUMA OUTRA VERSAO ATIVA <> 0
		V_COUNT_ATIVO := 0;
		V_IGUAL := 'FALSE';
		V_STATUS := 'COMPLETED';
		V_INATIVE_FLG := 'N';
		DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE POSSUI VERSAO ATIVA <> 0...');
		FOR i IN WF_V_ATIVA LOOP
			V_COUNT_ATIVO := V_COUNT_ATIVO + 1;
			
			IF(V_COUNT_ATIVO > 0) THEN
				DBMS_OUTPUT.PUT_LINE(
					'INATIVANDO E RENOMENANDO A VERSAO: ' || i.VERSION || '... | ' ||
					'RESULTADO FINAL: ' ||
					'ROW_ID: ' || i.ROW_ID || '; ' ||
					'NOME: ' || V_NOME_WF || '_OLD; ' ||
					'VERSAO: ' || i.VERSION || '; ' ||
					'STATUS: '|| 'NOT_IN_USE' || '; ' ||
					'INATIVE_FLAG: '|| 'Y'
				);
				--ALTERAR_WF(i.ROW_ID, (V_NOME_WF || '_OLD'), 'Y', 'NOT_IN_USE', i.VERSION);
				--COMMIT;
			END IF;
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO);
		DBMS_OUTPUT.PUT_LINE('');
		
		-- VERIFICO SE POSSUI ALGUMA OUTRA VERSAO <> 0
		V_COUNT_ATIVO := 0;
		V_WF_VERSION := 0;
		DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE POSSUI VERSAO <> 0...');
		FOR i IN WF_VERSION LOOP
			V_COUNT_ATIVO := V_COUNT_ATIVO + 1;
			
			IF(V_COUNT_ATIVO > 0) THEN
				DBMS_OUTPUT.PUT_LINE(
					'INATIVANDO E RENOMENANDO A VERSAO: ' || i.VERSION || '... | ' ||
					'RESULTADO FINAL: ' ||
					'ROW_ID: ' || i.ROW_ID || '; ' ||
					'NOME: ' || V_NOME_WF || '_OLD; ' ||
					'VERSAO: ' || i.VERSION || '; ' ||
					'STATUS: '|| 'NOT_IN_USE' || '; ' ||
					'INATIVE_FLAG: '|| 'Y'
				);
				--ALTERAR_WF(i.ROW_ID, (V_NOME_WF || '_OLD'), 'Y', 'NOT_IN_USE', i.VERSION);
				--COMMIT;
			END IF;
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO);
        DBMS_OUTPUT.PUT_LINE('');
        
        -- VERIFICO SE POSSUI POSSUI VERSAO 0 INATIVA OU ANTIGA (_OLD, OLD OU OLDER)...'
		V_COUNT_ATIVO := 0;
        DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE EXISTE ALGUMA VERSAO "0" INATIVA OU ANTIGA (_OLD, OLD OU OLDER)...');
        FOR I IN C_VERIFY_HAS_VERSION_INATIVE(V_NOME_WF, '0') LOOP
            V_COUNT_ATIVO := V_COUNT_ATIVO + 1;
            DBMS_OUTPUT.PUT_LINE(
					'INATIVANDO E RENOMENANDO A VERSAO: ' || i.VERSION || '... | ' ||
					'RESULTADO FINAL: ' ||
					'ROW_ID: ' || i.ROW_ID || '; ' ||
					'NOME PROC: ' || V_NOME_WF || '_OLD; ' ||
                    'NOME: ' || V_NOME_WF || '_OLD: ' || i.VERSION || '; ' ||
					'VERSAO: ' || i.VERSION || '; ' ||
					'STATUS: '|| 'NOT_IN_USE' || '; ' ||
					'INATIVE_FLAG: '|| 'Y'
				);
            --ALTERAR_WF(i.ROW_ID, (V_NOME_WF || '_OLD'), 'Y', 'NOT_IN_USE', i.VERSION);
            --COMMIT;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO);
        DBMS_OUTPUT.PUT_LINE('');
        
        /*
        -- VERIFICO SE POSSUI POSSUI VERSAO INATIVA OU ANTIGA (_OLD, OLD OU OLDER)...'
		V_COUNT_ATIVO := 0;
        DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE EXISTE ALGUMA VERSAO "0" INATIVA OU ANTIGA (_OLD, OLD OU OLDER)...');
        FOR I IN C_VERIFY_HAS_VERSION_INATIVE(V_NOME_WF, '0') LOOP
            V_COUNT_ATIVO := V_COUNT_ATIVO + 1;
            DBMS_OUTPUT.PUT_LINE(
					'INATIVANDO E RENOMENANDO A VERSAO: ' || i.VERSION || '... | ' ||
					'RESULTADO FINAL: ' ||
					'ROW_ID: ' || i.ROW_ID || '; ' ||
					'NOME PROC: ' || V_NOME_WF || '_OLD; ' ||
                    'NOME: ' || V_NOME_WF || '_OLD: ' || i.VERSION || '; ' ||
					'VERSAO: ' || i.VERSION || '; ' ||
					'STATUS: '|| 'NOT_IN_USE' || '; ' ||
					'INATIVE_FLAG: '|| 'Y'
				);
            --ALTERAR_WF(i.ROW_ID, (V_NOME_WF || '_OLD'), 'Y', 'NOT_IN_USE', i.VERSION);
            --COMMIT;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO);
        DBMS_OUTPUT.PUT_LINE('');
        */
    ELSE
        DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO_ZERO);
		-- VERIFICO SE POSSUI ALGUMA VERSAO ATIVA <> 0
		V_COUNT_ATIVO := 0;
		V_COUNT_ATIVO_LOCAL := 0;
		V_IGUAL := 'FALSE';
		V_STATUS := 'COMPLETED';
		V_INATIVE_FLG := 'N';
		DBMS_OUTPUT.PUT_LINE('');
		DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE POSSUI VERSAO ATIVA <> 0...');
		FOR i IN WF_V_ATIVA LOOP
			V_COUNT_ATIVO := V_COUNT_ATIVO + 1;
			V_COUNT_ATIVO_LOCAL := V_COUNT_ATIVO_LOCAL + 1;
			
			IF(V_COUNT_ATIVO > 0) THEN
				IF(V_COUNT_ATIVO = 1) THEN
					IF(I.VERSION <> V_MAIOR_VERSAO) THEN
						--VERIFICO SE A MAIOR VERSAO TEM ALGUM INATIVO EM OUTRAS WS
						DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE A MAIOR VERSAO (' || V_MAIOR_VERSAO || ') POSSUI VERSAO INATIVA OU ANTIGA (_OLD, OLD OU OLDER)...');
						V_HAS_VERSAO_INATIVA := VERIFY_HAS_MAX_VERSION_INATIVE(i.PROC_NAME, V_MAIOR_VERSAO);
						IF(V_HAS_VERSAO_INATIVA > 0) THEN
							DBMS_OUTPUT.PUT_LINE('POSSUI VERSAO INATIVA... TOTAL: ' || V_HAS_VERSAO_INATIVA || ', PORTANTO A MESMA SERA INATIVADA E TROCADA PELA VERSAO ATIVA: ' || I.VERSION);
							DBMS_OUTPUT.PUT_LINE('');
							DBMS_OUTPUT.PUT_LINE('VERIFICANDO SE A VERSAO ATUAL (' || I.VERSION ||') POSSUI VERSAO ATIVA EM OUTROS WORKSPACES');							
							-- VEJO SE A VERSAO ATUAL TEM ALGUMA VERSAO ATIVA EM OUTRAS WS
							V_HAS_VERSAO_ATIVA := VERIFY_HAS_VERSION_ACTIVE(i.PROC_NAME, I.VERSION);
							IF(V_HAS_VERSAO_ATIVA > 0) THEN
								DBMS_OUTPUT.PUT_LINE('POSSUI VERSAO ATIVA... TOTAL: ' || V_HAS_VERSAO_ATIVA);
								DBMS_OUTPUT.PUT_LINE('');
								V_HAS_VERSAO_ATIVA_NUM := I.VERSION;
								FOR A IN C_GET_VERSION_ACTIVE LOOP
									--ALTERO TEMPORARIAMENTE PARA MAIOR VERSAO + 1
									DBMS_OUTPUT.PUT_LINE(
										'ALTERANDO PARA VERSAO TEMPORARIA: ' ||
										'ROW_ID: ' || A.ROW_ID || '; ' ||
										'NOME: ' || A.PROC_NAME || '; ' ||
										'VERSAO: ' || A.VERSION || '; ' ||
										'STATUS: '|| A.STATUS_CD || '; ' ||
										'INATIVE_FLAG: '|| A.INACTIVE_FLG ||
										' | VERSAO TEMPORARIA: ' || (V_MAIOR_VERSAO + 1)
									);
									--ALTERAR_WF(A.ROW_ID, A.PROC_NAME, 'N', 'COMPLETED', (V_MAIOR_VERSAO + 1));
									--COMMIT;
								END LOOP;
								
								DBMS_OUTPUT.PUT_LINE('');
								--PEGO TODAS AS MAIORES VERSOES ATUAIS E ALTERO PARA A MAIOR VERSAO - 1
								FOR l IN C_MAIOR_VERSAO LOOP
									DBMS_OUTPUT.PUT_LINE(
										'ALTERANDO A MAIOR VERSAO: ' ||
										'ROW_ID: ' || l.ROW_ID || '; ' ||
										'NOME: ' || l.PROC_NAME || '_OLD; ' ||
										'VERSAO: ' || l.VERSION || '; ' ||
										'STATUS: '|| l.STATUS_CD || '; ' ||
										'INATIVE_FLAG: '|| l.INACTIVE_FLG ||
										' | NOVA VERSAO: ' || i.VERSION
									);
									--ALTERAR_WF(l.ROW_ID, (l.PROC_NAME || '_OLD'), 'N', 'NOT_IN_USE', i.VERSION);
									--COMMIT;
								END LOOP;						
								
								DBMS_OUTPUT.PUT_LINE('');
								V_HAS_VERSAO_ATIVA_NUM := (V_MAIOR_VERSAO + 1);
								FOR B IN C_GET_VERSION_ACTIVE LOOP
									-- PEGO TODOS OS WFS TEMPORARIOS E VOLTO ELSE PARA A MAIOR VERSAO
									DBMS_OUTPUT.PUT_LINE(
										'ALTERANDO PARA VERSAO FINAL: ' ||
										'ROW_ID: ' || B.ROW_ID || '; ' ||
										'NOME: ' || B.PROC_NAME || '; ' ||
										'VERSAO: ' || B.VERSION || '; ' ||
										'STATUS: '|| B.STATUS_CD || '; ' ||
										'INATIVE_FLAG: '|| B.INACTIVE_FLG ||
										' | VERSAO FINAL: ' || V_MAIOR_VERSAO
									);
									--ALTERAR_WF(B.ROW_ID, B.PROC_NAME, 'N', 'COMPLETED', V_MAIOR_VERSAO);
									--COMMIT;
								END LOOP;
							ELSE
								DBMS_OUTPUT.PUT_LINE('');
								DBMS_OUTPUT.PUT_LINE('ENTROU NO ELSE DE VERSAO ATIVA. V_HAS_VERSAO_ATIVA = ' || V_HAS_VERSAO_ATIVA);
								DBMS_OUTPUT.PUT_LINE('');
								--ALTERO TEMPORARIAMENTE PARA MAIOR VERSAO + 1						
								DBMS_OUTPUT.PUT_LINE(
									'ALTERANDO PARA VERSAO TEMPORARIA: ' ||
									'ROW_ID: ' || i.ROW_ID || '; ' ||
									'NOME: ' || i.PROC_NAME || '; ' ||
									'VERSAO: ' || i.VERSION || '; ' ||
									'STATUS: '|| i.STATUS_CD || '; ' ||
									'INATIVE_FLAG: '|| i.INACTIVE_FLG ||
									' | VERSAO TEMPORARIA: ' || (V_MAIOR_VERSAO + 1)
								);
								--ALTERAR_WF(i.ROW_ID, i.PROC_NAME, 'N', 'COMPLETED', (V_MAIOR_VERSAO + 1));
								--COMMIT;
								
								--PEGO TODAS AS MAIORES VERSOES ATUAIS E ALTERO PARA A MAIOR VERSAO - 1
								FOR l IN C_MAIOR_VERSAO LOOP
									DBMS_OUTPUT.PUT_LINE(
										'ALTERANDO A MAIOR VERSAO: ' ||
										'ROW_ID: ' || l.ROW_ID || '; ' ||
										'NOME: ' || l.PROC_NAME || '_OLD; ' ||
										'VERSAO: ' || l.VERSION || '; ' ||
										'STATUS: '|| l.STATUS_CD || '; ' ||
										'INATIVE_FLAG: '|| l.INACTIVE_FLG ||
										' | NOVA VERSAO: ' || i.VERSION
									);
									--ALTERAR_WF(l.ROW_ID, (l.PROC_NAME || '_OLD'), 'N', 'NOT_IN_USE', i.VERSION);
									--COMMIT;
								END LOOP;						
						
								-- PEGO TODOS OS WFS TEMPORARIOS E VOLTO ELSE PARA A MAIOR VERSAO
								DBMS_OUTPUT.PUT_LINE(
									'ALTERANDO PARA VERSAO FINAL: ' ||
									'ROW_ID: ' || i.ROW_ID || '; ' ||
									'NOME: ' || i.PROC_NAME || '; ' ||
									'VERSAO: ' || i.VERSION || '; ' ||
									'STATUS: '|| i.STATUS_CD || '; ' ||
									'INATIVE_FLAG: '|| i.INACTIVE_FLG ||
									' | VERSAO FINAL: ' || V_MAIOR_VERSAO
								);
								--ALTERAR_WF(i.ROW_ID, i.PROC_NAME, 'N', 'COMPLETED', V_MAIOR_VERSAO);
								--COMMIT;
							END IF;
						ELSE
							DBMS_OUTPUT.PUT_LINE('ENTROU NO ELSE DE MAIOR VERSAO INATIVA. V_HAS_VERSAO_INATIVA = ' || V_HAS_VERSAO_INATIVA);
							DBMS_OUTPUT.PUT_LINE('');
							--ALTERO TEMPORARIAMENTE PARA MAIOR VERSAO + 1						
								DBMS_OUTPUT.PUT_LINE(
									'ALTERANDO PARA VERSAO TEMPORARIA: ' ||
									'ROW_ID: ' || i.ROW_ID || '; ' ||
									'NOME: ' || i.PROC_NAME || '; ' ||
									'VERSAO: ' || i.VERSION || '; ' ||
									'STATUS: '|| i.STATUS_CD || '; ' ||
									'INATIVE_FLAG: '|| i.INACTIVE_FLG ||
									' | VERSAO TEMPORARIA: ' || (V_MAIOR_VERSAO + 1)
								);
								--ALTERAR_WF(i.ROW_ID, i.PROC_NAME, 'N', 'COMPLETED', (V_MAIOR_VERSAO + 1));
								--COMMIT;
								
								--PEGO TODAS AS MAIORES VERSOES ATUAIS E ALTERO PARA A MAIOR VERSAO - 1
								FOR l IN C_MAIOR_VERSAO LOOP
									DBMS_OUTPUT.PUT_LINE(
										'ALTERANDO A MAIOR VERSAO: ' ||
										'ROW_ID: ' || l.ROW_ID || '; ' ||
										'NOME: ' || l.PROC_NAME || '_OLD; ' ||
										'VERSAO: ' || l.VERSION || '; ' ||
										'STATUS: '|| l.STATUS_CD || '; ' ||
										'INATIVE_FLAG: '|| l.INACTIVE_FLG ||
										' | NOVA VERSAO: ' || i.VERSION
									);
									--ALTERAR_WF(l.ROW_ID, (l.PROC_NAME || '_OLD'), 'N', 'NOT_IN_USE', i.VERSION);
									--COMMIT;
								END LOOP;						
						
								-- PEGO TODOS OS WFS TEMPORARIOS E VOLTO ELSE PARA A MAIOR VERSAO
								DBMS_OUTPUT.PUT_LINE(
									'ALTERANDO PARA VERSAO FINAL: ' ||
									'ROW_ID: ' || i.ROW_ID || '; ' ||
									'NOME: ' || i.PROC_NAME || '; ' ||
									'VERSAO: ' || i.VERSION || '; ' ||
									'STATUS: '|| i.STATUS_CD || '; ' ||
									'INATIVE_FLAG: '|| i.INACTIVE_FLG ||
									' | VERSAO FINAL: ' || V_MAIOR_VERSAO
								);
								--ALTERAR_WF(i.ROW_ID, i.PROC_NAME, 'N', 'COMPLETED', V_MAIOR_VERSAO);
								--COMMIT;
						END IF;
					ELSE
						DBMS_OUTPUT.PUT_LINE(
							'VERSAO ATIVA: ' ||
							'ROW_ID: ' || i.ROW_ID || '; ' ||
							'NOME: ' || i.PROC_NAME || '; ' ||
							'VERSAO: ' || i.VERSION || '; ' ||
							'STATUS: '|| i.STATUS_CD || '; ' ||
							'INATIVE_FLAG: '|| i.INACTIVE_FLG ||
							' | MAIOR VERSAO : ' || V_MAIOR_VERSAO
						);
						V_COUNT_ATIVO := 0;
					END IF;
				END IF;
			END IF;
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO_LOCAL);
		DBMS_OUTPUT.PUT_LINE('');
		
		-- INATIVANDO TODAS AS OUTRAS VERSOES
		DBMS_OUTPUT.PUT_LINE('INATIVANDO TODAS AS OUTRAS VERSOES...');
		V_WF_VERSION := V_MAIOR_VERSAO;
		V_COUNT_ATIVO := 0;
		FOR i IN WF_VERSION LOOP
			V_COUNT_ATIVO := V_COUNT_ATIVO + 1;
			
			IF(V_COUNT_ATIVO > 0) THEN
				DBMS_OUTPUT.PUT_LINE(
					'INATIVANDO E RENOMENANDO A VERSAO: ' || i.VERSION || '... | ' ||
					'RESULTADO FINAL: ' ||
					'ROW_ID: ' || i.ROW_ID || '; ' ||
					'NOME: ' || V_NOME_WF || '_OLD; ' ||
					'VERSAO: ' || i.VERSION || '; ' ||
					'STATUS: '|| 'NOT_IN_USE' || '; ' ||
					'INATIVE_FLAG: '|| 'Y'
				);
				--ALTERAR_WF(i.ROW_ID, (V_NOME_WF || '_OLD'), 'Y', 'NOT_IN_USE', i.VERSION);
				--COMMIT;
			END IF;
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_COUNT_ATIVO);
	
	END IF;
    
    P_UPDATE_OLD;
    --COMMIT;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('                               RESULTADO FINAL                               ');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------');
    -- LOOP USADO APENAS PARA EXIBICAO DAS ALTERACOES NA TELA
    FOR L IN RESULT_FINAL LOOP        
        DBMS_OUTPUT.PUT_LINE(
            'ROW_ID: ' || L.ROW_ID || '; ' ||
            'NOME PROC: ' || L.PROC_NAME || '; ' ||
			'NOME: ' || L.NAME || '; ' ||
            'VERSAO: ' || L.VERSION || '; ' ||
            'STATUS: '|| L.STATUS_CD || '; ' ||
            'INATIVE_FLAG: '|| L.INACTIVE_FLG
        );
        
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------');    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Fim da execucao');
END;