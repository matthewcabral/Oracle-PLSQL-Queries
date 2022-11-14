SELECT
    RL.NAME             AS "NAME",
    RL.OBJECT_NAME      AS "WORKFLOW_OBJ",
    GR.NAME             AS "GROUP_NAME",
    LC.NAME             AS "COND_FIELD",
    CD.COND_OPERAND     AS "COND_OPERATION",
    CD.VAL              AS "COND_VALUE",
    ACC.NAME            AS "ACT_NAME",
    ACT.SEQUENCE        AS "ACT_SEQUENCE",
    ACC.PROGRAM_NAME    AS "ACT_PROG_NAME",
    ARG.NAME            AS "ARG_NAME",
    ARG.REQUIRED        AS "ARG_REQUIRED",
    ARG.DEFAULT_VALUE   AS "ARG_VALUE"
FROM SIEBEL.S_ESCL_RULE RL
RIGHT JOIN SIEBEL.S_ESCL_GROUP GR ON GR.ROW_ID = RL.GROUP_ID
LEFT JOIN SIEBEL.S_ESCL_COND CD ON CD.RULE_ID = RL.ROW_ID
LEFT JOIN SIEBEL.S_ESCL_COL CL ON CL.NAME = CD.LINK_COL_NAME
LEFT JOIN SIEBEL.S_ESCL_LINK_COL LC ON LC.COND_COL_ID = CL.ROW_ID
LEFT JOIN SIEBEL.S_ESCL_ACTION ACT ON ACT.RULE_ID = RL.ROW_ID
LEFT JOIN SIEBEL.S_ACTION_DEFN ACC ON ACC.ROW_ID = ACT.ACTION_ID
LEFT JOIN SIEBEL.S_ACTION_ARG ARG ON ARG.ACTION_ID = ACC.ROW_ID
WHERE 1=1
--AND RL.OBJECT_NAME LIKE '%Vou%';
AND ARG.DEFAULT_VALUE LIKE '%Vouc%';
AND RL.NAME LIKE '%Voucher%';
--AND RL.OBJECT_NAME LIKE '%Signature%';
AND RL.NAME LIKE '%Send%';
---AND LC.NAME LIKE 'Product Name'
AND CD.VAL LIKE '%Ren%';
AND CD.COND_OPERAND = 'IN';


/*----------------------------------------------------------------
                    FALTA FINALIZAR A QUERY
----------------------------------------------------------------*/
/*
Screen:
	Front Office Workflow
View:
	Workflow Policy Detail View
Business Object:
	Workflow Policy
Applets:
	Applet[0]: Workflow Policy List Without Navigation Applet;
	Applet[1]: Workflow Condition Applet;
	Applet[2]: Workflow Action Applet;
	Applet[3]: Workflow Action Argument Applet;
Business Components:
	BusComp[0]: Workflow Policy;
	BusComp[1]: Workflow Condition;
	BusComp[2]: Workflow Action;
	BusComp[3]: Workflow Action Argument;
*/
/*----------------------------------------------------------------*/