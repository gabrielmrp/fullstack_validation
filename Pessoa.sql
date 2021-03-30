--  #####   ######   ###     #    
-- #     #  #     #   #     # #   
-- #        #     #   #    #   #  
-- #        ######    #   #     # 
-- #        #   #     #   ####### 
-- #     #  #    #    #   #     #  
--  #####   #     #  ###  #     #  
BEGIN TRANSACTION;  
SET QUERY_GOVERNOR_COST_LIMIT 6000;
  CREATE TABLE  Pessoa 
( 
     idPessoa int IDENTITY(1,1) NOT NULL,
     documento_cdTipo  BIT NOT NULL,
     documento_numero NVARCHAR(18) NOT NULL,
     nome NVARCHAR(150) NOT NULL,
     razaoSocial NVARCHAR(150) NULL,
     telefones XML NOT NULL,
     emails XML NOT NULL,
     dataNascimento DATE NULL,
     dataFundacao DATE NULL,
     website NVARCHAR(300) NULL,
     DTINS DATETIME NOT NULL,
     DTALT DATETIME NULL DEFAULT CURRENT_TIMESTAMP, 
     CONSTRAINT PK_Pessoa_1 PRIMARY KEY   ( idPessoa ASC )
     WITH (
     pad_index = OFF, statistics_norecompute = OFF,
     ignore_dup_key = OFF,
     allow_row_locks = on, allow_page_locks = on
     ) ON [PRIMARY]
 )
ON [PRIMARY] textimage_on [PRIMARY]
--
GO
--
CREATE TABLE  Error_Msg
(
id_Error_Msg int IDENTITY(1,1) NOT NULL,
errorMsg NVARCHAR(300)  NOT NULL,
translated NVARCHAR(300)  NOT NULL
)
--
GO
--
DELETE FROM Error_Msg;
INSERT INTO Error_Msg (errorMsg,translated) VALUES 
('The INSERT statement conflicted with the CHECK constraint "documento_cdTipo_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Código de documento inválido!'),
('The INSERT statement conflicted with the CHECK constraint "Uniquedocumento_numero". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Número de documento já inserido!'),
('The INSERT statement conflicted with the CHECK constraint "Validodocumento_numero". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa", column ''documento_numero''.','CPF/CNPJ Inválido!'),
('The INSERT statement conflicted with the CHECK constraint "Tipodocumentocorreto". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Tipo de documento diferente do tipo de Pessoa!'),
('The INSERT statement conflicted with the CHECK constraint "NomeValido_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Nome com caracteres inválidos'),
('The INSERT statement conflicted with the CHECK constraint "razaoSocialPessoaFisica_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Razão social não deve ser preenchida para Pessoa Física'),
('The INSERT statement conflicted with the CHECK constraint "razaoSocialPreenchida_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Razão social deve ser preenchida para Pessoa Jurídica'),
('The INSERT statement conflicted with the CHECK constraint "razaoSocialValida_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Razão social com caracteres inválidos'),
('The INSERT statement conflicted with the CHECK constraint "TelefoneValida_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa", column ''telefones''.','Formato de telefone inválido'),
('The INSERT statement conflicted with the CHECK constraint "dataUnica_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Tipo de data Inválido.'),
('The INSERT statement conflicted with the CHECK constraint "dataNascimento_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Data de Fundação Inválida!'),
('The INSERT statement conflicted with the CHECK constraint "dataNascimentoTipo_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Data de Nascimento não se aplica para Pessoa Jurídica!'),
('The INSERT statement conflicted with the CHECK constraint "dataFundacao_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Data de Fundação Inválida!'),
('The INSERT statement conflicted with the CHECK constraint "dataFundacaoTipo_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa".','Data de Fundação não se aplica para Pessoa Física!'),
('The INSERT statement conflicted with the CHECK constraint "website_check". The conflict occurred in database "DB_A71D65_contatos", table "dbo.Pessoa", column ''website''.','Formato de Website Inválido')
--
---#######  #     #  #     #   #####   ###  #######  #     #     #     #        ###  ######      #     ######   #######   #####  
-- #        #     #  ##    #  #     #   #   #     #  ##    #    # #    #         #   #     #    # #    #     #  #        #     # 
-- #        #     #  # #   #  #         #   #     #  # #   #   #   #   #         #   #     #   #   #   #     #  #        #       
-- #####    #     #  #  #  #  #         #   #     #  #  #  #  #     #  #         #   #     #  #     #  #     #  #####     #####  
-- #        #     #  #   # #  #         #   #     #  #   # #  #######  #         #   #     #  #######  #     #  #              # 
-- #        #     #  #    ##  #     #   #   #     #  #    ##  #     #  #         #   #     #  #     #  #     #  #        #     # 
-- #         #####   #     #   #####   ###  #######  #     #  #     #  #######  ###  ######   #     #  ######   #######   #####  
--
-------------------------------------------------
---DOCUMENTO CD TIPO
-------------------------------------------------
-- CONSTRAINTS
ALTER TABLE Pessoa ADD CONSTRAINT documento_cdTipo_check CHECK (documento_cdTipo = 0 OR documento_cdTipo = 1)
GO
-- 
-------------------------------------------------
---DOCUMENTO NUMERO
-------------------------------------------------
--
CREATE OR ALTER FUNCTION dbo.Valida_CNPJ ( @CNPJ VARCHAR(14) )
RETURNS BIT
AS
BEGIN 
    DECLARE
        @INDICE INT, @SOMA INT,@DIG1 INT,@DIG2 INT,@VAR1 INT,@VAR2 INT,@RESULTADO CHAR(1) 
    SET @SOMA = 0
    SET @INDICE = 1
    SET @RESULTADO = 0
    SET @VAR1 = 5 /* 1a Parte do Algorítimo começando de "5" */ 
    WHILE ( @INDICE < = 4 )
    BEGIN
        SET @SOMA = @SOMA + CONVERT(INT, SUBSTRING(@CNPJ, @INDICE, 1)) * @VAR1
        SET @INDICE = @INDICE + 1 /* Navegando um-a-um até < = 4, as quatro primeira posições */
        SET @VAR1 = @VAR1 - 1       /* subtraindo o algorítimo de 5 até 2 */
    END 
    SET @VAR2 = 9
    WHILE ( @INDICE <= 12 )
    BEGIN
        SET @SOMA = @SOMA + CONVERT(INT, SUBSTRING(@CNPJ, @INDICE, 1)) * @VAR2
        SET @INDICE = @INDICE + 1
        SET @VAR2 = @VAR2 - 1            
    END 
    SET @DIG1 = ( @SOMA % 11 ) 
   /* SE O RESTO DA DIVISÃO FOR < 2, O DIGITO = 0 */
    IF @DIG1 < 2
        SET @DIG1 = 0
    ELSE /* SE O RESTO DA DIVISÃO NÃO FOR < 2*/
        SET @DIG1 = 11 - ( @SOMA % 11 ) 
    SET @INDICE = 1
    SET @SOMA = 0
    SET @VAR1 = 6 /* 2a Parte do Algorítimo começando de "6" */
    SET @RESULTADO = 0 
    WHILE ( @INDICE <= 5 )
    BEGIN
        SET @SOMA = @SOMA + CONVERT(INT, SUBSTRING(@CNPJ, @INDICE, 1)) * @VAR1
        SET @INDICE = @INDICE + 1 /* Navegando um-a-um até < = 5, as quatro primeira posições */
        SET @VAR1 = @VAR1 - 1       /* subtraindo o algorítimo de 6 até 2 */
    END 
    /* CÁLCULO DA 2ª PARTE DO ALGORÍTIOM 98765432 */
    SET @VAR2 = 9
    WHILE ( @INDICE <= 13 )
    BEGIN
        SET @SOMA = @SOMA + CONVERT(INT, SUBSTRING(@CNPJ, @INDICE, 1)) * @VAR2
        SET @INDICE = @INDICE + 1
        SET @VAR2 = @VAR2 - 1            
    END 
    SET @DIG2 = ( @SOMA % 11 ) 
   /* SE O RESTO DA DIVISÃO FOR < 2, O DIGITO = 0 */ 
    IF @DIG2 < 2
        SET @DIG2 = 0
    ELSE /* SE O RESTO DA DIVISÃO NÃO FOR < 2*/
        SET @DIG2 = 11 - ( @SOMA % 11 )
    IF ( @DIG1 = SUBSTRING(@CNPJ, LEN(@CNPJ) - 1, 1) ) AND ( @DIG2 = SUBSTRING(@CNPJ, LEN(@CNPJ), 1) )
        SET @RESULTADO = 1
    ELSE
        SET @RESULTADO = 0 
    RETURN @RESULTADO 
END
--
GO
--https://www.dirceuresende.com/blog/validando-cpf-cnpj-e-mail-telefone-e-cep-no-sql-server/ 
CREATE OR ALTER FUNCTION dbo.Valida_CPF(
    @Nr_Documento VARCHAR(11)
)
RETURNS BIT -- 1 = válido, 0 = inválido
WITH SCHEMABINDING
BEGIN 
    DECLARE
        @Contador_1 INT,
        @Contador_2 INT,
        @Digito_1 INT,
        @Digito_2 INT,
        @Nr_Documento_Aux VARCHAR(11) 
    -- Remove espaços em branco
    SET @Nr_Documento_Aux = LTRIM(RTRIM(@Nr_Documento))
    SET @Digito_1 = 0 
    -- Remove os números que funcionam como validação para CPF, pois eles "passam" pela regra de validação
    IF (@Nr_Documento_Aux IN ('00000000000', '11111111111', '22222222222', '33333333333', '44444444444', '55555555555', '66666666666', '77777777777', '88888888888', '99999999999', '12345678909'))
        RETURN 0 
    -- Verifica se possui apenas 11 caracteres
    IF (LEN(@Nr_Documento_Aux) <> 11)
        RETURN 0
    ELSE 
    BEGIN 
        -- Cálculo do segundo dígito
        SET @Nr_Documento_Aux = SUBSTRING(@Nr_Documento_Aux, 1, 9) 
        SET @Contador_1 = 2 
        WHILE (@Contador_1 < = 10)
        BEGIN 
            SET @Digito_1 = @Digito_1 + (@Contador_1 * CAST(SUBSTRING(@Nr_Documento_Aux, 11 - @Contador_1, 1) as int))
            SET @Contador_1 = @Contador_1 + 1
        end  
        SET @Digito_1 = @Digito_1 - (@Digito_1/11)*11 
        IF (@Digito_1 <= 1)
            SET @Digito_1 = 0
        ELSE 
            SET @Digito_1 = 11 - @Digito_1 
        SET @Nr_Documento_Aux = @Nr_Documento_Aux + CAST(@Digito_1 AS VARCHAR(1)) 
        IF (@Nr_Documento_Aux <> SUBSTRING(@Nr_Documento, 1, 10))
            RETURN 0
        ELSE BEGIN         
            -- Cálculo do segundo dígito
            SET @Digito_2 = 0
            SET @Contador_2 = 2 
            WHILE (@Contador_2 < = 11)
            BEGIN 
                SET @Digito_2 = @Digito_2 + (@Contador_2 * CAST(SUBSTRING(@Nr_Documento_Aux, 12 - @Contador_2, 1) AS INT))
                SET @Contador_2 = @Contador_2 + 1
            end  
            SET @Digito_2 = @Digito_2 - (@Digito_2/11)*11 
            IF (@Digito_2 < 2)
                SET @Digito_2 = 0
            ELSE 
                SET @Digito_2 = 11 - @Digito_2 
            SET @Nr_Documento_Aux = @Nr_Documento_Aux + CAST(@Digito_2 AS VARCHAR(1)) 
            IF (@Nr_Documento_Aux <> @Nr_Documento)
                RETURN 0                
        END
    END     
    RETURN 1    
END
--https://www.dirceuresende.com/blog/validando-cpf-cnpj-e-mail-telefone-e-cep-no-sql-server/ 
GO 
--
CREATE OR ALTER FUNCTION dbo.ValidaRegradocumento_numero ( 
    @Nr_Documento NVARCHAR(18) 
)
RETURNS BIT
AS BEGIN
    DECLARE @Retorno BIT = 0
    IF (LEN(@Nr_Documento) = 11)
    BEGIN
        -- Valida CPF
        IF (@Nr_Documento IN ('00000000000', '11111111111', '22222222222', '33333333333', '44444444444', '55555555555', '66666666666', '77777777777', '88888888888', '99999999999', '12345678909'))
            SET @Retorno = 0
        ELSE
            SET @Retorno =  dbo.Valida_CPF(@Nr_Documento)
    END
    ELSE BEGIN 
        -- Valida CNPJ
        IF (LEN(@Nr_Documento) = 14)
            SET @Retorno = dbo.Valida_CNPJ(@Nr_Documento)
        ELSE
            SET @Retorno = 0
    END
    RETURN @Retorno  
END
--
GO
-- 
CREATE OR ALTER FUNCTION dbo.Extrainumerosdocumento_numero ( @str NVARCHAR(18) )
RETURNS NVARCHAR(18)
BEGIN   
    DECLARE @startingIndex INT  
    SET @startingIndex = 0      
    WHILE (1 = 1)
    BEGIN      
        SET @startingIndex = PATINDEX('%[^0-9]%', @str)  
        IF @startingIndex <> 0
            SET @str = REPLACE(@str, SUBSTRING(@str, @startingIndex, 1), '')  
        ELSE
            BREAK            
    END 
    RETURN @str  
    END
--
GO
--    
CREATE OR ALTER FUNCTION dbo.ValidaMascaradocumento_numero (@documento_numero NVARCHAR(18))
RETURNS BIT
BEGIN  
	IF(LEN(@documento_numero)=14)
		RETURN IIF(SUBSTRING(@documento_numero , 4, 1)='.' AND
		 SUBSTRING(@documento_numero , 8, 1)='.' AND
		 SUBSTRING(@documento_numero , 12, 1)='-' AND 
		 LEN(dbo.Extrainumerosdocumento_numero( @documento_numero))=11
		 ,1,0)
	 IF(LEN(@documento_numero)=18)
	 	RETURN IIF(SUBSTRING(@documento_numero , 3, 1)='.' AND
		 SUBSTRING(@documento_numero , 7, 1)='.' AND
		 SUBSTRING(@documento_numero , 11, 1)='/' AND
		 SUBSTRING(@documento_numero , 16, 1)='-'   AND
		 LEN(dbo.Extrainumerosdocumento_numero( @documento_numero))=14
		 ,1,0)
	 RETURN 0
END
--
GO 
--
CREATE OR ALTER FUNCTION dbo.Validadocumento_numero (@documento_numero NVARCHAR(18))
RETURNS BIT
BEGIN  
	IF(dbo.ValidaMascaradocumento_numero(@documento_numero)=0)	
		RETURN 0
	ELSE 
		RETURN dbo.ValidaRegradocumento_numero(
			dbo.Extrainumerosdocumento_numero(@documento_numero)
			)
	RETURN 0
END
--
GO
--   
-- CONSTRAINTS
ALTER TABLE Pessoa ADD CONSTRAINT Uniquedocumento_numero UNIQUE(documento_numero)
--
GO
-- 
ALTER TABLE Pessoa ADD CONSTRAINT Validodocumento_numero CHECK (dbo.Validadocumento_numero(documento_numero)=1)
--
GO
-- 
ALTER TABLE Pessoa ADD CONSTRAINT Tipodocumentocorreto CHECK ( (LEN(documento_numero)=14 AND  documento_cdTipo = 0) OR (LEN(documento_numero)=18 AND  documento_cdTipo = 1))
-- 
-------------------------------------------------
---NOME
-------------------------------------------------
--
GO
-- 
CREATE OR ALTER FUNCTION dbo.ValidaTexto( @str NVARCHAR(18) )
RETURNS NVARCHAR(18)
BEGIN   
    DECLARE @startingIndex INT  
    SET @startingIndex = 0      
    WHILE (1 = 1)
    BEGIN      
        SET @startingIndex = PATINDEX('%[ #0-9a-zA-Z_-]%', REPLACE(@str,CHAR(39),' '))  
        IF @startingIndex <> 0
            SET @str = REPLACE(@str, SUBSTRING(@str, @startingIndex, 1), '')  
        ELSE
            BREAK            
    END 
    RETURN IIF(@str='',1,0)  
    END;  
--
GO
--  
-- CONSTRAINTS
--O valor deste campo deve possuir apenas letras, espaços, números e os seguintes símbolos ('; &; #; _; -)
ALTER TABLE Pessoa ADD CONSTRAINT NomeValido_check CHECK (dbo.ValidaTexto(nome)=1) 
--
GO
--  
-------------------------------------------------
---RAZÃO SOCIAL
-------------------------------------------------
-- CONSTRAINTS
--Deverá ser preenchido se documento_cdTipo 1;
ALTER TABLE Pessoa ADD CONSTRAINT razaoSocialPessoaFisica_check CHECK ((documento_cdTipo = 0 AND razaoSocial IS NULL) OR documento_cdTipo = 1 )
--
GO
-- 
ALTER TABLE Pessoa ADD CONSTRAINT razaoSocialPreenchida_check CHECK ((razaoSocial IS NOT NULL AND documento_cdTipo = 1) OR documento_cdTipo =0 )
--
GO
-- 
--O valor deste campo deve possuir apenas letras, espaços, números e os seguintes símbolos ('; &; #; _; -)
ALTER TABLE Pessoa ADD CONSTRAINT razaoSocialValida_check CHECK (dbo.ValidaTexto(razaoSocial)=1 OR razaoSocial IS  NULL)
--
GO
-- 
-------------------------------------------------
---TELEFONE: 
-------------------------------------------------
CREATE OR ALTER FUNCTION dbo.ValidaFormatoTelefone (  
   @TELEFONES XML)
RETURNS BIT
AS
BEGIN
	-- Número de digitos de acordo com: Máscara (99) 9999-9999 ou (99) 99999-9999;  
 	DECLARE @SOMAINVALIDOS INT  = ( 
 	SELECT SUM( IIF(SUBSTRING(RIGHT(telefone.query('.').value('.','VARCHAR(15)'),5),1,1)='-' AND
	 SUBSTRING(telefone.query('.').value('.','VARCHAR(15)'),1,1)='(' AND
	 SUBSTRING(telefone.query('.').value('.','VARCHAR(15)'),4,2)=') ' AND (
	 LEN(dbo.Extrainumerosdocumento_numero( telefone.query('.').value('.','VARCHAR(15)')))=10 OR 
	 LEN(dbo.Extrainumerosdocumento_numero( telefone.query('.').value('.','VARCHAR(15)')))=11  )
	 ,0,1))
	FROM @TELEFONES.nodes('telefones/telefone') Telefones(telefone)  
	   )
	   
	 --Deverá possuir ao menos um telefone.   
	 DECLARE @counts INT
	SET @counts =  (SELECT COUNT(telefone.query('.').value('.','VARCHAR(15)')) AS count_telefone 		
	FROM @TELEFONES.nodes('telefones/telefone') Telefones(telefone)	)   
	   
	--Deverá possuir somente um telefone com atributo  principal 1.    
	DECLARE @counts_principal INT 
	 = (SELECT  SUM(IIF(CHARINDEX('principal="1"',CAST(telefone.query('.') AS VARCHAR(100)))>0,1,0)) AS count_telefone 		
	FROM @TELEFONES.nodes('telefones/telefone') Telefones(telefone))  	
	RETURN IIF(@SOMAINVALIDOS=0 AND @counts>0 AND @counts_principal =1 ,1,0)
END
--
GO
-- 
-- CONSTRAINTS
ALTER TABLE Pessoa ADD CONSTRAINT TelefoneValida_check CHECK (dbo.ValidaFormatoTelefone(telefones)=1)  
--
GO
-- 
DECLARE @TELEFONE XML
SET @TELEFONE = '<telefones><telefone principal="1">(31) 99970-1132</telefone><telefone>(11) 9970-1132</telefone></telefones>'
SELECT  dbo.ValidaFormatoTelefone(@TELEFONE)
--
GO
-- 
-------------------------------------------------
---DATA DE NASCIMENTO 
------------------------------------------------- 
CREATE OR ALTER FUNCTION dbo.IsValiddataNascimento(@DATADENASCIMENTO DATE)
RETURNS INT
AS
BEGIN  	
   SET @DATADENASCIMENTO = CONVERT( DATETIME, @DATADENASCIMENTO, 103 )
    --Ano deverá ser maior que 1900; 
   DECLARE @anoMaior1900 INT
   SET @anoMaior1900 = DATEDIFF(year, CONVERT( DATETIME, '31/12/1900', 103 ), @DATADENASCIMENTO )
    --Data deverá ser menor que a data atual. 
   DECLARE @dataMenorAtual INT
   SET @dataMenorAtual = DATEDIFF(year,  @DATADENASCIMENTO,GETDATE() ) 
   DECLARE @anoMaior1900ok BIT  
   SET @anoMaior1900ok = IIF(@anoMaior1900 > 0 ,1,0)   
   RETURN  IIF(@dataMenorAtual > 0 AND @anoMaior1900ok=1 ,1,0)  
END
--
GO
-- 
ALTER TABLE Pessoa ADD CONSTRAINT dataUnica_check CHECK ( (dataFundacao IS NULL AND documento_cdTipo=0) OR (documento_cdTipo=1 AND dataNascimento IS NULL))  

ALTER TABLE Pessoa ADD CONSTRAINT dataNascimento_check CHECK ((dbo.IsValiddataNascimento(dataNascimento)=1 AND documento_cdTipo=0) OR dataNascimento IS NULL)  
ALTER TABLE Pessoa ADD CONSTRAINT dataNascimentoTipo_check CHECK ((dataNascimento IS  NULL AND documento_cdTipo=1) OR documento_cdTipo=0) 
-------------------------------------------------
---DATA DE FUNDAÇÃO 
------------------------------------------------- 
--
GO
-- 
CREATE OR ALTER FUNCTION dbo.IsValiddataFundacao(@DATADEFUNDACAO DATE)
RETURNS INT
AS
BEGIN  	
   SET @DATADEFUNDACAO = CONVERT( DATE, @DATADEFUNDACAO, 103 )     
    --Data deverá ser menor que a data atual. 
   DECLARE @dataMenorAtual INT
   SET @dataMenorAtual = DATEDIFF(year,  @DATADEFUNDACAO,GETDATE() )     
   RETURN  IIF(@dataMenorAtual > 0 ,1,0)  
END
--
GO
ALTER TABLE Pessoa ADD CONSTRAINT dataFundacao_check CHECK ((dbo.IsValiddataFundacao(dataFundacao)=1 AND documento_cdTipo=1) OR dataFundacao IS NULL) 
ALTER TABLE Pessoa ADD CONSTRAINT dataFundacaoTipo_check CHECK ((dataFundacao IS  NULL AND documento_cdTipo=0) OR documento_cdTipo=1)
-------------------------------------------------
---WEBSITE
------------------------------------------------- 
--
GO
--  
CREATE OR ALTER FUNCTION dbo.IsValidwebsite (@Url VARCHAR(200))
RETURNS BIT
AS
BEGIN
	--DECLARE @URL VARCHAR(129) = 'http://sqlfiddle.com.br'
	DECLARE @http BIT
	DECLARE @https BIT
	SET @http =  PatIndex('%http://[a-zA-Z0-9.a-zA-Z0-9]%', @URL)
	SET @https =  PatIndex('%https://[a-zA-Z0-9.a-zA-Z0-9]%', @URL)
	RETURN IIF(@http>0,1,IIF(@https>0,1,0)) 	
END
--
GO
-- 
-- CONSTRAINTS
ALTER TABLE Pessoa ADD CONSTRAINT website_check CHECK (dbo.IsValidwebsite(website)=1)  
--
GO
-- 
-------------------------------------------------
---DTALT
------------------------------------------------- 
--Deverá ser preenchido com a data atual no ato de  alteração.
CREATE TRIGGER ModDate
    ON Pessoa
    AFTER UPDATE
AS
BEGIN
    UPDATE X 
    SET DTALT = CURRENT_TIMESTAMP
    FROM Pessoa X
    JOIN inserted i ON X.idPessoa = i.idPessoa  
END 
--
GO
--
--
 --###  #     #   #####   #######  ######   ####### 
  --#   ##    #  #     #  #        #     #  #       
  --#   # #   #  #        #        #     #  #       
  --#   #  #  #   #####   #####    ######   #####   
  --#   #   # #        #  #        #   #    #       
  --#   #    ##  #     #  #        #    #   #       
 --###  #     #   #####   #######  #     #  #######
 --
 -- 
CREATE OR ALTER FUNCTION dbo.TRANSLATE_ERROR_MSG  (
	@MENSAGEM VARCHAR(300) 
	  )
RETURNS VARCHAR(300) 
AS  
	BEGIN 
	DECLARE @RESPOSTA VARCHAR(300) 
	SET @RESPOSTA = (SELECT translated FROM Error_Msg WHERE errorMsg = @MENSAGEM)
	IF @RESPOSTA IS NULL
	BEGIN 
		RETURN @MENSAGEM
	END
    RETURN @RESPOSTA
    END    
GO   
-------------------------------------------------
---RETORNO: ERRO
-------------------------------------------------       
CREATE OR ALTER FUNCTION dbo.GET_ERROR  (
	@MENSAGEM NVARCHAR(100) 
	  )
RETURNS XML
AS  
	BEGIN
	DECLARE @RESPOSTA XML
	SET @RESPOSTA = 
	(SELECT   
    0 AS status, 
    IIF(@MENSAGEM<>'',@MENSAGEM,dbo.TRANSLATE_ERROR_MSG(ERROR_MESSAGE())) AS mensagem
    FOR XML PATH('Retorno'),ELEMENTS)
    RETURN @RESPOSTA
    END    
GO   
-------------------------------------------------
---RETORNO: SUCESSO
-------------------------------------------------   
CREATE OR ALTER FUNCTION dbo.GET_SUCCESS  (
	@MENSAGEM NVARCHAR(100) 
	  )
RETURNS XML
AS  
	BEGIN
	DECLARE @RESPOSTA XML
	SET @RESPOSTA = 
	(SELECT      
    1 AS status, 
    IIF(@MENSAGEM<>'',@MENSAGEM,'Registro inserido com sucesso') AS mensagem,
    (SELECT MAX(idPessoa)+1 FROM Pessoa) AS idPessoa
    FOR XML PATH('Retorno'),ELEMENTS)
    RETURN @RESPOSTA
    END
GO    
-------------------------------------------------
---INSERÇÃO: PROCEDIMENTO
-------------------------------------------------     
CREATE OR ALTER PROCEDURE dbo.SPA_Pessoa_INSERT
   @CAMPOS XML,
   @RETORNO XML OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  SET QUERY_GOVERNOR_COST_LIMIT 6000
  BEGIN TRY	
	  INSERT INTO Pessoa
	  SELECT 
	    Pessoa.value('documento_cdTipo[1]','bit') AS documento_cdTipo,
	    Pessoa.value('documento_numero[1]','NVARCHAR(18)') AS documento_numero,
	    Pessoa.value('nome[1]','NVARCHAR(150)') AS nome,
	    Pessoa.value('razaoSocial[1]','NVARCHAR(150)') AS razaoSocial,
	    Pessoa.query('telefones[1]') AS telefones,
	    Pessoa.query('emails[1]') AS emails,
	    Pessoa.value('dataNascimento[1]','DATE') AS dataNascimento,
	    Pessoa.value('dataFundacao[1]','DATE') AS dataFundacao,
	    Pessoa.value('website[1]','NVARCHAR(300)') AS website,
	    GETDATE() AS DTINS, 
	    NULL AS DTALT 
	    FROM @CAMPOS.nodes('contatos/Pessoa') contatos(Pessoa)
	    SET @RETORNO = dbo.GET_SUCCESS('')
   END TRY
   BEGIN CATCH
   SET @RETORNO = dbo.GET_ERROR('') 
   END CATCH
RETURN
END
GO
-------------------------------------------------
---INSERÇÃO: CHAMADA
-------------------------------------------------    
DELETE FROM Pessoa  
--INSERT FILE  
DECLARE @FileXML XML
DECLARE @RESULT XML
SET @FileXML = '<?xml version="1.0"?>
<contatos>
    <Pessoa>
        <documento_cdTipo>0</documento_cdTipo>
        <documento_numero>065.821.786-01</documento_numero>
        <nome>José Alves Filho</nome> 
        <telefones><telefone principal="1">(31) 99970-1132</telefone><telefone>(11) 9970-1132</telefone></telefones>
        <emails><email principal="1">jalfi@gmail.com</email><email>jalfi2@gmail.com</email></emails>
        <dataNascimento>01/02/1980</dataNascimento> 
        <website>http://www.jalfi.com</website>
    </Pessoa>
</contatos>
<contatos>
    <Pessoa>
        <documento_cdTipo>1</documento_cdTipo>
        <documento_numero>07.950.377/0001-50</documento_numero>  
        <nome>Mtc Informática LTDA</nome>
        <razaoSocial>Mtc Informática Produtos e Serviços LTDA</razaoSocial>
        <telefones><telefone principal="1">(31) 98970-1132</telefone><telefone>(16) 9570-1232</telefone></telefones>
        <emails><email principal="1">contato@mtc.com</email></emails> 
        <dataFundacao>01/02/2000</dataFundacao>
        <website>https://www.mtc.com.br</website>
    </Pessoa>
</contatos>' 
EXEC dbo.SPA_Pessoa_INSERT @FileXML , @RESULT OUT 
SELECT @RESULT
--
GO
--
COMMIT TRANSACTION

/*
 #     #  ###   #####   #     #     #     #        ###  #######     #    
 #     #   #   #     #  #     #    # #    #         #        #     # #   
 #     #   #   #        #     #   #   #   #         #       #     #   #  
 #     #   #    #####   #     #  #     #  #         #      #     #     # 
  #   #    #         #  #     #  #######  #         #     #      ####### 
   # #     #   #     #  #     #  #     #  #         #    #       #     # 
    #     ###   #####    #####   #     #  #######  ###  #######  #     #      
*/
-------------------------------------------------
---CRIAÇÃO DA VIEW
-------------------------------------------------  
CREATE OR ALTER VIEW VE_Pessoa AS
SELECT  
	idPessoa,
	--Descrição: Campo da tabela.
	IIF(documento_cdTipo=0,'F','J') AS tipo,
	--Descrição: O campo deverá possuir os valores F ou J de acordo com documento_cdTipo.
	documento_cdTipo,
	--Descrição: Campo da tabela.
	documento_numero,
	--Descrição: Campo da tabela.
	nome,
	--Descrição: Campo da tabela.
	IIF(documento_cdTipo=0,NULL,nome) AS nomeFantasia,
	--Descrição: O campo deverá trazer o valor de nome quando documento_cdTipo 1.
	razaoSocial,
	--Descrição: Campo da tabela.
	CONCAT((SELECT string_agg(telefone.query('.').value('.','VARCHAR(12)'),',')
	FROM telefones.nodes('telefones/telefone') Telefones(telefone) ),'.') AS telefones,
	--Descrição: Trazer os números de telefone separados por vírgula e com ponto ao final.	
	(SELECT string_agg(telefone.query('.').value('.','VARCHAR(12)'),',')
	FROM telefones.nodes('telefones/telefone') Telefones(telefone) 
	WHERE telefone.value('./@principal','int')=1) AS telefonePrincipal,
	--Descrição: O campo deverá trazer o número do telefone que possui o atributo principal.
	dataNascimento,
	--Descrição: Campo da tabela.
	dataFundacao,
	--Descrição: Campo da tabela.
	website,
	--Descrição: Campo da tabela.
	DTINS,
	--Descrição: Campo da tabela.
	DTALT
	--Descrição: Campo da tabela.
FROM Pessoa
SELECT * FROM VE_Pessoa
--


 

