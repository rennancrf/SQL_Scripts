USE [ON_GOING]
GO
/****** Object:  StoredProcedure [dbo].[2TRI_SP_2.3_VALIDA_SDBR_POSICOES]    Script Date: 30/10/2018 08:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rennan Correa
-- Create date: 20/08/2018
-- Description:	Procedure para validação das informações geradas na tabela de posições do SDBR após a execução
--				da procedure [2TRI_SP_2.1_SDBR_POSICOES].


-- =============================================
ALTER PROCEDURE [dbo].[2TRI_SP_2.3_VALIDA_SDBR_POSICOES] 

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
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VERIFICA SE TABELA TEMPORÁRIA DE VALIDAÇÃO SDBR JÁ EXISTE ~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SE SIM, A TABELA É DROPADA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
			
	PRINT '#############################################################################'  + CHAR(13)
	PRINT '############ INICIANDO PROCESSO DE VALIDAÇÃO DAS INFORMAÇÕES ################'  + CHAR(13)
	PRINT '####################### CRIANDO VALIDA ID SDBR POSICOES #####################'  + CHAR(13)
	PRINT '#############################################################################'  + CHAR(13)

	BEGIN TRY

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SDBR_JUN17')
			DROP TABLE ##VALIDA_ID_TAB_POS_SDBR_JUN17
		
		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SDBR_NOV17')
			DROP TABLE ##VALIDA_ID_TAB_POS_SDBR_NOV17

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SDBR_JAN18')
			DROP TABLE ##VALIDA_ID_TAB_POS_SDBR_JAN18

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SDBR_FEV18')
			DROP TABLE ##VALIDA_ID_TAB_POS_SDBR_FEV18
		
		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SDBR_MAR18')
			DROP TABLE ##VALIDA_ID_TAB_POS_SDBR_MAR18

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SDBR_JUN18')
			DROP TABLE ##VALIDA_ID_TAB_POS_SDBR_JUN18

		If Exists(Select * from Tempdb..SysObjects Where Name Like '##VALIDA_ID_TAB_POS_SDBR_JUL18')
			DROP TABLE ##VALIDA_ID_TAB_POS_SDBR_JUL18

		PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] TABELAS APAGADAS COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	END TRY
		
	BEGIN CATCH
	
			PRINT 'ATENÇÃO!!! FALHA AO APAGAR TABELAS TEMPORÁRIAS!!!'
			SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
			PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
	
	END CATCH

------------------------------------------------------------------------------------------------------------------------------
-------------------------------- CRIANDO TABELAS TEMPORÁRIAS PARA VERIFICAÇÃO DE CADA UM DOS MESES ---------------------------
------------------------------------------------------------------------------------------------------------------------------

IF @ERRO = 0
		BEGIN
			BEGIN TRY

				CREATE TABLE ##VALIDA_ID_TAB_POS_SDBR_JUN17
				(
					ID_SISJUR						BIGINT			NULL
					,SALDO_JUN_2017					MONEY			NULL
					,TIPO						VARCHAR(50)			NULL
					,SALDO_JUN_2017_POSICAO			MONEY			NULL

					,VALIDA_SALDO_JUN_17			MONEY			NULL
				)
			

				INSERT INTO ##VALIDA_ID_TAB_POS_SDBR_JUN17
					SELECT 
						G_ID_SISJUR_CONC
						,SUM(G_MONMI_TRAT)
						,G_TIPO_PROCESSO_GRUPO_NEW
						,NULL
						,NULL
					FROM OI_Analytics..[07_SDBR_TRAT]
					WHERE INDICADOR <> 7 AND G_ID_SISJUR_CONC IS NOT NULL AND G_TIPO_PROCESSO_GRUPO_NEW <> 'OUTROS'
					GROUP BY G_ID_SISJUR_CONC, G_TIPO_PROCESSO_GRUPO_NEW


				UPDATE ##VALIDA_ID_TAB_POS_SDBR_JUN17
					SET SALDO_JUN_2017_POSICAO = J.SALDO
						,VALIDA_SALDO_JUN_17 = J.SALDO - ##VALIDA_ID_TAB_POS_SDBR_JUN17.SALDO_JUN_2017
					FROM 
						(SELECT 								 
							F.ID_SISJUR 								--ID_SISJUR
							,SUM(F.SALDO_JUN)	AS SALDO			--SALDO_JUN_17
							,F.G_TIPO_PROCESSO AS TIPO
						FROM 
							ON_GOING.[2_TRI].POSICOES_SDBR F			
				
						INNER JOIN ##VALIDA_ID_TAB_POS_SDBR_JUN17 B
							ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO	AND F.ID_SISJUR IS NOT NULL												  			
			
						GROUP BY  
							F.ID_SISJUR
							,F.G_TIPO_PROCESSO) J

					WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SDBR_JUN17.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SDBR_JUN17.TIPO

					PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] INSERIDO BASE JUNHO 17 - TABELA VALIDA JUNHO 17 PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA ##VALIDA_ID_TAB_POS_SDBR_JUN17!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END



	---------------------------------------------------------------------------------------------------------------------------------

	IF @ERRO = 0
		BEGIN
			BEGIN TRY

				CREATE TABLE ##VALIDA_ID_TAB_POS_SDBR_NOV17
				(
					ID_SISJUR						BIGINT			NULL
					,SALDO_NOV_2017					MONEY			NULL
					,TIPO						VARCHAR(50)			NULL
					,SALDO_NOV_2017_POSICAO			MONEY			NULL

					,VALIDA_SALDO_NOV_17			MONEY			NULL
				)

				BEGIN
					WITH POSICAO_SDBR_NOV(ID_SISJUR,TOTAL,G_TIPO_PROCESSO) AS
					(
						SELECT 
							ID_SISJUR = 
								CASE
									WHEN ISNULL(CAST(G_ID_SISJUR_CONC_FASE_2  AS INT),0) = 0 THEN CAST(G_ID_SISJUR_CONC  AS INT)

									ELSE
										CAST(G_ID_SISJUR_CONC_FASE_2  AS INT)
								END
							,SUM(G_MONTMI) AS TOTAL
							--,COUNT(*)
							,G_TIPO_PROCESSO
			
					
						FROM OI_RSG_FASE_2..SDBR_01
						WHERE INDICADOR <> 7 AND (G_ID_SISJUR_CONC_FASE_2 IS NOT NULL OR G_ID_SISJUR_CONC IS NOT NULL)-- AND (G_ID_SISJUR_CONC_FASE_2 = 11373 OR G_ID_SISJUR_CONC = 11373)
						GROUP BY G_ID_SISJUR_CONC,G_ID_SISJUR_CONC_FASE_2,G_TIPO_PROCESSO
					)

					INSERT INTO ##VALIDA_ID_TAB_POS_SDBR_NOV17
						SELECT
							ID_SISJUR
							,SUM(TOTAL)
							,G_TIPO_PROCESSO
							,NULL
							,NULL
						FROM
							POSICAO_SDBR_NOV
						GROUP BY
							ID_SISJUR,
							G_TIPO_PROCESSO
				
					UPDATE ##VALIDA_ID_TAB_POS_SDBR_NOV17
						SET SALDO_NOV_2017_POSICAO = J.SALDO
							,VALIDA_SALDO_NOV_17 = J.SALDO - ##VALIDA_ID_TAB_POS_SDBR_NOV17.SALDO_NOV_2017
						FROM 
							(SELECT 								 
								F.ID_SISJUR 								
								,F.SALDO_NOV	AS SALDO			
								,F.G_TIPO_PROCESSO AS TIPO
							FROM 
								ON_GOING.[2_TRI].POSICOES_SDBR F			
				
							INNER JOIN ##VALIDA_ID_TAB_POS_SDBR_NOV17 B
								ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO	AND F.ID_SISJUR IS NOT NULL												  			
			
							GROUP BY  
								F.ID_SISJUR
								,F.G_TIPO_PROCESSO,SALDO_NOV) J

						WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SDBR_NOV17.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SDBR_NOV17.TIPO
				END

				PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] INSERIDO BASE NOVEMBRO 17 - TABELA VALIDA NOVEMBRO 17 PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA ##VALIDA_ID_TAB_POS_SDBR_NOV17!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END

	---------------------------------------------------------------------------------------------------------------------------------
	
	IF @ERRO = 0
		BEGIN
			BEGIN TRY

				CREATE TABLE ##VALIDA_ID_TAB_POS_SDBR_JAN18
				(
					ID_SISJUR						BIGINT			NULL
					,SALDO_JAN_2018					MONEY			NULL
					,TIPO						VARCHAR(50)			NULL
					,SALDO_JAN_2018_POSICAO			MONEY			NULL

					,VALIDA_SALDO_JAN_18			MONEY			NULL
				)

				BEGIN			

					WITH POSICAO_SDBR_JAN(ID_SISJUR,TOTAL,G_TIPO_PROCESSO) AS
					(
						SELECT 
							ID_SISJUR = 
								CASE
									WHEN ISNULL(CAST(G_ID_SISJUR_DELTA_FASE_2  AS INT),0) = 0 THEN CAST(G_ID_SISJUR_DELTA_FASE_1  AS INT)

									ELSE
										CAST(G_ID_SISJUR_DELTA_FASE_2  AS INT)
								END
							,SUM(G_MONTMI) AS TOTAL
							--,COUNT(*)
							,G_TIPO_PROCESSO_GRUPO
					
						FROM OI_RSG_FASE_2..SDBR_03_JANEIRO18
						WHERE INDICADOR <> 7 AND (G_ID_SISJUR_DELTA_FASE_2 IS NOT NULL OR G_ID_SISJUR_DELTA_FASE_1 IS NOT NULL)
						GROUP BY G_ID_SISJUR_DELTA_FASE_1, G_ID_SISJUR_DELTA_FASE_2, G_TIPO_PROCESSO_GRUPO
					)

					INSERT INTO ##VALIDA_ID_TAB_POS_SDBR_JAN18
						SELECT
							ID_SISJUR
							,SUM(TOTAL)
							,G_TIPO_PROCESSO
							,NULL
							,NULL
						FROM
							POSICAO_SDBR_JAN
						GROUP BY
							ID_SISJUR,
							G_TIPO_PROCESSO
				
					UPDATE ##VALIDA_ID_TAB_POS_SDBR_JAN18
						SET SALDO_JAN_2018_POSICAO = J.SALDO
							,VALIDA_SALDO_JAN_18 = J.SALDO - ##VALIDA_ID_TAB_POS_SDBR_JAN18.SALDO_JAN_2018
						FROM 
							(SELECT 								 
								F.ID_SISJUR 								
								,F.SALDO_JAN_18	AS SALDO			
								,F.G_TIPO_PROCESSO AS TIPO
							FROM 
								ON_GOING.[2_TRI].POSICOES_SDBR F			
				
							INNER JOIN ##VALIDA_ID_TAB_POS_SDBR_JAN18 B
								ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO	AND F.ID_SISJUR IS NOT NULL												  			
			
							GROUP BY  
								F.ID_SISJUR
								,F.G_TIPO_PROCESSO,SALDO_JAN_18) J

						WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SDBR_JAN18.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SDBR_JAN18.TIPO

				END

				PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] INSERIDO BASE JANEIRO 18 - TABELA VALIDA JANEIRO 18 PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA ##VALIDA_ID_TAB_POS_SDBR_JAN18!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END
	---------------------------------------------------------------------------------------------------------------------------------
	IF @ERRO = 0
		BEGIN
			BEGIN TRY

				CREATE TABLE ##VALIDA_ID_TAB_POS_SDBR_FEV18
				(
					ID_SISJUR						BIGINT			NULL
					,SALDO_FEV_2018					MONEY			NULL
					,TIPO						VARCHAR(50)			NULL
					,SALDO_FEV_2018_POSICAO			MONEY			NULL

					,VALIDA_SALDO_FEV_18			MONEY			NULL
				)

				BEGIN			

					WITH POSICAO_SDBR_FEV(ID_SISJUR,TOTAL,G_TIPO_PROCESSO) AS
					(
						SELECT 
							ID_SISJUR = 
								CASE
									WHEN ISNULL(CAST(G_ID_SISJUR_DELTA_FASE_2_NEW  AS INT),0) = 0 THEN CAST(G_ID_SISJUR_DELTA_FASE_1_NEW  AS INT)

									ELSE
										CAST(G_ID_SISJUR_DELTA_FASE_2_NEW  AS INT)
								END
							,SUM(B.G_MONTMI) AS TOTAL
							--,COUNT(*)
							,G_TIPO_PROCESSO_GRUPO
					
						FROM OI_RSG_FASE_2..SDBR_05_FEVEREIRO18 B
						WHERE INDICADOR <> 7 AND (G_ID_SISJUR_DELTA_FASE_2_NEW IS NOT NULL OR G_ID_SISJUR_DELTA_FASE_1_NEW IS NOT NULL)
						GROUP BY G_ID_SISJUR_DELTA_FASE_1_NEW, G_ID_SISJUR_DELTA_FASE_2_NEW, G_TIPO_PROCESSO_GRUPO
					)

					INSERT INTO ##VALIDA_ID_TAB_POS_SDBR_FEV18
						SELECT
							ID_SISJUR
							,SUM(TOTAL)
							,G_TIPO_PROCESSO
							,NULL
							,NULL
						FROM
							POSICAO_SDBR_FEV
						GROUP BY
							ID_SISJUR,
							G_TIPO_PROCESSO
				
					UPDATE ##VALIDA_ID_TAB_POS_SDBR_FEV18
						SET SALDO_FEV_2018_POSICAO = J.SALDO
							,VALIDA_SALDO_FEV_18 = J.SALDO - ##VALIDA_ID_TAB_POS_SDBR_FEV18.SALDO_FEV_2018
						FROM 
							(SELECT 								 
								F.ID_SISJUR 								
								,F.SALDO_FEV_18	AS SALDO			
								,F.G_TIPO_PROCESSO AS TIPO
							FROM 
								ON_GOING.[2_TRI].POSICOES_SDBR F			
				
							INNER JOIN ##VALIDA_ID_TAB_POS_SDBR_FEV18 B
								ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO	AND F.ID_SISJUR IS NOT NULL												  			
			
							GROUP BY  
								F.ID_SISJUR
								,F.G_TIPO_PROCESSO,SALDO_FEV_18) J

						WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SDBR_FEV18.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SDBR_FEV18.TIPO

				END

				PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] INSERIDO BASE FEVEREIRO 18 - TABELA VALIDA FEVEREIRO 18 PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA ##VALIDA_ID_TAB_POS_SDBR_FEV18!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END
	---------------------------------------------------------------------------------------------------------------------------------

	IF @ERRO = 0
			BEGIN
				BEGIN TRY
					CREATE TABLE ##VALIDA_ID_TAB_POS_SDBR_MAR18
					(
						ID_SISJUR						BIGINT			NULL
						,SALDO_MAR_2018					MONEY			NULL
						,TIPO						VARCHAR(50)			NULL
						,SALDO_MAR_2018_POSICAO			MONEY			NULL

						,VALIDA_SALDO_MAR_18			MONEY			NULL
					)

					INSERT INTO ##VALIDA_ID_TAB_POS_SDBR_MAR18
						SELECT
							G_ID_SISJUR_CONC_DELTA_CONSOLIDADO
							,SUM(B.G_montMI)
							--,COUNT(*)
							,G_TIPO_PROCESSO_GRUPO
							,NULL
							,NULL
						 
						FROM  ON_GOING.SDBR.SDBR_ABRIL18 B	
						WHERE indicador <> 7 AND G_FLAG_PODE_CONCILIAR = 'CONCILIAR' AND G_TIPO_PROCESSO_GRUPO <> 'OUTROS'
						GROUP BY 
							G_ID_SISJUR_CONC_DELTA_CONSOLIDADO, 
							G_TIPO_PROCESSO_GRUPO
				
					UPDATE ##VALIDA_ID_TAB_POS_SDBR_MAR18
						SET SALDO_MAR_2018_POSICAO = J.SALDO
							,VALIDA_SALDO_MAR_18 = J.SALDO - ##VALIDA_ID_TAB_POS_SDBR_MAR18.SALDO_MAR_2018
						FROM 
							(SELECT 								 
								F.ID_SISJUR 								
								,F.SALDO_MAR_18	AS SALDO			
								,F.G_TIPO_PROCESSO AS TIPO
							FROM 
								ON_GOING.[2_TRI].POSICOES_SDBR F			
				
							INNER JOIN ##VALIDA_ID_TAB_POS_SDBR_MAR18 B
								ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO	AND F.ID_SISJUR IS NOT NULL												  			
			
							GROUP BY  
								F.ID_SISJUR
								,F.G_TIPO_PROCESSO,SALDO_MAR_18) J

						WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SDBR_MAR18.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SDBR_MAR18.TIPO

						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] INSERIDO BASE MARÇO 18 - TABELA VALIDA MARÇO 18 PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)
			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA ##VALIDA_ID_TAB_POS_SDBR_MAR18!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END

	---------------------------------------------------------------------------------------------------------------------------------

	IF @ERRO = 0
		BEGIN
			BEGIN TRY

				CREATE TABLE ##VALIDA_ID_TAB_POS_SDBR_JUN18
				(
					ID_SISJUR						BIGINT			NULL
					,SALDO_JUN_2018					MONEY			NULL
					,TIPO						VARCHAR(50)			NULL
					,SALDO_JUN_2018_POSICAO			MONEY			NULL

					,VALIDA_SALDO_JUN_18			MONEY			NULL
				)

				INSERT INTO ##VALIDA_ID_TAB_POS_SDBR_JUN18
					SELECT
						G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI
						,SUM(G_montMI)
						--,COUNT(*)
						,G_TIPO_PROCESSO_GRUPO
						,NULL
						,NULL
					 				 
					FROM  ON_GOING.[2_TRI].SDBR_JUNHO_2018 	
					WHERE INDICADOR <> 7 AND G_FLAG_PODE_CONCILIAR = 'CONCILIAR' AND G_TIPO_PROCESSO_GRUPO <> 'OUTROS'
					GROUP BY 
						G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI, 
						G_TIPO_PROCESSO_GRUPO
				
				UPDATE ##VALIDA_ID_TAB_POS_SDBR_JUN18
					SET SALDO_JUN_2018_POSICAO = J.SALDO
						,VALIDA_SALDO_JUN_18 = J.SALDO - ##VALIDA_ID_TAB_POS_SDBR_JUN18.SALDO_JUN_2018
					FROM 
						(SELECT 								 
							F.ID_SISJUR 								
							,F.SALDO_JUN_18	AS SALDO			
							,F.G_TIPO_PROCESSO AS TIPO
						FROM 
							ON_GOING.[2_TRI].POSICOES_SDBR F			
				
						INNER JOIN ##VALIDA_ID_TAB_POS_SDBR_JUN18 B
							ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO	AND F.ID_SISJUR IS NOT NULL												  			
			
						GROUP BY  
							F.ID_SISJUR
							,F.G_TIPO_PROCESSO,SALDO_JUN_18) J

					WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SDBR_JUN18.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SDBR_JUN18.TIPO
		
					PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] INSERIDO BASE JUNHO 18 - TABELA VALIDA JUNHO 18 PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA ##VALIDA_ID_TAB_POS_SDBR_JUN18!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END

	---------------------------------------------------------------------------------------------------------------------------------

IF @ERRO = 0
		BEGIN
			BEGIN TRY

				CREATE TABLE ##VALIDA_ID_TAB_POS_SDBR_JUL18
				(
					ID_SISJUR						BIGINT			NULL
					,SALDO_JUL_2018					MONEY			NULL
					,TIPO						VARCHAR(50)			NULL
					,SALDO_JUL_2018_POSICAO			MONEY			NULL

					,VALIDA_SALDO_JUL_18			MONEY			NULL
				)

				INSERT INTO ##VALIDA_ID_TAB_POS_SDBR_JUL18
					SELECT
						G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI
						,SUM(G_montMI)
						--,COUNT(*)
						,G_TIPO_PROCESSO_GRUPO
						,NULL
						,NULL
					 				 
					FROM  ON_GOING.[2_TRI].SDBR_JULHO_2018 	
					WHERE INDICADOR <> 7 AND G_FLAG_PODE_CONCILIAR = 'CONCILIAR' AND G_TIPO_PROCESSO_GRUPO <> 'OUTROS' AND G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI IS NOT NULL
					GROUP BY 
						G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI, 
						G_TIPO_PROCESSO_GRUPO
				
				UPDATE ##VALIDA_ID_TAB_POS_SDBR_JUL18
					SET SALDO_JUL_2018_POSICAO = J.SALDO
						,VALIDA_SALDO_JUL_18 = J.SALDO - ##VALIDA_ID_TAB_POS_SDBR_JUL18.SALDO_JUL_2018
					FROM 
						(SELECT 								 
							F.ID_SISJUR 								
							,F.SALDO_JUL_18	AS SALDO			
							,F.G_TIPO_PROCESSO AS TIPO
						FROM 
							ON_GOING.[2_TRI].POSICOES_SDBR F			
				
						INNER JOIN ##VALIDA_ID_TAB_POS_SDBR_JUL18 B
							ON F.ID_SISJUR = B.ID_SISJUR AND F.G_TIPO_PROCESSO = B.TIPO	AND F.ID_SISJUR IS NOT NULL												  			
			
						GROUP BY  
							F.ID_SISJUR
							,F.G_TIPO_PROCESSO,SALDO_JUL_18) J

					WHERE J.ID_SISJUR = ##VALIDA_ID_TAB_POS_SDBR_JUL18.ID_SISJUR AND J.TIPO = ##VALIDA_ID_TAB_POS_SDBR_JUL18.TIPO
		
					PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] INSERIDO BASE JULHO 18 - TABELA VALIDA JULHO 18 PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA ##VALIDA_ID_TAB_POS_SDBR_JUL18!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END

	---------------------------------------------------------------------------------------------------------------------------------


		PRINT '----------------------------RESULTADO DA VERIFICAÇÃO ------------------------------------'
		IF (SELECT SUM(VALIDA_SALDO_JUN_17) FROM ##VALIDA_ID_TAB_POS_SDBR_JUN17 WHERE VALIDA_SALDO_JUN_17 IS NOT NULL) <> 0
			PRINT 'JUNHO 2017 COM ERRO!'
		ELSE
			PRINT 'JUNHO 2017 OK!'

		IF (SELECT SUM(VALIDA_SALDO_NOV_17) FROM ##VALIDA_ID_TAB_POS_SDBR_NOV17 WHERE VALIDA_SALDO_NOV_17 IS NOT NULL) <> 0
			PRINT 'NOVEMBRO 2017 COM ERRO!'
		ELSE
			PRINT 'NOVEMBRO 2017 OK!'

		IF (SELECT SUM(VALIDA_SALDO_JAN_18) FROM ##VALIDA_ID_TAB_POS_SDBR_JAN18 WHERE VALIDA_SALDO_JAN_18 IS NOT NULL) <> 0
			PRINT 'JANEIRO 2018 COM ERRO!'
		ELSE
			PRINT 'JANEIRO 2018 OK!'

		IF (SELECT SUM(VALIDA_SALDO_FEV_18) FROM ##VALIDA_ID_TAB_POS_SDBR_FEV18 WHERE VALIDA_SALDO_FEV_18 IS NOT NULL) <> 0
			PRINT 'FEVEREIRO 2018 COM ERRO!'
		ELSE
			PRINT 'FEVEREIRO 2018 OK!'

		IF (SELECT SUM(VALIDA_SALDO_MAR_18) FROM ##VALIDA_ID_TAB_POS_SDBR_MAR18 WHERE VALIDA_SALDO_MAR_18 IS NOT NULL) <> 0
			PRINT 'MARÇO 2018 COM ERRO!'
		ELSE
			PRINT 'MARÇO 2018 OK!'

		IF (SELECT SUM(VALIDA_SALDO_JUN_18) FROM ##VALIDA_ID_TAB_POS_SDBR_JUN18 WHERE VALIDA_SALDO_JUN_18 IS NOT NULL) <> 0
			PRINT 'JUNHO 2018 COM ERRO!'
		ELSE
			PRINT 'JUNHO 2018 OK!'

		IF (SELECT SUM(VALIDA_SALDO_JUL_18) FROM ##VALIDA_ID_TAB_POS_SDBR_JUL18 WHERE VALIDA_SALDO_JUL_18 IS NOT NULL) <> 0
			PRINT 'JULHO 2018 COM ERRO!'
		ELSE
			PRINT 'JULHO 2018 OK!'

		PRINT '-----------------------------------------------------------------------------------------'

END

-- EXEC [ON_GOING].[dbo].[2TRI_SP_1.3_VALIDA_SDBR_POSICOES]
