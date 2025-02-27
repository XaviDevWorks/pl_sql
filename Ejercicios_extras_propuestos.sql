-- 1. Procedure per inserir dades a la taula City
DELIMITER $$
CREATE PROCEDURE InsertCity(
    IN pName VARCHAR(35),
    IN pCountryCode CHAR(3),
    IN pDistrict VARCHAR(20),
    IN pPopulation INT
)
BEGIN
    INSERT INTO City (Name, CountryCode, District, Population) 
    VALUES (pName, pCountryCode, pDistrict, pPopulation);
END$$
DELIMITER ;

-- 2. Procedure per obtenir habitants i país d'una ciutat
DELIMITER $$
CREATE PROCEDURE GetCityPopulation(
    IN pCityName VARCHAR(35)
)
BEGIN
    SELECT Population, CountryCode FROM City WHERE Name = pCityName;
END$$
DELIMITER ;

-- 3. Procedure per calcular preu final amb IVA
DELIMITER $$
CREATE PROCEDURE CalculateFinalPrice(
    IN pPrice FLOAT,
    IN pIVA FLOAT,
    OUT pFinalPrice FLOAT
)
BEGIN
    SET pFinalPrice = pPrice + (pPrice * pIVA / 100);
END$$
DELIMITER ;

-- 4. Procedure per guardar en fitxer els països d'una llengua
DELIMITER $$
CREATE PROCEDURE SaveCountriesByLanguage(
    IN pLanguage VARCHAR(50)
)
BEGIN
    SELECT CountryCode INTO OUTFILE '/tmp/countries_by_language.txt'
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    FROM CountryLanguage WHERE Language = pLanguage;
END$$
DELIMITER ;

-- 5. Modificació del procediment anterior per incloure el nom de la llengua al fitxer
DELIMITER $$
CREATE PROCEDURE SaveCountriesByLanguageDynamic(
    IN pLanguage VARCHAR(50)
)
BEGIN
    SET @query = CONCAT('SELECT CountryCode INTO OUTFILE "/tmp/', pLanguage, '.txt" 
    FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" 
    FROM CountryLanguage WHERE Language = "', pLanguage, '"');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- 6. Procedure per comptar idiomes i ciutats d'un país
DELIMITER $$
CREATE PROCEDURE CountLanguagesAndCities(
    IN pCountryID CHAR(3),
    OUT pLanguageCount INT,
    OUT pCityCount INT
)
BEGIN
    SELECT COUNT(*) INTO pLanguageCount FROM CountryLanguage WHERE CountryCode = pCountryID;
    SELECT COUNT(*) INTO pCityCount FROM City WHERE CountryCode = pCountryID;
END$$
DELIMITER ;

-- 7. Procedure per exportar dades de CountryLanguage
DELIMITER $$
CREATE PROCEDURE ExportCountryLanguage(
    IN pFileName VARCHAR(255)
)
BEGIN
    SET @query = CONCAT('SELECT * INTO OUTFILE "/tmp/', pFileName, '" 
    FIELDS TERMINATED BY "," LINES TERMINATED BY "\n" 
    FROM CountryLanguage');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- 8. Procedure per fer backup de totes les taules amb data
DELIMITER $$
CREATE PROCEDURE BackupTables()
BEGIN
    SET @date_suffix = DATE_FORMAT(NOW(), '%Y%m%d');
    SET @query1 = CONCAT('CREATE TABLE City_', @date_suffix, ' AS SELECT * FROM City');
    SET @query2 = CONCAT('CREATE TABLE Country_', @date_suffix, ' AS SELECT * FROM Country');
    SET @query3 = CONCAT('CREATE TABLE CountryLanguage_', @date_suffix, ' AS SELECT * FROM CountryLanguage');
    PREPARE stmt1 FROM @query1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1;
    PREPARE stmt2 FROM @query2; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;
    PREPARE stmt3 FROM @query3; EXECUTE stmt3; DEALLOCATE PREPARE stmt3;
END$$
DELIMITER ;

-- 9. Procedure de calculadora amb CASE i IF
DELIMITER $$
CREATE PROCEDURE Calculator(
    IN pNum1 FLOAT,
    IN pNum2 FLOAT,
    IN pOperacio CHAR(1),
    OUT pResultat FLOAT
)
BEGIN
    CASE pOperacio
        WHEN '+' THEN SET pResultat = pNum1 + pNum2;
        WHEN '-' THEN SET pResultat = pNum1 - pNum2;
        WHEN '*' THEN SET pResultat = pNum1 * pNum2;
        WHEN '/' THEN 
            IF pNum2 = 0 THEN 
                SET pResultat = NULL;
            ELSE 
                SET pResultat = pNum1 / pNum2;
            END IF;
    END CASE;
END$$
DELIMITER ;

-- 10. Loop per buscar la categoria 'Seafood'
DELIMITER $$
CREATE PROCEDURE FindSeafoodCategory()
BEGIN
    DECLARE vCategoryName VARCHAR(50);
    DECLARE vTotalCategories INT;
    SET vTotalCategories = (SELECT COUNT(*) FROM Categories);
    SET @i = 1;
    WHILE @i <= vTotalCategories DO
        SELECT CategoryName INTO vCategoryName FROM Categories WHERE CategoryID = @i;
        IF vCategoryName = 'Seafood' THEN
            SELECT 'Seafood category found';
            LEAVE;
        END IF;
        SET @i = @i + 1;
    END WHILE;
END$$
DELIMITER ;
