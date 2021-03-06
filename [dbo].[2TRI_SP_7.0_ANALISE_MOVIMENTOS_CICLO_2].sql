USE [ON_GOING]
GO
/****** Object:  StoredProcedure [dbo].[2TRI_SP_7.0_ANALISE_MOVIMENTOS_CICLO_2]    Script Date: 30/10/2018 08:56:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rennan Correa
-- Create date: 28/09/2018
-- Description:	Realiza análise de movimentos ocorridos entre o 1tri e 2tri no sdbr para lançamentos classificados como Novas Movimentações e Movimentação = Ajuste 
-- =============================================

ALTER PROCEDURE [dbo].[2TRI_SP_7.0_ANALISE_MOVIMENTOS_CICLO_2] 
	
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
DECLARE @VER_CAMPO INT





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ LIMPA A TABELA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	PRINT '#############################################################################'  + CHAR(13)
	PRINT '###################### ANALISE MOVIMENTAÇÃO CICLO 2 #########################'  + CHAR(13)
	PRINT '#############################################################################'  + CHAR(13)


	BEGIN TRY

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2]') AND type in (N'U'))
			DROP TABLE [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2]

		PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] TABELA ANALISE APAGADA COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	END TRY
	
	BEGIN CATCH
		
		PRINT 'ATENÇÃO!!! FALHA AO APAGAR A TABELA [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2]!!!'
		SET @ERRO = 1
		SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
		PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
	
	END CATCH

	BEGIN TRY

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2_CONSOLIDADO]') AND type in (N'U'))
			DROP TABLE [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2_CONSOLIDADO]
				
		PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [2] TABELA CONSOLIDADO APAGADA COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

	END TRY
	
	BEGIN CATCH
		
		PRINT 'ATENÇÃO!!! FALHA AO APAGAR A TABELA [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2_CONSOLIDADO]!!!'
		SET @ERRO = 1
		SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
		PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
	
	END CATCH


IF @ERRO = 0
	BEGIN
		BEGIN TRY

---------------------------------------------------------------------------------------------------------
--------------------------- TABELA COM OS MOVIMENTOS DOS SALDOS POR ID_SISJUR -----------------------------
---------------------------------------------------------------------------------------------------------


			WITH
				MOVIMENTO_COMPARA_SDBR (ID_SISJUR,G_TIPO_PROCESSO,TIPO_PROCESSO,SALDO_1_TRI,SALDO_2_TRI,MOVIMENTO,STATUS_MOVIMENTACAO) AS 
				(
						SELECT 
							  A.[ID_SISJUR]
							  ,A.[G_TIPO_PROCESSO]
							  ,B.[TIPO_PROCESSO]
							  ,ISNULL(B.SALDO_RECENTE_1_TRI,0) AS SALDO_1_TRI
							  ,ISNULL(B.SALDO_RECENTE_2_TRI,0) AS SALDO_2_TRI
							  ,ISNULL(B.SALDO_RECENTE_2_TRI,0) - ISNULL(B.SALDO_RECENTE_1_TRI,0) AS MOVIMENTO_2_TRI
							  --,B.VALOR_BAIXA_MC AS BAIXA_1_TRI
							  --,B.VALOR_EXPECTATIVA_MC AS EXPECTATIVA_1_TRI
							  ,[STATUS_MOVIMENTACAO]
						  FROM [ON_GOING].[2_TRI].[00_MATRIZ_COMPARACAO] A
						  LEFT JOIN [ON_GOING].[2_TRI].[01_COMPARA_SDBR] B
							ON A.ID_SISJUR = B.ID_SISJUR AND A.G_TIPO_PROCESSO = B.TIPO_PROCESSO
						WHERE 	((DETALHE_MOVIMENTACAO LIKE '%1TRI%' OR DETALHE_MOVIMENTACAO IS NULL OR DETALHE_MOVIMENTACAO LIKE '%NOVOS%')) 
								AND (STATUS_MOVIMENTACAO = 'MOVIMENTAÇÕES NOVAS' OR LEFT(STATUS_MOVIMENTACAO,28) = 'MOVIMENTAÇÕES = AJUSTE')
				)

			SELECT ID_SISJUR,G_TIPO_PROCESSO,TIPO_PROCESSO,SALDO_1_TRI,SALDO_2_TRI,MOVIMENTO,STATUS_MOVIMENTACAO
			INTO [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2]
			FROM MOVIMENTO_COMPARA_SDBR

			PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [3] TABELA ANALISE CRIADA COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

		END TRY

		BEGIN CATCH

			PRINT 'ATENÇÃO!!! FALHA AO APAGAR A TABELA [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2]!!!'
			SET @ERRO = 1
			SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
			PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
		END CATCH
	END
	
	BEGIN
		BEGIN TRY

---------------------------------------------------------------------------------------------------------
----------------- TABELA COM OS TOTAIS DOS MOVIMENTOS DOS SALDOS POR TIPO DE PROCESSO -------------------
---------------------------------------------------------------------------------------------------------

		
			SELECT DISTINCT Z.G_TIPO_PROCESSO,SUM(ISNULL(Z.SALDO_2_TRI,0)) AS SALDO_2_TRI,SUM(ISNULL(Z.SALDO_1_TRI,0)) AS SALDO_1_TRI,SUM(ISNULL(Z.MOVIMENTO,0)) AS MOVIMENTO_CICLO_2  
			INTO [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2_CONSOLIDADO]
			FROM [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2] Z
			GROUP BY Z.G_TIPO_PROCESSO


-----------------------------------------------------------------------------------------------------------------------
------------ CONFORME INFORMADO PELO THOR, O VALOR DAS NOVAS MOVIMENTAÇÕES PARA O 2TRI DO TRIBUTÁRIO FORAM DE, --------
------------ 35.127.723.97, SENDO ASSIM, ADICIONAREMOS ESTA INFORMAÇÃO EM NOSSA TABELA PARA ANÁLISE -------------------
-----------------------------------------------------------------------------------------------------------------------


			INSERT INTO [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2_CONSOLIDADO]
			VALUES
			(
				'TRIBUTÁRIO',
				35127723.97,
				0.00,
				35127723.97
			)
 
			--	SALDO_2_TRI = SALDO_2_TRI + 1391645335.50 + 35000000.00,
			--	MOVIMENTO = ISNULL(SALDO_2_TRI,0) - ISNULL(SALDO_1_TRI,0)
			--WHERE G_TIPO_PROCESSO = 'TRIBUTÁRIO'

			PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [4] TABELA CONSOLIDADO CRIADA COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

		END TRY

		BEGIN CATCH

			PRINT 'ATENÇÃO!!! FALHA AO APAGAR A TABELA [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2_CONSOLIDADO]!!!'
			SET @ERRO = 1
			SET @DESCRICAO_ERRO = ERROR_MESSAGE() 
			PRINT 'MOTIVO: '+ @DESCRICAO_ERRO + CHAR(13)
		
		END CATCH
	END

	SELECT * FROM [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2_CONSOLIDADO]
END 

--SELECT * FROM [ON_GOING].[2_TRI].[ANALISE_MOVIMENTOS_MC_CICLO_2]
--EXEC [dbo].[2TRI_SP_7.0_ANALISE_MOVIMENTOS_CICLO_2]
















