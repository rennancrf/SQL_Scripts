USE [ON_GOING]
GO
/****** Object:  StoredProcedure [dbo].[2TRI_SP_1.3_VALIDA_SISJUR_POSICOES]    Script Date: 30/10/2018 08:55:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rennan Correa
-- Create date: 16/08/2018
-- Description:	Procedure para validação das informações geradas na tabela de posições do SISJUR após a execução
--				da procedure [2TRI_SP_2.1_SISJUR_POSICOES] .


-- =============================================
ALTER PROCEDURE [dbo].[2TRI_SP_1.3_VALIDA_SISJUR_POSICOES]

AS
BEGIN

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DECLARAÇÃO DAS VARIAVEIS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DECLARE @ERRO INT
SET @ERRO = 0
DECLARE @DESCRICAO_ERRO VARCHAR(500)
SET @DESCRICAO_ERRO = NULL
DECLARE @INSERT VARCHAR(8000) 
SET @INSERT = NULL


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VERIFICA SE TABELA TEMPORÁRIA DE VALIDAÇÃO SISJUR JÁ EXISTE ~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SE SIM, A TABELA É DROPADA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
			
	PRINT '#############################################################################'  + CHAR(13)
	PRINT '############ INICIANDO PROCESSO DE VALIDAÇÃO DAS INFORMAÇÕES ################'  + CHAR(13)
	PRINT '####################### CRIANDO VALIDA SISJUR POSICOES ######################'  + CHAR(13)
	PRINT '#############################################################################'  + CHAR(13)

	BEGIN TRY

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_TAB_POS_SISJUR')
			DROP TABLE ##VALIDA_TAB_POS_SISJUR
		
		PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] TABELA APAGADA COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	END TRY
		
	BEGIN CATCH
	
			PRINT 'ATENÇÃO!!! FALHA AO APAGAR A TABELA [ON_GOING].[2_TRI].[POSICOES_SISJUR]!!!'
			SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
			PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
	
	END CATCH

	CREATE TABLE ##VALIDA_TAB_POS_SISJUR
	(
		TIPO						VARCHAR(50)		NULL
		,JUN_2017					MONEY			NULL
		,NOV_2017					MONEY			NULL
		,DEZ_2017					MONEY			NULL
		,MAR_18						MONEY			NULL
		,JUN_18						MONEY			NULL

		,JUN_2017_POSICAO			MONEY			NULL
		,NOV_2017_POSICAO			MONEY			NULL
		,DEZ_2017_POSICAO			MONEY			NULL
		,MAR_18_POSICAO				MONEY			NULL
		,JUN_18_POSICAO				MONEY			NULL

		,VALIDA_JUN_17				MONEY			NULL
		,VALIDA_NOV_17				MONEY			NULL
		,VALIDA_DEZ_17				MONEY			NULL
		,VALIDA_MAR_18				MONEY			NULL
		,VALIDA_JUN_18				MONEY			NULL
	)
			
	------------------------ INCLUÍNDO DADOS SISJUR JUNHO 2018 NA TABELA TEMPORÁRIA -----------------------------------				

	INSERT INTO ##VALIDA_TAB_POS_SISJUR VALUES
	('CÍVEL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) 
	INSERT INTO ##VALIDA_TAB_POS_SISJUR VALUES
	('JEC',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
	INSERT INTO ##VALIDA_TAB_POS_SISJUR VALUES
	('TRABALHISTA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
	INSERT INTO ##VALIDA_TAB_POS_SISJUR VALUES
	('ESTRATÉGICO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
	INSERT INTO ##VALIDA_TAB_POS_SISJUR VALUES
	('REGULATÓRIO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

	---------------------------------------------------------------------------------------------------------------------
	------------------------ INCLUÍNDO DADOS SISJUR DOS MESES DE JUNHO, NOV, DEZ, MAR E JUN 2018 NA TABELA TEMPORÁRIA ---				
	---------------------------------------------------------------------------------------------------------------------

	------------------------------------ANALISE JUN 17 ------------------------------------------------------------------
		UPDATE ##VALIDA_TAB_POS_SISJUR
		SET JUN_2017 = A.TOTAL
		FROM
			-----------CIVEL/TRAB
			(
				SELECT 'CÍVEL' AS TIPO, count([ID_SISJUR]) AS ID, sum([SALDO_SISJUR]) AS TOTAL 
				  FROM [OI_RSG].[dbo].[00_PROCESSOS_BTSA]
				  WHERE TIPO_PROCESSO = 'CÍVEL CONSUMIDOR'

				UNION
			
				SELECT 'JEC' AS TIPO, count([ID_SISJUR]) AS ID, sum([SALDO_SISJUR]) AS TOTAL 
				  FROM [OI_RSG].[dbo].[00_PROCESSOS_BTSA]
				  WHERE TIPO_PROCESSO = 'JUIZADO ESPECIAL'

				UNION
			
				SELECT 'TRABALHISTA' AS TIPO, count([ID_SISJUR]) AS ID, sum([SALDO_SISJUR]) AS TOTAL 
				  FROM [OI_RSG].[dbo].[00_PROCESSOS_BTSA]
				  WHERE TIPO_PROCESSO = 'TRABALHISTA'
			) A
			 
		WHERE A.TIPO = ##VALIDA_TAB_POS_SISJUR.TIPO
	

	------------------------------------ANALISE NOV 17 -----------------------------------------------------------------
		UPDATE ##VALIDA_TAB_POS_SISJUR
		SET NOV_2017 = B.TOTAL
		FROM
		------------CIVEL
			(SELECT 'CÍVEL' AS TIPO, count([G_ID_UNICO]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL
				FROM [OI_RSG_FASE_2].[dbo].[SISJUR_01_TI_MOVIMENTACOES_CIVEL_NOV17]
				WHERE DSC_TIPO_PROCESSO = 'Cível Consumidor'
	
			UNION

			SELECT 'JEC' AS TIPO, count([G_ID_UNICO]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL
				FROM [OI_RSG_FASE_2].[dbo].[SISJUR_01_TI_MOVIMENTACOES_CIVEL_NOV17]
				WHERE DSC_TIPO_PROCESSO = 'Juizado Especial'

			UNION

		------------TRABALHISTA
			SELECT distinct([DSC_TIPO_PROCESSO]) AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL
			  FROM [OI_RSG_FASE_2].[dbo].[SISJUR_06_TI_MOVIMENTACOES_TRAB_NOV17]
			  group by DSC_TIPO_PROCESSO) B
	
		WHERE B.TIPO = ##VALIDA_TAB_POS_SISJUR.TIPO
	

	-----------------------------------ANALISE DEZ 17 ---------------------------------------------------------------------
	
		UPDATE ##VALIDA_TAB_POS_SISJUR
		SET DEZ_2017 = C.TOTAL
		FROM

		------------ESTR/REG
		(SELECT 'ESTRATÉGICO' AS TIPO, count([ID_SISJUR]) AS ID, sum([G_VALOR_LANCAMENTO]) AS TOTAL
		  FROM [OI_RSG_FASE_2].[dbo].[ESTRATEGICA_04_CONSOLIDADO]
		  WHERE  ASSUNTO <> 'PADO'
	  
		  UNION

		  SELECT 'REGULATÓRIO' AS TIPO, count([ID_SISJUR]) AS ID, sum([G_VALOR_LANCAMENTO]) AS TOTAL
		  FROM [OI_RSG_FASE_2].[dbo].[ESTRATEGICA_04_CONSOLIDADO]
		  WHERE  ASSUNTO = 'PADO'	  ) C
	
		WHERE C.TIPO = ##VALIDA_TAB_POS_SISJUR.TIPO
	

	-----------------------------------ANALISE MARCO 18 --------------
	
		UPDATE ##VALIDA_TAB_POS_SISJUR
		SET MAR_18 = D.TOTAL
		FROM
			-----------CIVEL
			(SELECT 'CÍVEL' AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL  
				FROM [ON_GOING].[dbo].[SISJUR_TI_CIVEL_20180406]
				WHERE dsc_tipo_processo = 'Cível Consumidor'

			UNION

			SELECT 'JEC' AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL  
				FROM [ON_GOING].[dbo].[SISJUR_TI_CIVEL_20180406]
				WHERE dsc_tipo_processo = 'Juizado Especial'

			UNION
			------------TRABALHISTA
			SELECT distinct([DSC_TIPO_PROCESSO]) AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL    
			  FROM [ON_GOING].[dbo].[SISJUR_TI_TRABALHISTA_20180406]
			  group by dsc_tipo_processo

			UNION

			------------REG/ESTR
			SELECT distinct(NATUREZA) AS TIPO, count(G_id_SISJUR) AS ID, sum([Valor do Lançamento]) AS TOTAL
			  FROM [ON_GOING].[dbo].[SISJUR_ABRIL18_REGULATORIO_ESTRATEGICO]
			  group by natureza) D

		WHERE D.TIPO = ##VALIDA_TAB_POS_SISJUR.TIPO
	

	------------------------------------ANALISE JUNHO 18 --------------
	
		UPDATE ##VALIDA_TAB_POS_SISJUR
		SET JUN_18 = E.TOTAL
		FROM
			-------CIVEL
			(SELECT 'Juizado Especial' AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL
			  FROM [ON_GOING].[2_TRI].[SISJUR_CIVEL_CONSOLIDADA_JUN18]
			  WHERE dsc_tipo_processo = 'Juizado Especial'
	
			UNION
	
			SELECT 'Cível Consumidor' AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL
			  FROM [ON_GOING].[2_TRI].[SISJUR_CIVEL_CONSOLIDADA_JUN18]
			  WHERE dsc_tipo_processo = 'Cível Consumidor'
	
			UNION
		
			-------TRABALHISTA
			SELECT Distinct([DSC_TIPO_PROCESSO]) AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_PRINCIPAL_CORRIGIDO]) AS TOTAL
			  FROM [ON_GOING].[2_TRI].[SISJUR_TRABALHISTA_JUN18]
			  group by DSC_TIPO_PROCESSO

			UNION

			-------ESTRATEGICO
			SELECT 'ESTRATÉGICO' AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_LANCAMENTO_TRATADO]) AS TOTAL
			  FROM [ON_GOING].[2_TRI].[SISJUR_ESTRATEGICO_TRAT_JUN18]

			UNION

			-------REGULATORIO
			SELECT 'REGULATÓRIO' AS TIPO, count([G_ID_SISJUR]) AS ID, sum([G_VALOR_LANCAMENTO_TRATADO]) AS TOTAL
			  FROM [ON_GOING].[2_TRI].[SISJUR_REGULATORIO_TRAT_JUN18]) E

		WHERE E.TIPO = ##VALIDA_TAB_POS_SISJUR.TIPO

	----------------------------------------------------------------------------------------------------------
	------------------------------------INCLUINDO DADOS DA TABELA POSIÇÃO SISJUR PARA ANÁLISE ----------------
	----------------------------------------------------------------------------------------------------------

		UPDATE ##VALIDA_TAB_POS_SISJUR
		SET JUN_2017_POSICAO = F.TOTAL_JUN_17
		,NOV_2017_POSICAO = F.TOTAL_NOV_17
		,DEZ_2017_POSICAO = F.TOTAL_DEZ_17
		,MAR_18_POSICAO = F.TOTAL_MAR_18
		,JUN_18_POSICAO = F.TOTAL_JUN_18
	
		,VALIDA_JUN_17 = JUN_2017 - F.TOTAL_JUN_17
		,VALIDA_NOV_17 = NOV_2017 - F.TOTAL_NOV_17
		,VALIDA_DEZ_17 = DEZ_2017 - F.TOTAL_DEZ_17
		,VALIDA_MAR_18 = MAR_18 - F.TOTAL_MAR_18
		,VALIDA_JUN_18 = JUN_18 - F.TOTAL_JUN_18
	
		FROM
			(SELECT DISTINCT(G_TIPO_PROCESSO) AS TIPO, COUNT([ID_SISJUR]) AS ID, SUM(SALDO_JUN_17) AS TOTAL_JUN_17, SUM(SALDO_NOV_17) AS TOTAL_NOV_17, SUM(SALDO_DEZ_17) AS TOTAL_DEZ_17, SUM(SALDO_MAR_18) AS TOTAL_MAR_18, SUM(SALDO_JUN_18) AS TOTAL_JUN_18
			  FROM [ON_GOING].[2_TRI].[POSICOES_SISJUR]
			  GROUP BY G_TIPO_PROCESSO) F 
		WHERE F.TIPO = ##VALIDA_TAB_POS_SISJUR.TIPO


	SELECT * FROM ##VALIDA_TAB_POS_SISJUR


END

-- EXEC [dbo].[2TRI_SP_2.3_VALIDA_SISJUR_POSICOES]