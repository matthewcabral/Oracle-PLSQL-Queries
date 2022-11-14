--Mapeamento de DataMap
SELECT
    DMAP.NAME 					AS "NOME",
    DMAP.SRC_INT_OBJ_NAME 		AS "IO_ORIGEM",
    DMAP.DST_INT_OBJ_NAME 		AS "IO_DESTINO",
    DMAP.COMMENTS 				AS "COMENTARIO",
    CMAP.NAME 					AS "NOME_COMPONENTE",
    CMAP.SRC_INT_COMP_NAME 		AS "COMP_ORIGEM",
    CMAP.DST_INT_COMP_NAME 		AS "COMP_DESTINO",
    CMAP.SRC_SRCHSPEC 			AS "SEARCH_EXP",
    CMAP.COMMENTS 				AS "COMENTARIO_COMP",
    FMAP.SRC_EXPR 				AS "EXP_ORIGEM",
    FMAP.DST_INT_FLD_NAME 		AS "EXP_DESTINO",
    FMAP.INACTIVE_FLG 			AS "ATIVO",
    FMAP.COMMENTS 				AS "COMENTARIO_FIELD"
FROM SIEBEL.S_INT_OBJMAP DMAP
FULL JOIN SIEBEL.S_INT_COMPMAP CMAP ON CMAP.INT_OBJ_MAP_ID = DMAP.ROW_ID
FULL JOIN SIEBEL.S_INT_FLDMAP FMAP ON FMAP.INT_COMP_MAP_ID = CMAP.ROW_ID
WHERE 1=1
--AND DMAP.NAME = 'NV Power Curve Check Credit Request'
AND CMAP.SRC_INT_COMP_NAME LIKE '%GOL Vouc Execute Schedulled WF%';