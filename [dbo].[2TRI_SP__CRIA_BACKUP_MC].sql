USE [ON_GOING]
GO
/****** Object:  StoredProcedure [dbo].[2TRI_SP__CRIA_BACKUP_MC]    Script Date: 30/10/2018 08:55:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rennan Correa
-- Create date: 11/09/2018
-- Description:	Realiza backup das tabelas 00_matriz, posições e compara para sisjur, sdbr, extrato e TJ.

-- =============================================
ALTER PROCEDURE [dbo].[2TRI_SP__CRIA_BACKUP_MC] 
		
AS
BEGIN



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DECLARAÇÃO DAS VARIAVEIS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


DECLARE @DATABASE					VARCHAR (100)
DECLARE @00_MATRIZ					VARCHAR (100)
DECLARE @POSICOES_SISJUR			VARCHAR (100)
DECLARE @POSICOES_SDBR				VARCHAR (100)
DECLARE @POSICOES_EXTRATO			VARCHAR (100)
DECLARE @POSICOES_TJ				VARCHAR (100)
DECLARE @COMPARA_SISJUR				VARCHAR (100)
DECLARE @COMPARA_SDBR				VARCHAR (100)
DECLARE @COMPARA_EXTRATO			VARCHAR (100)
DECLARE @COMPARA_TJ					VARCHAR (100)
DECLARE @CRITERIOS_MOV_DIF_AJST		VARCHAR (100)
DECLARE @CRIA_MOV_AJST_SDBR			VARCHAR (100)
DECLARE @CRIA_MOV_AJST_SISJUR		VARCHAR (100)
DECLARE @FECHAMENTO_2_TRI			VARCHAR (100)

DECLARE @erro INT
DECLARE @descricao_erro VARCHAR(500)


SET @DATABASE				= 'ON_GOING.2_TRI.'
SET @00_MATRIZ				= (CONCAT('00_MATRIZ_COMPARACAO','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @POSICOES_SISJUR		= (CONCAT('POSICOES_SISJUR','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @POSICOES_SDBR			= (CONCAT('POSICOES_SDBR','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @POSICOES_EXTRATO		= (CONCAT('POSICOES_EXTRATOS','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @POSICOES_TJ			= (CONCAT('POSICOES_TJ_MC_2_TRI','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @COMPARA_SDBR			= (CONCAT('01_COMPARA_SDBR','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @COMPARA_EXTRATO		= (CONCAT('02_COMPARA_EXTRATO','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @COMPARA_SISJUR			= (CONCAT('03_COMPARA_SISJUR','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @COMPARA_TJ				= (CONCAT('04_COMPARA_TJ_MC','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @CRITERIOS_MOV_DIF_AJST	= (CONCAT('05_CRITERIOS_MOV_DIF_AJST','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @CRIA_MOV_AJST_SDBR		= (CONCAT('SDBR_MOVIMENTACAO_E_AJUSTES','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @CRIA_MOV_AJST_SISJUR	= (CONCAT('SISJUR_MOVIMENTACAO_E_AJUSTES','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))
SET @FECHAMENTO_2_TRI		= (CONCAT('06_FECHAMENTO_2_TRI','_',REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/','_')))

SET @erro = 0
SET @descricao_erro = NULL


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PROCESSO DE REALIZAÇÃO DE BACKUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DE TABELAS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	PRINT '#############################################################################'  + CHAR(13)
	PRINT '########## INICIANDO PROCESSO DE BACKUP DE TABELAS PARA O ONGOING ###########'  + CHAR(13)
	PRINT '############################ RENOMEANDO TABELAS #############################'  + CHAR(13)
	PRINT '#############################################################################'  + CHAR(13)



	BEGIN TRY

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@00_MATRIZ)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.00_MATRIZ_COMPARACAO', @00_MATRIZ

		--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@POSICOES_SISJUR)) AND type in (N'U'))
		--		EXEC SP_rename '2_TRI.POSICOES_SISJUR', @POSICOES_SISJUR

		--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@POSICOES_SDBR)) AND type in (N'U'))
		--		EXEC SP_rename '2_TRI.POSICOES_SDBR', @POSICOES_SDBR

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@POSICOES_EXTRATO)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.POSICOES_EXTRATOS', @POSICOES_EXTRATO

		--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@POSICOES_TJ)) AND type in (N'U'))
		--		EXEC SP_rename '2_TRI.POSICOES_TJ_MC_2_TRI', @POSICOES_TJ

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@COMPARA_SDBR)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.01_COMPARA_SDBR', @COMPARA_SDBR

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@COMPARA_EXTRATO)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.02_COMPARA_EXTRATO', @COMPARA_EXTRATO

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@COMPARA_SISJUR)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.03_COMPARA_SISJUR', @COMPARA_SISJUR

		--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@COMPARA_TJ)) AND type in (N'U'))
		--		EXEC SP_rename '2_TRI.04_COMPARA_TJ_MC', @COMPARA_TJ

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@CRITERIOS_MOV_DIF_AJST)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.05_CRITERIOS_MOV_DIF_AJST', @CRITERIOS_MOV_DIF_AJST

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@CRIA_MOV_AJST_SDBR)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.SDBR_MOVIMENTACAO_E_AJUSTES', @CRIA_MOV_AJST_SDBR

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@CRIA_MOV_AJST_SISJUR)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.SISJUR_MOVIMENTACAO_E_AJUSTES', @CRIA_MOV_AJST_SISJUR

		IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(CONCAT(@DATABASE,@FECHAMENTO_2_TRI)) AND type in (N'U'))
				EXEC SP_rename '2_TRI.06_FECHAMENTO_2_TRI', @FECHAMENTO_2_TRI

		PRINT UPPER(replace(replace(system_user,'.',' '),'OI\',''))+', [1] BACKUP DE TABELAS REALIZADO COM SUCESSO!'+ CONVERT(CHAR(20),@@ROWCOUNT)  + CHAR(13)

		
		--EXEC sys.sp_refreshsqlmodule 'ON_GOING'

	END TRY
		BEGIN CATCH
			PRINT 'ATENÇÃO!!! FALHA AO RENOMEAR TABELAS!!!'
				SET @erro = 1
				SET @descricao_erro = ERROR_MESSAGE() 
			PRINT 'MOTIVO: '+ @descricao_erro + CHAR(13)
		END CATCH


END

--EXEC [dbo].[2TRI_SP__CRIA_BACKUP_MC]




