USE [ON_GOING]
GO
/****** Object:  StoredProcedure [dbo].[2TRI_SP_1.4_VALIDA_ID_SISJUR_POSICOES]    Script Date: 30/10/2018 08:55:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rennan Correa
-- Create date: 16/08/2018
-- Description:	Procedure para validação das informações de ID_SISJUR geradas na tabela de posições do SISJUR após a execução
--				da procedure [2TRI_SP_2.1_SISJUR_POSICOES] .


-- =============================================
ALTER PROCEDURE [dbo].[2TRI_SP_1.4_VALIDA_ID_SISJUR_POSICOES]

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
	PRINT '####################### CRIANDO VALIDA ID SISJUR POSICOES ###################'  + CHAR(13)
	PRINT '#############################################################################'  + CHAR(13)

	BEGIN TRY

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SISJUR_JUN17')
			DROP TABLE ##VALIDA_ID_TAB_POS_SISJUR_JUN17
		
		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SISJUR_NOV17')
			DROP TABLE ##VALIDA_ID_TAB_POS_SISJUR_NOV17

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SISJUR_DEZ17')
			DROP TABLE ##VALIDA_ID_TAB_POS_SISJUR_DEZ17

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SISJUR_MAR18')
			DROP TABLE ##VALIDA_ID_TAB_POS_SISJUR_MAR18
		
		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SISJUR_JUN18')
			DROP TABLE ##VALIDA_ID_TAB_POS_SISJUR_JUN18


		PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] TABELAS APAGADAS COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	END TRY
		
	BEGIN CATCH
	
			PRINT 'ATENÇÃO!!! FALHA AO APAGAR TABELAS TEMPORÁRIAS!!!'
			SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
			PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
	
	END CATCH


	CREATE TABLE ##VALIDA_ID_TAB_POS_SISJUR_JUN17
	(
		ID_SISJUR						BIGINT			NULL
		,SALDO_JUN_2017					MONEY			NULL
		,TIPO						VARCHAR(50)			NULL
		,SALDO_JUN_2017_POSICAO			MONEY			NULL

		,VALIDA_SALDO_JUN_17			MONEY			NULL
	)
			

	---------------------------------------------------------------------------------------------------------------------
	------------------------ INCLUÍNDO DADOS SISJUR DOS MÊS DE JUNHO 2017 NA TABELA TEMPORÁRIA ---				
	---------------------------------------------------------------------------------------------------------------------

		INSERT INTO ##VALIDA_ID_TAB_POS_SISJUR_JUN17
			-----------CIVEL/TRAB
			SELECT 
				[OI_RSG].[dbo].[00_PROCESSOS_BTSA].ID_SISJUR AS ID
				,SUM([SALDO_SISJUR])
				,CASE TIPO_PROCESSO
					WHEN 'Juizado Especial' THEN'JEC'
					WHEN 'Cível Consumidor' THEN 'CÍVEL'
					WHEN 'TRABALHISTA' THEN 'TRABALHISTA'
				 END 
				,NULL
				,NULL
				FROM [OI_RSG].[dbo].[00_PROCESSOS_BTSA]
				
				LEFT JOIN [ON_GOING].[2_TRI].[POSICOES_SISJUR] A 
					ON [OI_RSG].[dbo].[00_PROCESSOS_BTSA].ID_SISJUR = A.ID_SISJUR AND TIPO_PROCESSO = A.G_TIPO_PROCESSO

				GROUP BY 
					[OI_RSG].[dbo].[00_PROCESSOS_BTSA].[ID_SISJUR], 
					TIPO_PROCESSO,
					A.SALDO_JUN_17,
					A.ID_SISJUR


	----------------------------------------------------------------------------------------------------------------
	-------------------------CRIANDO TABELA TEMPORÁRIA PARA VALIDAÇÃO DOS ID_SISJUR DA TABELA POSIÇÃO --------------
	----------------------------------------------------------------------------------------------------------------

	CREATE TABLE ##VALIDA_ID_TAB_POS_SISJUR_NOV17
	(
		ID_SISJUR						BIGINT			NULL
		,SALDO_NOV_2017					MONEY			NULL
		,TIPO						VARCHAR(50)			NULL
		,SALDO_NOV_2017_POSICAO			MONEY			NULL

		,VALIDA_SALDO_NOV_17			MONEY			NULL
	)
			

	---------------------------------------------------------------------------------------------------------------------
	------------------------ INCLUÍNDO DADOS SISJUR DOS MESES DE NOV NA TABELA TEMPORÁRIA -------------------------------				
	---------------------------------------------------------------------------------------------------------------------

		INSERT INTO ##VALIDA_ID_TAB_POS_SISJUR_NOV17
			SELECT 
				G_ID_SISJUR,	
				SUM(G_VALOR_PRINCIPAL_CORRIGIDO)
				,CASE DSC_TIPO_PROCESSO
					WHEN 'Juizado Especial' THEN'JEC'
					WHEN 'Cível Consumidor' THEN 'CÍVEL'
					END
				,NULL
				,NULL
											
			FROM 
				OI_RSG_FASE_2..SISJUR_01_TI_MOVIMENTACOES_CIVEL_NOV17		
			GROUP BY 
				G_ID_SISJUR,					
				DSC_TIPO_PROCESSO
			UNION

				SELECT 
					G_ID_SISJUR 
					,SUM(G_VALOR_PRINCIPAL_CORRIGIDO)
					,'TRABALHISTA' AS DSC_TIPO_PROCESSO								
					,NULL
					,NULL
			
				FROM 
					OI_RSG_FASE_2..SISJUR_06_TI_MOVIMENTACOES_TRAB_NOV17		
				GROUP BY 
					G_ID_SISJUR,
					DSC_TIPO_PROCESSO

	---------------------------------------------------------------------------------

			UPDATE ##VALIDA_ID_TAB_POS_SISJUR_NOV17
				SET SALDO_NOV_2017_POSICAO = J.SALDO
					,VALIDA_SALDO_NOV_17 = J.SALDO - SALDO_NOV_2017
				FROM 
					(SELECT 								 
						F.ID_SISJUR 						--ID_SISJUR
						,SUM(F.SALDO_NOV_17)	AS SALDO			--SALDO_NOV_17
						,F.G_TIPO_PROCESSO AS TIPO
					FROM 
						ON_GOING.[2_TRI].POSICOES_SISJUR F			
				
					INNER JOIN ##VALIDA_ID_TAB_POS_SISJUR_NOV17 B
						ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO													  			
			
					GROUP BY  
						F.ID_SISJUR
						,F.G_TIPO_PROCESSO) J

				WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SISJUR_NOV17.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SISJUR_NOV17.TIPO
		

	----------------------------------------------------------------------------------------------------------------------------
	-------------------------CRIANDO TABELA TEMPORÁRIA PARA VALIDAÇÃO DOS ID_SISJUR DE DEZ 2017 DA TABELA POSIÇÃO --------------
	----------------------------------------------------------------------------------------------------------------------------

	CREATE TABLE ##VALIDA_ID_TAB_POS_SISJUR_DEZ17
	(
		ID_SISJUR						BIGINT			NULL
		,SALDO_DEZ_2017					MONEY			NULL
		,TIPO						VARCHAR(50)			NULL
		,SALDO_DEZ_2017_POSICAO			MONEY			NULL

		,VALIDA_SALDO_DEZ_17			MONEY			NULL
	)
			

	---------------------------------------------------------------------------------------------------------------------
	------------------------ INCLUÍNDO DADOS SISJUR DOS MÊS DE DEZ NA TABELA TEMPORÁRIA ---------------------------------				
	---------------------------------------------------------------------------------------------------------------------

		INSERT INTO ##VALIDA_ID_TAB_POS_SISJUR_DEZ17
			SELECT								 
				CAST(ID_SISJUR  AS INT)
				,SUM(G_VALOR_LANCAMENTO)
				,CASE WHEN ASSUNTO = 'PADO' THEN 'REGULATÓRIO' ELSE 'ESTRATÉGICO' END AS G_TIPO_PROCESSO
				,NULL
				,NULL	
			FROM 
				OI_RSG_FASE_2.[dbo].[ESTRATEGICA_04_CONSOLIDADO]	
			
			GROUP BY 
				ID_SISJUR,
				ASSUNTO

	---------------------------------------------------------------------------------

			UPDATE ##VALIDA_ID_TAB_POS_SISJUR_DEZ17
				SET SALDO_DEZ_2017_POSICAO = J.SALDO
					,VALIDA_SALDO_DEZ_17 = J.SALDO - SALDO_DEZ_2017
				FROM 
					(SELECT 								 
						F.ID_SISJUR 						--ID_SISJUR
						,SUM(F.SALDO_DEZ_17)	AS SALDO			--SALDO_DEZ_17
						,F.G_TIPO_PROCESSO AS TIPO
					FROM 
						ON_GOING.[2_TRI].POSICOES_SISJUR F			
				
					INNER JOIN ##VALIDA_ID_TAB_POS_SISJUR_DEZ17 B
						ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO													  			
			
					GROUP BY  
						F.ID_SISJUR
						,F.G_TIPO_PROCESSO) J

				WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SISJUR_DEZ17.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SISJUR_DEZ17.TIPO


	----------------------------------------------------------------------------------------------------------------------------
	-------------------------CRIANDO TABELA TEMPORÁRIA PARA VALIDAÇÃO DOS ID_SISJUR DE MAR 2018 DA TABELA POSIÇÃO --------------
	----------------------------------------------------------------------------------------------------------------------------

	CREATE TABLE ##VALIDA_ID_TAB_POS_SISJUR_MAR18
	(
		ID_SISJUR						BIGINT			NULL
		,SALDO_MAR_2018					MONEY			NULL
		,TIPO						VARCHAR(50)			NULL
		,SALDO_MAR_2018_POSICAO			MONEY			NULL

		,VALIDA_SALDO_MAR_18			MONEY			NULL
	)
			

	---------------------------------------------------------------------------------------------------------------------
	------------------------ INCLUÍNDO DADOS SISJUR DOS MÊS DE MARÇO NA TABELA TEMPORÁRIA -------------------------------				
	---------------------------------------------------------------------------------------------------------------------

		INSERT INTO ##VALIDA_ID_TAB_POS_SISJUR_MAR18
			SELECT								 
				CAST(G_ID_SISJUR  AS INT)
				,SUM(G_VALOR_PRINCIPAL_CORRIGIDO)
				,CASE DSC_TIPO_PROCESSO
					WHEN 'Juizado Especial' THEN'JEC'
					WHEN 'Cível Consumidor' THEN 'CÍVEL'
					END
				,NULL
				,NULL
				
			FROM 
				ON_GOING..SISJUR_TI_CIVEL_20180406	
			GROUP BY 
				G_ID_SISJUR
				,DSC_TIPO_PROCESSO

			UNION

				SELECT 					 
					CAST(G_ID_SISJUR  AS INT)
					,SUM(G_VALOR_PRINCIPAL_CORRIGIDO)
					,'TRABALHISTA' AS DSC_TIPO_PROCESSO
					,NULL
					,NULL

				FROM 
					ON_GOING..SISJUR_TI_TRABALHISTA_20180406							
				GROUP BY 
					G_ID_SISJUR
					,DSC_TIPO_PROCESSO

				UNION

					SELECT 					 
						CAST(G_ID_SISJUR  AS INT)
						,SUM([Valor do Lançamento])
						,NATUREZA
						,NULL
						,NULL

					FROM 
						ON_GOING..SISJUR_ABRIL18_REGULATORIO_ESTRATEGICO							
					GROUP BY 
						G_ID_SISJUR
						,NATUREZA

	---------------------------------------------------------------------------------

			UPDATE ##VALIDA_ID_TAB_POS_SISJUR_MAR18
				SET SALDO_MAR_2018_POSICAO = J.SALDO
					,VALIDA_SALDO_MAR_18 = J.SALDO - SALDO_MAR_2018
				FROM 
					(SELECT 								 
						F.ID_SISJUR 						--ID_SISJUR
						,SUM(F.SALDO_MAR_18)	AS SALDO			--SALDO_MAR_18
						,F.G_TIPO_PROCESSO AS TIPO
					FROM 
						ON_GOING.[2_TRI].POSICOES_SISJUR F			
				
					INNER JOIN ##VALIDA_ID_TAB_POS_SISJUR_MAR18 B
						ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO													  			
			
					GROUP BY  
						F.ID_SISJUR
						,F.G_TIPO_PROCESSO) J

				WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SISJUR_MAR18.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SISJUR_MAR18.TIPO


	----------------------------------------------------------------------------------------------------------------------------
	-------------------------CRIANDO TABELA TEMPORÁRIA PARA VALIDAÇÃO DOS ID_SISJUR DE JUN 2018 DA TABELA POSIÇÃO --------------
	----------------------------------------------------------------------------------------------------------------------------

	CREATE TABLE ##VALIDA_ID_TAB_POS_SISJUR_JUN18
	(
		ID_SISJUR						BIGINT			NULL
		,SALDO_JUN_2018					MONEY			NULL
		,TIPO						VARCHAR(50)			NULL
		,SALDO_JUN_2018_POSICAO			MONEY			NULL

		,VALIDA_SALDO_JUN_18			MONEY			NULL
	)
			

	---------------------------------------------------------------------------------------------------------------------
	------------------------ INCLUÍNDO DADOS SISJUR DOS MÊS DE MARÇO NA TABELA TEMPORÁRIA -------------------------------				
	---------------------------------------------------------------------------------------------------------------------

		INSERT INTO ##VALIDA_ID_TAB_POS_SISJUR_JUN18
			SELECT								 
				CAST(G_ID_SISJUR  AS INT)
				,SUM(G_VALOR_LANCAMENTO_TRATADO)
				,'ESTRATÉGICO' AS G_TIPO_PROCESSO
				,NULL
				,NULL	
			FROM 
				ON_GOING.[2_TRI].[SISJUR_ESTRATEGICO_TRAT_JUN18]	
			
			GROUP BY 
				G_ID_SISJUR
																													
			UNION

				SELECT								 
					CAST(G_ID_SISJUR  AS INT)
					,SUM(G_VALOR_LANCAMENTO_TRATADO)
					,'REGULATÓRIO' AS G_TIPO_PROCESSO
					,NULL
					,NULL
				FROM 
					ON_GOING.[2_TRI].[SISJUR_REGULATORIO_TRAT_JUN18]	
			
				GROUP BY 
					G_ID_SISJUR
	
				UNION
					
					SELECT								 
						CAST(G_ID_SISJUR  AS INT)
						,SUM(G_VALOR_PRINCIPAL_CORRIGIDO)
						,'TRABALHISTA' AS G_TIPO_PROCESSO
						,NULL
						,NULL
					FROM 
						ON_GOING.[2_TRI].[SISJUR_TRABALHISTA_JUN18]	
			
					GROUP BY 
						G_ID_SISJUR									
																							
					UNION
	
						SELECT								 
							CAST(G_ID_SISJUR  AS INT)
							,SUM(G_VALOR_PRINCIPAL_CORRIGIDO)
							,CASE DSC_TIPO_PROCESSO
								WHEN 'Juizado Especial' THEN'JEC'
								WHEN 'Cível Consumidor' THEN 'CÍVEL'
								END
							,NULL
							,NULL
						FROM 
							ON_GOING.[2_TRI].[SISJUR_CIVEL_CONSOLIDADA_JUN18]	
			
						GROUP BY 
							G_ID_SISJUR, DSC_TIPO_PROCESSO						
	---------------------------------------------------------------------------------

			UPDATE ##VALIDA_ID_TAB_POS_SISJUR_JUN18
				SET SALDO_JUN_2018_POSICAO = J.SALDO
					,VALIDA_SALDO_JUN_18 = J.SALDO - SALDO_JUN_2018
				FROM 
					(SELECT 								 
						F.ID_SISJUR 						--ID_SISJUR
						,SUM(F.SALDO_JUN_18)	AS SALDO			--SALDO_JUN_18
						,F.G_TIPO_PROCESSO AS TIPO
					FROM 
						ON_GOING.[2_TRI].POSICOES_SISJUR F			
				
					INNER JOIN ##VALIDA_ID_TAB_POS_SISJUR_JUN18 B
						ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO													  			
			
					GROUP BY  
						F.ID_SISJUR
						,F.G_TIPO_PROCESSO) J

				WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SISJUR_JUN18.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SISJUR_JUN18.TIPO


	---------------------------------------------------------------------------------------------------------------------------------


		PRINT '----------------------------RESULTADO DA VERIFICAÇÃO ------------------------------------'
		IF (SELECT SUM(VALIDA_SALDO_JUN_17) FROM ##VALIDA_ID_TAB_POS_SISJUR_JUN17 WHERE VALIDA_SALDO_JUN_17 IS NOT NULL) <> 0
			PRINT 'JUNHO 2017 COM ERRO!'
		ELSE
			PRINT 'JUNHO 2017 OK!'

		IF (SELECT SUM(VALIDA_SALDO_NOV_17) FROM ##VALIDA_ID_TAB_POS_SISJUR_NOV17 WHERE VALIDA_SALDO_NOV_17 IS NOT NULL) <> 0
			PRINT 'NOVEMBRO 2017 COM ERRO!'
		ELSE
			PRINT 'NOVEMBRO 2017 OK!'

		IF (SELECT SUM(VALIDA_SALDO_DEZ_17) FROM ##VALIDA_ID_TAB_POS_SISJUR_DEZ17 WHERE VALIDA_SALDO_DEZ_17 IS NOT NULL) <> 0
			PRINT 'DEZEMBRO 2017 COM ERRO!'
		ELSE
			PRINT 'DEZEMBRO 2017 OK!'

		IF (SELECT SUM(VALIDA_SALDO_MAR_18) FROM ##VALIDA_ID_TAB_POS_SISJUR_MAR18 WHERE VALIDA_SALDO_MAR_18 IS NOT NULL) <> 0
			PRINT 'MARÇO 2018 COM ERRO!'
		ELSE
			PRINT 'MARÇO 2018 OK!'

		IF (SELECT SUM(VALIDA_SALDO_JUN_18) FROM ##VALIDA_ID_TAB_POS_SISJUR_JUN18 WHERE VALIDA_SALDO_JUN_18 IS NOT NULL) <> 0
			PRINT 'JUNHO 2018 COM ERRO!'
		ELSE
			PRINT 'JUNHO 2018 OK!'

		PRINT '-----------------------------------------------------------------------------------------'

END

-- EXEC [dbo].[2TRI_SP_2.4_VALIDA_ID_SISJUR_POSICOES]