USE [ON_GOING]
GO
/****** Object:  StoredProcedure [dbo].[2TRI_SP_2.1_CRIA_SDBR_POSICOES]    Script Date: 30/10/2018 08:55:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rennan Correa
-- Create date: 24/08/2018
-- Description:	Gera uma tabela contendo todos os saldos por data base do SDBR.


-- =============================================
ALTER PROCEDURE [dbo].[2TRI_SP_2.1_CRIA_SDBR_POSICOES] 

AS
BEGIN

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DECLARAÇÃO DAS VARIAVEIS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DECLARE @ERRO INT
SET @ERRO = 0
DECLARE @DESCRICAO_ERRO VARCHAR(500)
SET @DESCRICAO_ERRO = NULL
DECLARE @INSERT VARCHAR(8000) 
SET @INSERT = NULL

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ VERIFICA SE TABELA DE SISJUR SUMARIZADA JÁ EXISTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SE SIM, A TABELA É DROPADA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	PRINT '#############################################################################'  + CHAR(13)
	PRINT '############ INICIANDO PROCESSO DE COMPARAÇÃO PARA O ONGOING ################'  + CHAR(13)
	PRINT '############################## CRIANDO SDBR POSICOES ########################'  + CHAR(13)
	PRINT '#############################################################################'  + CHAR(13)



	BEGIN TRY

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ON_GOING].[2_TRI].[POSICOES_SDBR]') AND type in (N'U'))
			DROP TABLE [ON_GOING].[2_TRI].[POSICOES_SDBR]
	
		PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [1] TABELA APAGADA COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	END TRY
	BEGIN CATCH

		PRINT 'ATENÇÃO!!! FALHA AO APAGAR A TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
		SET @ERRO = 1
		SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
		PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)

	END CATCH

	--------------------------------------------------------------------------------------------------------------
	--------------------------- CRIA TABELA COM AS POSIÇOES DOS SALDOS POR ID_SISJUR -----------------------------
	--------------------------------------------------------------------------------------------------------------

	IF @ERRO = 0	
		BEGIN
			BEGIN TRY

				CREATE TABLE [ON_GOING].[2_TRI].[POSICOES_SDBR] 
				(
					 ID_SISJUR					BIGINT		 NULL
					,G_TIPO_PROCESSO			VARCHAR(100) NULL
					,SALDO_MAIS_ATUAL			MONEY		 NULL
					,QTD_MAIS_ATUAL				INT			 NULL
					,SALDO_JUN					MONEY		 NULL
					,QTD_JUN					INT			 NULL
					,SALDO_NOV					MONEY		 NULL
					,QTD_NOV					INT			 NULL
					,SALDO_JAN_18				MONEY		 NULL
					,QTD_JAN_18					INT			 NULL
					,SALDO_FEV_18				MONEY		 NULL
					,QTD_FEV_18					INT			 NULL
					,SALDO_MAR_18				MONEY		 NULL
					,QTD_MAR_18					INT			 NULL
					,SALDO_JUN_18				MONEY		 NULL
					,QTD_JUN_18					INT			 NULL
					,SALDO_JUL_18				MONEY		 NULL
					,QTD_JUL_18					INT			 NULL
				
				)

				PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [2] TABELA CRIADA COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
	
				PRINT 'ATENÇÃO!!! FALHA AO CRIAR A TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
	
			END CATCH
		END


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES ------------------------------------------
	---------------------------------------------------------------------------------------------------------

	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_JUL_18')
				DROP TABLE ##SDBR_JUL_18
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (JULHO 2018) ------------------------
				CREATE TABLE ##SDBR_JUL_18
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR						MONEY			NULL
					,QTD_JUL_18					INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR JULHO 2018 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_JUL_18										
					 SELECT
						 G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI
						 ,SUM(G_montMI)
						 ,COUNT(*)
						,G_TIPO_PROCESSO_GRUPO
					 				 
					 FROM  ON_GOING.[2_TRI].SDBR_JULHO_2018 	
					 WHERE INDICADOR <> 7 
					   AND G_FLAG_PODE_CONCILIAR = 'CONCILIAR' 
					   AND G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI IS NOT NULL 
					   AND G_TIPO_PROCESSO_GRUPO <> 'BLOQUEIO' 
					   AND G_TIPO_PROCESSO_GRUPO <> 'OUTROS'
					 GROUP BY G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI, G_TIPO_PROCESSO_GRUPO
			

	----------------------------------------------------------------------------------------------------------------			
	-------------------- INSERINDO PROCESSOS DA CONCILIAÇÃO (base JULHO 2018) --------------------------------------
	----------------------------------------------------------------------------------------------------------------

				INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
					SELECT	
						A.ID_SISJUR											--ID_SISJUR
						,A.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
						,A.VALOR AS SALDO_JUL_18							--SALDO_MAIS_ATUAL
						,A.QTD_JUL_18										--QTD_MAIS_ATUAL
						,NULL												--SALDO_JUN_17
						,NULL												--QTD_JUN_17
						,NULL												--SALDO_NOV_17
						,NULL												--QTD_NOV_17
						,NULL					--,NULL		 AS SALDO_JAN	--SALDO_JAN_17
						,NULL					--,NULL		 AS QTD_JAN		--QTD_JAN_17
						,NULL												--SALDO_FEV_18
						,NULL												--QTD_FEV_18
						,NULL					--,D.VALOR					--SALDO_MAR_18
						,NULL					--,D.QTD	  				--QTD_MAR_18						
						,NULL												--SALDO_JUN_18
						,NULL								  				--QTD_JUN_18																										
						,A.VALOR AS SALDO_JUL_18							--SALDO_JUN_18
						,A.QTD_JUL_18						  				--QTD_JUN_18																								

					FROM  ##SDBR_JUL_18 A 
					--WHERE A.ID_SISJUR NOT IN (SELECT DISTINCT(B.ID_SISJUR) FROM ON_GOING.[2_TRI].POSICOES_SISJUR B)
					
				PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [1] INSERIDO BASE JULHO 18 - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO PREENCHER A TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES ------------------------------------------
	---------------------------------------------------------------------------------------------------------


	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_JUN_18')
				DROP TABLE ##SDBR_JUN_18
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (JUNHO 2018) ------------------------
				CREATE TABLE ##SDBR_JUN_18
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR						MONEY			NULL
					,QTD_JUN_18					INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR JUNHO 2018 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_JUN_18										
					 SELECT
						 G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI
						 ,SUM(G_montMI)
						 ,COUNT(*)
						,G_TIPO_PROCESSO_GRUPO
					 				 
					 FROM  ON_GOING.[2_TRI].SDBR_JUNHO_2018 	
					 WHERE INDICADOR <> 7 AND G_FLAG_PODE_CONCILIAR = 'CONCILIAR' 
					   AND G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI IS NOT NULL 
					   AND G_TIPO_PROCESSO_GRUPO <> 'BLOQUEIO' 
					   AND G_TIPO_PROCESSO_GRUPO <> 'OUTROS'
					 GROUP BY G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI, G_TIPO_PROCESSO_GRUPO
			
	---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE JUNHO RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ON_GOING.[2_TRI].POSICOES_SDBR 
							SET SALDO_JUN_18 = J.SALDO,
								QTD_JUN_18 = J.QTD
							
							FROM 
								(SELECT 								 
									C.ID_SISJUR 						--ID_SISJUR
									,SUM(C.VALOR)	AS SALDO			--SALDO_JUN_18
									,COUNT(*) 		AS QTD				--QTD_JUN_18			
									,C.G_TIPO_PROCESSO AS TIPO
								FROM 
									##SDBR_JUN_18 C			
				
								INNER JOIN ON_GOING.[2_TRI].POSICOES_SDBR B
									ON C.ID_SISJUR = B.ID_SISJUR AND C.G_TIPO_PROCESSO = B.G_TIPO_PROCESSO													  			
			
								GROUP BY  
									 C.ID_SISJUR
									,C.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ON_GOING.[2_TRI].POSICOES_SDBR.ID_SISJUR 
							  AND J.TIPO = ON_GOING.[2_TRI].POSICOES_SDBR.G_TIPO_PROCESSO
		
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [2] VALORES ATUALIZADOS REFERENTE A BASE JUNHO 18 NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	---------------------- INCLUINDO IDs DE JUNHO QUE NÃO ESTÃO RELACIONADOS AOS IDS DE JULHO -----------------------------------------
			
						INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
							SELECT	
								D.ID_SISJUR											--ID_SISJUR
								,D.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
								,NULL												--SALDO_MAIS_ATUAL
								,NULL												--QTD_MAIS_ATUAL
								,NULL												--SALDO_JUN_17
								,NULL												--QTD_JUN_17
								,NULL												--SALDO_NOV_17
								,NULL												--QTD_NOV_17
								,NULL					--,NULL		 AS SALDO_JAN	--SALDO_JAN_17
								,NULL					--,NULL		 AS QTD_JAN		--QTD_JAN_17
								,NULL												--SALDO_FEV_18
								,NULL												--QTD_FEV_18
								,NULL												--SALDO_MAR_18
								,NULL								  				--QTD_MAR_18
								,D.VALOR AS SALDO_JUN_18							--SALDO_JUN_18
								,D.QTD_JUN_18						  				--QTD_JUN_18						
								,NULL												--SALDO_JUL_18
								,NULL								  				--QTD_JUL_18																										

							FROM  
							##SDBR_JUN_18 D 
							WHERE CONCAT(D.ID_SISJUR,D.G_TIPO_PROCESSO) NOT IN (SELECT DISTINCT(CONCAT(B.ID_SISJUR,B.G_TIPO_PROCESSO)) FROM ON_GOING.[2_TRI].POSICOES_SDBR B)
					
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [3] INSERIDO IDs DA BASE JUNHO 18 - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)


			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO INSERIR OS PROCESSOS NOVOS NA TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END
	


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES ------------------------------------------
	---------------------------------------------------------------------------------------------------------


	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_MAR_18')
				DROP TABLE ##SDBR_MAR_18
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (MARÇO 2018) ------------------------
				CREATE TABLE ##SDBR_MAR_18
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR						MONEY			NULL
					,QTD_MAR_18					INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR MARÇO 2018 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_MAR_18										
					SELECT
							 G_ID_SISJUR_CONC_DELTA_CONSOLIDADO
							 ,SUM(B.G_montMI)
							 ,COUNT(*)
							 ,G_TIPO_PROCESSO_GRUPO
						 
						 FROM  ON_GOING.SDBR.SDBR_ABRIL18 B	
						 WHERE indicador <> 7 
						   AND G_FLAG_PODE_CONCILIAR = 'CONCILIAR' 
						   AND G_ID_SISJUR_CONC_DELTA_CONSOLIDADO IS NOT NULL 
						   AND G_TIPO_PROCESSO_GRUPO <> 'BLOQUEIO' 
						   AND G_TIPO_PROCESSO_GRUPO <> 'OUTROS'
						 GROUP BY G_ID_SISJUR_CONC_DELTA_CONSOLIDADO, G_TIPO_PROCESSO_GRUPO

	---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE MARÇO RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ON_GOING.[2_TRI].POSICOES_SDBR 
							SET SALDO_MAR_18 = J.SALDO,
								QTD_MAR_18 = J.QTD
							
							FROM 
								(SELECT 								 
									C.ID_SISJUR 						--ID_SISJUR
									,SUM(C.VALOR)	AS SALDO			--SALDO_MAR_18
									,COUNT(*) 		AS QTD				--QTD_MAR_18			
									,C.G_TIPO_PROCESSO AS TIPO
								FROM 
									##SDBR_MAR_18 C			
				
								INNER JOIN ON_GOING.[2_TRI].POSICOES_SDBR B
									ON C.ID_SISJUR = B.ID_SISJUR AND C.G_TIPO_PROCESSO = B.G_TIPO_PROCESSO													  			
			
								GROUP BY  
									 C.ID_SISJUR
									,C.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ON_GOING.[2_TRI].POSICOES_SDBR.ID_SISJUR 
							  AND J.TIPO = ON_GOING.[2_TRI].POSICOES_SDBR.G_TIPO_PROCESSO
		
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [4] VALORES ATUALIZADOS REFERENTE A BASE MARÇO 18 NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	---------------------- INCLUINDO IDs DE MARÇO QUE NÃO ESTÃO RELACIONADOS AOS IDS DE JULHO -----------------------------------------
			
						INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
							SELECT	
								D.ID_SISJUR											--ID_SISJUR
								,D.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
								,NULL												--SALDO_MAIS_ATUAL
								,NULL												--QTD_MAIS_ATUAL
								,NULL												--SALDO_JUN_17
								,NULL												--QTD_JUN_17
								,NULL												--SALDO_NOV_17
								,NULL												--QTD_NOV_17
								,NULL					--,NULL		 AS SALDO_JAN	--SALDO_JAN_17
								,NULL					--,NULL		 AS QTD_JAN		--QTD_JAN_17
								,NULL												--SALDO_FEV_18
								,NULL												--QTD_FEV_18
								,D.VALOR AS SALDO_MAR_18							--SALDO_MAR_18
								,D.QTD_MAR_18						  				--QTD_MAR_18						
								,NULL												--SALDO_JUN_18
								,NULL								  				--QTD_JUN_18																										
								,NULL												--SALDO_JUL_18
								,NULL								  				--QTD_JUL_18
								
							FROM  
							##SDBR_MAR_18 D 
							WHERE CONCAT(D.ID_SISJUR,D.G_TIPO_PROCESSO) NOT IN (SELECT DISTINCT(CONCAT(B.ID_SISJUR,B.G_TIPO_PROCESSO)) FROM ON_GOING.[2_TRI].POSICOES_SDBR B)
					
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [5] INSERIDO IDs DA BASE MARÇO 18 - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)


			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO INSERIR OS PROCESSOS NOVOS NA TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES ------------------------------------------
	---------------------------------------------------------------------------------------------------------


	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_FEV_18')
				DROP TABLE ##SDBR_FEV_18
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (FEV 2018) ------------------------
				CREATE TABLE ##SDBR_FEV_18
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR						MONEY			NULL
					,QTD_FEV_18					INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR FEV 2018 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_FEV_18										
					SELECT 
						ID_SISJUR = 
							CASE
								WHEN ISNULL(CAST(G_ID_SISJUR_DELTA_FASE_2_NEW  AS INT),0) = 0 THEN CAST(G_ID_SISJUR_DELTA_FASE_1_NEW  AS INT)

								ELSE
									CAST(G_ID_SISJUR_DELTA_FASE_2_NEW  AS INT)
							END
						,SUM(B.G_MONTMI)
						,COUNT(*)
						,G_TIPO_PROCESSO_GRUPO
					
					FROM OI_RSG_FASE_2..SDBR_05_FEVEREIRO18 B
					WHERE INDICADOR <> 7 AND (G_ID_SISJUR_DELTA_FASE_2_NEW IS NOT NULL 
					   OR G_ID_SISJUR_DELTA_FASE_1_NEW IS NOT NULL)
					GROUP BY G_ID_SISJUR_DELTA_FASE_1_NEW, G_ID_SISJUR_DELTA_FASE_2_NEW, G_TIPO_PROCESSO_GRUPO

	---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE FEV RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ON_GOING.[2_TRI].POSICOES_SDBR 
							SET SALDO_FEV_18 = J.SALDO,
								QTD_FEV_18 = J.QTD
						
							FROM 
								(SELECT 								 
									C.ID_SISJUR 						--ID_SISJUR
									,SUM(C.VALOR)	AS SALDO			--SALDO_FEV_18
									,COUNT(*) 		AS QTD				--QTD_FEV_18			
									,C.G_TIPO_PROCESSO AS TIPO
								FROM 
									##SDBR_FEV_18 C			
				
								INNER JOIN ON_GOING.[2_TRI].POSICOES_SDBR B
									ON C.ID_SISJUR = B.ID_SISJUR AND C.G_TIPO_PROCESSO = B.G_TIPO_PROCESSO													  			
			
								GROUP BY  
									 C.ID_SISJUR
									,C.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ON_GOING.[2_TRI].POSICOES_SDBR.ID_SISJUR 
							  AND J.TIPO = ON_GOING.[2_TRI].POSICOES_SDBR.G_TIPO_PROCESSO
		
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [6] VALORES ATUALIZADOS REFERENTE A BASE FEVEREIRO 18 NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	---------------------- INCLUINDO IDs DE FEVEREIRO QUE NÃO ESTÃO RELACIONADOS AOS IDS DE JULHO -----------------------------------------
			
						INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
							SELECT	
								E.ID_SISJUR											--ID_SISJUR
								,E.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
								,NULL												--SALDO_MAIS_ATUAL
								,NULL												--QTD_MAIS_ATUAL
								,NULL												--SALDO_JUN_17
								,NULL												--QTD_JUN_17
								,NULL												--SALDO_NOV_17
								,NULL												--QTD_NOV_17
								,NULL					--,NULL		 AS SALDO_JAN	--SALDO_JAN_17
								,NULL					--,NULL		 AS QTD_JAN		--QTD_JAN_17
								,E.VALOR AS SALDO_FEV_18							--SALDO_FEV_18
								,E.QTD_FEV_18										--QTD_FEV_18
								,NULL												--SALDO_MAR_18
								,NULL								  				--QTD_MAR_18						
								,NULL												--SALDO_JUN_18
								,NULL								  				--QTD_JUN_18						
								,NULL												--SALDO_JUL_18
								,NULL								  				--QTD_JUL_18																										

							FROM  
							##SDBR_FEV_18 E 
							WHERE CONCAT(E.ID_SISJUR,E.G_TIPO_PROCESSO) NOT IN (SELECT DISTINCT(CONCAT(B.ID_SISJUR,B.G_TIPO_PROCESSO)) FROM ON_GOING.[2_TRI].POSICOES_SDBR B)
					
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [7] INSERIDO IDs DA BASE FEVEREIRO 18 - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)


			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO INSERIR OS PROCESSOS NOVOS NA TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES ------------------------------------------
	---------------------------------------------------------------------------------------------------------


	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_JAN_18')
				DROP TABLE ##SDBR_JAN_18
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (JAN 2018) ------------------------
				CREATE TABLE ##SDBR_JAN_18
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR						MONEY			NULL
					,QTD_JAN_18					INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR JAN 2018 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_JAN_18										
					 SELECT 
						ID_SISJUR = 
							CASE
								WHEN ISNULL(CAST(G_ID_SISJUR_DELTA_FASE_2  AS INT),0) = 0 THEN CAST(G_ID_SISJUR_DELTA_FASE_1  AS INT)

								ELSE
									CAST(G_ID_SISJUR_DELTA_FASE_2  AS INT)
							END
						,SUM(G_MONTMI)
						,COUNT(*)
						,G_TIPO_PROCESSO_GRUPO
					
					FROM OI_RSG_FASE_2..SDBR_03_JANEIRO18
					WHERE INDICADOR <> 7 
					  AND (G_ID_SISJUR_DELTA_FASE_2 IS NOT NULL OR G_ID_SISJUR_DELTA_FASE_1 IS NOT NULL)
					GROUP BY G_ID_SISJUR_DELTA_FASE_1, G_ID_SISJUR_DELTA_FASE_2, G_TIPO_PROCESSO_GRUPO
			

	---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE JAN RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ON_GOING.[2_TRI].POSICOES_SDBR 
							SET SALDO_JAN_18 = J.SALDO,
								QTD_JAN_18 = J.QTD
						
							FROM 
								(SELECT 								 
									C.ID_SISJUR 						--ID_SISJUR
									,SUM(C.VALOR)	AS SALDO			--SALDO_JAN_18
									,COUNT(*) 		AS QTD				--QTD_JAN_18			
									,C.G_TIPO_PROCESSO AS TIPO
								FROM 
									##SDBR_JAN_18 C			
				
								INNER JOIN ON_GOING.[2_TRI].POSICOES_SDBR B
									ON C.ID_SISJUR = B.ID_SISJUR AND C.G_TIPO_PROCESSO = B.G_TIPO_PROCESSO													  			
			
								GROUP BY  
									 C.ID_SISJUR
									,C.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ON_GOING.[2_TRI].POSICOES_SDBR.ID_SISJUR 
							  AND J.TIPO = ON_GOING.[2_TRI].POSICOES_SDBR.G_TIPO_PROCESSO
		
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [8] VALORES ATUALIZADOS REFERENTE A BASE JANEIRO 18 NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	---------------------- INCLUINDO IDs DE JANEIRO QUE NÃO ESTÃO RELACIONADOS AOS IDS DE JULHO -----------------------------------------
			
						INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
							SELECT	
								E.ID_SISJUR											--ID_SISJUR
								,E.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
								,NULL												--SALDO_MAIS_ATUAL
								,NULL												--QTD_MAIS_ATUAL
								,NULL												--SALDO_JUN_17
								,NULL												--QTD_JUN_17
								,NULL												--SALDO_NOV_17
								,NULL												--QTD_NOV_17
								,E.VALOR AS SALDO_JAN_18							--SALDO_JAN_18
								,E.QTD_JAN_18										--QTD_JAN_18
								,NULL												--SALDO_FEV_18
								,NULL												--QTD_FEV_18
								,NULL												--SALDO_MAR_18
								,NULL								  				--QTD_MAR_18						
								,NULL												--SALDO_JUN_18
								,NULL								  				--QTD_JUN_18						
								,NULL												--SALDO_JUL_18
								,NULL								  				--QTD_JUL_18																										

							FROM  
							##SDBR_JAN_18 E 
							WHERE CONCAT(E.ID_SISJUR,E.G_TIPO_PROCESSO) NOT IN (SELECT DISTINCT(CONCAT(B.ID_SISJUR,B.G_TIPO_PROCESSO)) FROM ON_GOING.[2_TRI].POSICOES_SDBR B)
					
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [9] INSERIDO IDs DA BASE JANEIRO 18 - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)


			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO INSERIR OS PROCESSOS NOVOS NA TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES ------------------------------------------
	---------------------------------------------------------------------------------------------------------


	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_NOV_17')
				DROP TABLE ##SDBR_NOV_17
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (NOV 2017) ------------------------
				CREATE TABLE ##SDBR_NOV_17
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR						MONEY			NULL
					,QTD_NOV_17					INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR NOV 2017 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_NOV_17										
					 SELECT 
						ID_SISJUR = 
							CASE
								WHEN ISNULL(CAST(G_ID_SISJUR_CONC_FASE_2  AS INT),0) = 0 THEN CAST(G_ID_SISJUR_CONC  AS INT)

								ELSE
									CAST(G_ID_SISJUR_CONC_FASE_2  AS INT)
							END
						,SUM(G_MONTMI)
						,COUNT(*)
						,G_TIPO_PROCESSO
					
					FROM OI_RSG_FASE_2..SDBR_01
					WHERE INDICADOR <> 7 
					  AND (G_ID_SISJUR_CONC_FASE_2 IS NOT NULL 
					   OR G_ID_SISJUR_CONC IS NOT NULL)
					GROUP BY G_ID_SISJUR_CONC,G_ID_SISJUR_CONC_FASE_2,G_TIPO_PROCESSO

	---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE NOV RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ON_GOING.[2_TRI].POSICOES_SDBR 
							SET SALDO_NOV = J.SALDO,
								QTD_NOV = J.QTD
						
							FROM 
								(SELECT 								 
									C.ID_SISJUR 						--ID_SISJUR
									,SUM(C.VALOR)	AS SALDO			--SALDO_NOV_17
									,COUNT(*) 		AS QTD				--QTD_NOV_17			
									,C.G_TIPO_PROCESSO AS TIPO
								FROM 
									##SDBR_NOV_17 C			
				
								INNER JOIN ON_GOING.[2_TRI].POSICOES_SDBR B
									ON C.ID_SISJUR = B.ID_SISJUR AND C.G_TIPO_PROCESSO = B.G_TIPO_PROCESSO													  			
			
								GROUP BY  
									 C.ID_SISJUR
									,C.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ON_GOING.[2_TRI].POSICOES_SDBR.ID_SISJUR 
							  AND J.TIPO = ON_GOING.[2_TRI].POSICOES_SDBR.G_TIPO_PROCESSO
		
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [10] VALORES ATUALIZADOS REFERENTE A BASE NOVEMBRO 17 NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	---------------------- INCLUINDO IDs DE NOVEMBRO QUE NÃO ESTÃO RELACIONADOS AOS IDS DE JULHO -----------------------------------------
			
						INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
							SELECT	
								E.ID_SISJUR											--ID_SISJUR
								,E.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
								,NULL												--SALDO_MAIS_ATUAL
								,NULL												--QTD_MAIS_ATUAL
								,NULL												--SALDO_JUN_17
								,NULL												--QTD_JUN_17
								,E.VALOR AS SALDO_NOV_17							--SALDO_NOV_17
								,E.QTD_NOV_17										--QTD_NOV_17
								,NULL												--SALDO_JAN_18
								,NULL												--QTD_JAN_18
								,NULL												--SALDO_FEV_18
								,NULL												--QTD_FEV_18
								,NULL												--SALDO_MAR_18
								,NULL								  				--QTD_MAR_18						
								,NULL												--SALDO_JUN_18
								,NULL								  				--QTD_JUN_18						
								,NULL												--SALDO_JUL_18
								,NULL								  				--QTD_JUL_18																										

							FROM  
							##SDBR_NOV_17 E 
							WHERE CONCAT(E.ID_SISJUR,E.G_TIPO_PROCESSO) NOT IN (SELECT DISTINCT(CONCAT(B.ID_SISJUR,B.G_TIPO_PROCESSO)) FROM ON_GOING.[2_TRI].POSICOES_SDBR B)
					
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [11] INSERIDO IDs DA BASE NOVEMBRO 17 - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)


			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO INSERIR OS PROCESSOS NOVOS NA TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES ------------------------------------------
	---------------------------------------------------------------------------------------------------------


	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_JUN_17')
				DROP TABLE ##SDBR_JUN_17
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (JUN 2017) ------------------------
				CREATE TABLE ##SDBR_JUN_17
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR						MONEY			NULL
					,QTD_JUN_17					INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR JUN 2017 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_JUN_17										
					 SELECT 
						G_ID_SISJUR_CONC
						,SUM(G_MONMI_TRAT)
						,COUNT(*)
						,G_TIPO_PROCESSO_GRUPO_NEW
					
					FROM OI_Analytics..[07_SDBR_TRAT]
					WHERE INDICADOR <> 7 
					  AND G_ID_SISJUR_CONC IS NOT NULL 
					  AND G_TIPO_PROCESSO_GRUPO_NEW <> 'OUTROS'
					GROUP BY G_ID_SISJUR_CONC,G_TIPO_PROCESSO_GRUPO_NEW

	---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE JUN RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ON_GOING.[2_TRI].POSICOES_SDBR 
							SET SALDO_JUN = J.SALDO,
								QTD_JUN = J.QTD
						
							FROM 
								(SELECT 								 
									C.ID_SISJUR 						--ID_SISJUR
									,SUM(C.VALOR)	AS SALDO			--SALDO_NOV_17
									,COUNT(*) 		AS QTD				--QTD_NOV_17			
									,C.G_TIPO_PROCESSO AS TIPO
								FROM 
									##SDBR_JUN_17 C			
				
								INNER JOIN ON_GOING.[2_TRI].POSICOES_SDBR B
									ON C.ID_SISJUR = B.ID_SISJUR AND C.G_TIPO_PROCESSO = B.G_TIPO_PROCESSO													  			
			
								GROUP BY  
									 C.ID_SISJUR
									,C.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ON_GOING.[2_TRI].POSICOES_SDBR.ID_SISJUR AND J.TIPO = ON_GOING.[2_TRI].POSICOES_SDBR.G_TIPO_PROCESSO
		
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [12] VALORES ATUALIZADOS REFERENTE A BASE JUNHO 17 NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	---------------------- INCLUINDO IDs DE JUNHO 2017 QUE NÃO ESTÃO RELACIONADOS AOS IDS DE JULHO -----------------------------------------
			
						INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
							SELECT	
								E.ID_SISJUR											--ID_SISJUR
								,E.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
								,NULL												--SALDO_MAIS_ATUAL
								,NULL												--QTD_MAIS_ATUAL
								,E.VALOR AS SALDO_JUN_17							--SALDO_JUN_17
								,E.QTD_JUN_17										--QTD_JUN_17
								,NULL												--SALDO_NOV_17
								,NULL												--QTD_NOV_17
								,NULL												--SALDO_JAN_18
								,NULL												--QTD_JAN_18
								,NULL												--SALDO_FEV_18
								,NULL												--QTD_FEV_18
								,NULL												--SALDO_MAR_18
								,NULL								  				--QTD_MAR_18						
								,NULL												--SALDO_JUN_18
								,NULL								  				--QTD_JUN_18						
								,NULL												--SALDO_JUL_18
								,NULL								  				--QTD_JUL_18																										

							FROM  
							##SDBR_JUN_17 E 
							WHERE CONCAT(E.ID_SISJUR,E.G_TIPO_PROCESSO) NOT IN (SELECT DISTINCT(CONCAT(B.ID_SISJUR,B.G_TIPO_PROCESSO)) FROM ON_GOING.[2_TRI].POSICOES_SDBR B)
					
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [13] INSERIDO IDs DA BASE JUNHO 17 - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)


			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO INSERIR OS PROCESSOS NOVOS NA TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END


	---------------------------------------------------------------------------------------------------------
	--------------------------- PREENCHE A TABELA COM AS POSIÇÕES DE NATUREZA BLOQUEIO ----------------------
	---------------------------------------------------------------------------------------------------------


	IF @ERRO = 0
		BEGIN
			BEGIN TRY


				If Exists(Select * from Tempdb..SysObjects Where Name Like '##SDBR_BLOQUEIO_MAR_JUL_18')
				DROP TABLE ##SDBR_BLOQUEIO_MAR_JUL_18
		
	------------------------ CRIANDO TABELA TEMPORÁRIA PARA ARMAZENAR DADOS SDBR (MARÇO 2018) ------------------------
				CREATE TABLE ##SDBR_BLOQUEIO_MAR_JUL_18
				(
					ID_SISJUR					BIGINT			NULL
					,VALOR_MAR					MONEY			NULL
					,QTD_BLOQ_MAR_18			INT				NULL
					,VALOR_JUL					MONEY			NULL
					,QTD_BLOQ_JUL_18			INT				NULL
					,G_TIPO_PROCESSO			VARCHAR(500)	NULL
				)
			
	------------------------ INCLUÍNDO DADOS SDBR BLOQUEIO JULHO 2018 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_BLOQUEIO_MAR_JUL_18										
					SELECT
						A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI 
						,NULL
						,NULL
						,SUM(A.G_MONTMI) AS VALOR_JUL
						,COUNT(*)
						,TIPO = CASE ISNULL(B.G_TIPO_PROCESSO,'VAZIO')
									WHEN 'VAZIO' THEN 'BLOQUEIO'
									ELSE
										B.G_TIPO_PROCESSO
								END
					FROM ON_GOING.[2_TRI].SDBR_JULHO_2018 A
						LEFT JOIN ON_GOING.[2_TRI].POSICOES_SISJUR B
							ON A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI = B.ID_SISJUR
					WHERE G_FLAG_PODE_CONCILIAR = 'CONCILIAR' 
					  AND A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI IS NOT NULL 
					  and A.G_TIPO_PROCESSO_GRUPO = 'BLOQUEIO'
					GROUP BY  A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO_2TRI, B.G_TIPO_PROCESSO
/*
	---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE BLOQUEIO DE JULHO RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ##SDBR_BLOQUEIO_MAR_JUL_18 
							SET VALOR_MAR = J.VALOR_MAR,
								QTD_BLOQ_MAR_18 = J.QDT_MAR_18
							
							FROM 
								(SELECT
									A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO AS ID_SISJUR
									,SUM(A.G_MONTMI)	AS VALOR_MAR
									,COUNT(*)			AS QDT_MAR_18
									,TIPO = CASE ISNULL(B.G_TIPO_PROCESSO,'VAZIO')
												WHEN 'VAZIO' THEN 'BLOQUEIO'
												ELSE
													B.G_TIPO_PROCESSO
											END

								FROM ON_GOING.SDBR.SDBR_ABRIL18 A
									LEFT JOIN ON_GOING.[2_TRI].POSICOES_SISJUR B
										ON A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO = B.ID_SISJUR
								WHERE G_FLAG_PODE_CONCILIAR = 'CONCILIAR' 
								  AND A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO IS NOT NULL 
								  and A.G_TIPO_PROCESSO_GRUPO = 'BLOQUEIO'
								GROUP BY  A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO, B.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ##SDBR_BLOQUEIO_MAR_JUL_18.ID_SISJUR AND J.TIPO = ##SDBR_BLOQUEIO_MAR_JUL_18.G_TIPO_PROCESSO
		
						--PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [14] VALORES ATUALIZADOS REFERENTE A BASE MARÇO 18 NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	------------------------ INCLUÍNDO DADOS SDBR BLOQUEIO MARÇO 2018 NA TABELA TEMPORÁRIA -----------------------------------				

				INSERT INTO ##SDBR_BLOQUEIO_MAR_JUL_18										
					SELECT A.ID_SISJUR
						  ,A.VALOR_MAR
						  ,A.QDT_MAR_18
						  ,NULL
						  ,NULL
						  ,A.TIPO
					FROM 
						(SELECT
							A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO AS ID_SISJUR
							,SUM(A.G_MONTMI)	AS VALOR_MAR
							,COUNT(*)			AS QDT_MAR_18
							,TIPO = CASE ISNULL(B.G_TIPO_PROCESSO,'VAZIO')
										WHEN 'VAZIO' THEN 'BLOQUEIO'
										ELSE
											B.G_TIPO_PROCESSO
									END

						FROM ON_GOING.SDBR.SDBR_ABRIL18 A
							LEFT JOIN ON_GOING.[2_TRI].POSICOES_SISJUR B
								ON A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO = B.ID_SISJUR
						WHERE G_FLAG_PODE_CONCILIAR = 'CONCILIAR' 
						  AND A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO IS NOT NULL 
						  and A.G_TIPO_PROCESSO_GRUPO = 'BLOQUEIO'
						GROUP BY  A.G_ID_SISJUR_CONC_DELTA_CONSOLIDADO, B.G_TIPO_PROCESSO) A
					
					LEFT JOIN ##SDBR_BLOQUEIO_MAR_JUL_18 B
						ON A.ID_SISJUR = B.ID_SISJUR AND A.TIPO = B.G_TIPO_PROCESSO
					
					WHERE CONCAT(A.ID_SISJUR,A.TIPO) NOT IN (SELECT DISTINCT(CONCAT(C.ID_SISJUR,C.G_TIPO_PROCESSO)) FROM ##SDBR_BLOQUEIO_MAR_JUL_18 C)
				
				
				PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [14] INSERIDO IDs DE BLOQUEIO MARÇO/JULHO 18 NA TABELA TEMPORÁRIA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

*/
---------------------- INCLUINDO INFORMAÇÕES REFERENTES AOS VALORES DE BLOQUEIO RELACIONADOS AOS IDS DE JULHO ------------------------
						
						UPDATE ON_GOING.[2_TRI].POSICOES_SDBR 
							SET --SALDO_MAR_18 = SALDO_MAR_18 + J.VALOR_MAR_BLOQ,
								--QTD_MAR_18 = QTD_MAR_18 + J.QTD_BLOQ_MAR_18,
								SALDO_JUL_18 = SALDO_JUL_18 + J.VALOR_JUL_BLOQ,
								QTD_JUL_18 = QTD_JUL_18 + J.QTD_BLOQ_JUL_18,
								SALDO_MAIS_ATUAL = SALDO_MAIS_ATUAL + ISNULL(J.VALOR_JUL_BLOQ,0) --CASE ISNULL(J.VALOR_JUL_BLOQ,0)
																									--WHEN 0 THEN J.VALOR_MAR_BLOQ
																									--ELSE
																									--	J.VALOR_JUL_BLOQ
																								  --END
							FROM 
								(SELECT 								 
									C.ID_SISJUR 			--ID_SISJUR
									--,SUM(C.VALOR_MAR)		AS VALOR_MAR_BLOQ
									--,SUM(QTD_BLOQ_MAR_18) 	AS QTD_BLOQ_MAR_18			
									,SUM(C.VALOR_JUL)		AS VALOR_JUL_BLOQ
									,SUM(QTD_BLOQ_JUL_18) 	AS QTD_BLOQ_JUL_18			
									,C.G_TIPO_PROCESSO		AS TIPO_BLOQ
								FROM 
									##SDBR_BLOQUEIO_MAR_JUL_18 C			
				
								INNER JOIN ON_GOING.[2_TRI].POSICOES_SDBR B
									ON C.ID_SISJUR = B.ID_SISJUR AND C.G_TIPO_PROCESSO = B.G_TIPO_PROCESSO													  			
			
								GROUP BY  
									 C.ID_SISJUR
									,C.G_TIPO_PROCESSO) J

							WHERE J.ID_SISJUR = ON_GOING.[2_TRI].POSICOES_SDBR.ID_SISJUR 
							  AND J.TIPO_BLOQ = ON_GOING.[2_TRI].POSICOES_SDBR.G_TIPO_PROCESSO
		
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [15] VALORES DE BLOQUEIO REFERENTE A MARÇO/JULHO 18 ATUALIZADOS NA TABELA POSIÇÕES COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	---------------------- INCLUINDO IDs DE BLOQUEIO QUE NÃO ESTÃO RELACIONADOS AOS IDS DE JULHO -----------------------------------------
			
						INSERT INTO [ON_GOING].[2_TRI].[POSICOES_SDBR]
							SELECT	
								D.ID_SISJUR											--ID_SISJUR
								,D.G_TIPO_PROCESSO									--G_TIPO_PROCESSO
								,D.VALOR_JUL --CASE ISNULL(D.VALOR_JUL,0)
												--WHEN 0 THEN D.VALOR_MAR
												--ELSE
												--	D.VALOR_JUL
											 --END									--SALDO_MAIS_ATUAL
								,NULL												--QTD_MAIS_ATUAL
								,NULL												--SALDO_JUN_17
								,NULL												--QTD_JUN_17
								,NULL												--SALDO_NOV_17
								,NULL												--QTD_NOV_17
								,NULL												--SALDO_JAN_17
								,NULL												--QTD_JAN_17
								,NULL												--SALDO_FEV_18
								,NULL												--QTD_FEV_18
								,NULL --D.VALOR_MAR AS SALDO_MAR_18					--SALDO_MAR_18
								,NULL --D.QTD_BLOQ_MAR_18					  		--QTD_MAR_18						
								,NULL												--SALDO_JUN_18
								,NULL								  				--QTD_JUN_18																										
								,D.VALOR_JUL AS SALDO_JUL_18						--SALDO_JUL_18
								,D.QTD_BLOQ_JUL_18					  				--QTD_JUL_18						
								
							FROM  
							##SDBR_BLOQUEIO_MAR_JUL_18 D 
							WHERE CONCAT(D.ID_SISJUR,D.G_TIPO_PROCESSO) NOT IN (SELECT DISTINCT(CONCAT(B.ID_SISJUR,B.G_TIPO_PROCESSO)) FROM ON_GOING.[2_TRI].POSICOES_SDBR B)
					
						PRINT UPPER(replace(replace(system_user,'.',' '),'OI\ ',''))+', [16] INSERIDO IDs BLOQUEIO MARÇO/JULHO 18 RESTANTES - TABELA DE POSIÇÕES PREENCHIDA COM SUCESSO! '+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)


			END TRY

			BEGIN CATCH
		
				PRINT 'ATENÇÃO!!! FALHA AO INSERIR OS PROCESSOS NOVOS NA TABELA [ON_GOING].[2_TRI].[POSICOES_SDBR]!!!'
				SET @ERRO = 1
				SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
				PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
			END CATCH
		END

END


-- EXEC [dbo].[2TRI_SP_2.1_CRIA_SDBR_POSICOES]