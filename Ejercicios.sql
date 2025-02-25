
--1
DECLARE
    v_file UTL_FILE.FILE_TYPE;
    CURSOR c_tablas IS 
        SELECT table_name FROM user_tables; -- Lista todas las tablas del usuario actual
BEGIN
    -- Abrimos el archivo en modo escritura
    v_file := UTL_FILE.FOPEN('/ruta/completa/', 'nombre_tablas.txt', 'W');

    -- Recorremos las tablas y escribimos sus nombres en el archivo
    FOR r IN c_tablas LOOP
        UTL_FILE.PUT_LINE(v_file, r.table_name);
    END LOOP;

    -- Cerramos el archivo
    UTL_FILE.FCLOSE(v_file);
END;
/

--2
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE clientes_backup AS SELECT * FROM clientes';
    EXECUTE IMMEDIATE 'CREATE TABLE productos_backup AS SELECT * FROM productos';
    EXECUTE IMMEDIATE 'CREATE TABLE pedidos_backup AS SELECT * FROM pedidos';
END;
/

--3
DECLARE
    v_file UTL_FILE.FILE_TYPE;
    CURSOR c_paises IS 
        SELECT nombre_pais, habitantes, 
               (habitantes / (SELECT SUM(habitantes) FROM pais)) * 100 AS porcentaje
        FROM pais;
BEGIN
    v_file := UTL_FILE.FOPEN('/ruta/completa/', 'paises_porcentaje.txt', 'W');

    FOR r IN c_paises LOOP
        UTL_FILE.PUT_LINE(v_file, r.nombre_pais || ',' || r.porcentaje);
    END LOOP;

    UTL_FILE.FCLOSE(v_file);
END;
/

--4
DECLARE
    v_file UTL_FILE.FILE_TYPE;
    CURSOR c_cuentas IS 
        SELECT numero_cuenta, saldo FROM cuentas_bancarias WHERE saldo < 0;
BEGIN
    v_file := UTL_FILE.FOPEN('/ruta/completa/', 'cuentas_rojas.txt', 'W');

    FOR r IN c_cuentas LOOP
        UTL_FILE.PUT_LINE(v_file, r.numero_cuenta || ',' || r.saldo);
    END LOOP;

    UTL_FILE.FCLOSE(v_file);
END;
/

--5
-- No se puede crear una base de datos en PL/SQL, pero usamos un esquema.
-- Ahora creamos la tabla persona.

CREATE TABLE persona (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(50),
    apellido VARCHAR2(50),
    apellido2 VARCHAR2(50),
    email VARCHAR2(100),
    dni VARCHAR2(9) UNIQUE
);

-- Insertamos 3 personas en la tabla persona.
INSERT INTO persona (nombre, apellido, apellido2, email, dni) VALUES 
('Juan', 'Pérez', 'Gómez', 'juan.perez@email.com', '12345678A');

INSERT INTO persona (nombre, apellido, apellido2, email, dni) VALUES 
('Ana', 'López', 'Martínez', 'ana.lopez@email.com', '87654321B');

INSERT INTO persona (nombre, apellido, apellido2, email, dni) VALUES 
('Carlos', 'Ruiz', 'Fernández', 'carlos.ruiz@email.com', '56781234C');

COMMIT;

--Tarea 1
-- Crear la tabla para guardar las combinaciones de nombres y apellidos
CREATE TABLE persona_combinaciones (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(50),
    apellido VARCHAR2(50),
    apellido2 VARCHAR2(50)
);

-- Procedimiento para insertar combinaciones
CREATE OR REPLACE PROCEDURE generar_combinaciones AS
    CURSOR cur_nombres IS SELECT DISTINCT nombre FROM persona;
    CURSOR cur_apellidos IS SELECT DISTINCT apellido FROM persona;
    CURSOR cur_apellidos2 IS SELECT DISTINCT apellido2 FROM persona;
    
    v_nombre persona.nombre%TYPE;
    v_apellido persona.apellido%TYPE;
    v_apellido2 persona.apellido2%TYPE;
    
BEGIN
    FOR r1 IN cur_nombres LOOP
        FOR r2 IN cur_apellidos LOOP
            FOR r3 IN cur_apellidos2 LOOP
                INSERT INTO persona_combinaciones (nombre, apellido, apellido2)
                VALUES (r1.nombre, r2.apellido, r3.apellido2);
            END LOOP;
        END LOOP;
    END LOOP;

    COMMIT;
END;
/

--Tarea 2
CREATE OR REPLACE PROCEDURE buscar_email(
    p_dni IN persona.dni%TYPE,
    p_email OUT persona.email%TYPE
) AS
BEGIN
    SELECT email INTO p_email FROM persona WHERE dni = p_dni;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_email := 'No encontrado';
END;
/
--Para ejecutarlo:
DECLARE
    v_email VARCHAR2(100);
BEGIN
    buscar_email('12345678A', v_email);
    DBMS_OUTPUT.PUT_LINE('Email encontrado: ' || v_email);
END;
/

--Tarea 3
CREATE OR REPLACE PROCEDURE normalizar_datos(
    p_id IN persona.id%TYPE
) AS
    v_nombre persona.nombre%TYPE;
    v_apellido persona.apellido%TYPE;
    v_apellido2 persona.apellido2%TYPE;
    v_email persona.email%TYPE;
    v_dni persona.dni%TYPE;
BEGIN
    -- Obtener los datos actuales
    SELECT nombre, apellido, apellido2, email, dni 
    INTO v_nombre, v_apellido, v_apellido2, v_email, v_dni
    FROM persona WHERE id = p_id;

    -- Normalizar nombre y apellidos
    v_nombre := INITCAP(v_nombre);
    v_apellido := INITCAP(v_apellido);
    v_apellido2 := INITCAP(v_apellido2);

    -- Normalizar email (todo en minúsculas)
    v_email := LOWER(v_email);

    -- Normalizar DNI (8 números + 1 letra)
    v_dni := REGEXP_REPLACE(v_dni, '[^0-9A-Z]', ''); -- Elimina caracteres inválidos
    IF LENGTH(v_dni) < 9 THEN
        v_dni := LPAD(SUBSTR(v_dni, 1, LENGTH(v_dni) - 1), 8, '0') || 
                 CASE WHEN REGEXP_LIKE(SUBSTR(v_dni, -1, 1), '[A-Z]') THEN SUBSTR(v_dni, -1, 1) ELSE 'A' END;
    END IF;

    -- Actualizar la fila
    UPDATE persona
    SET nombre = v_nombre, 
        apellido = v_apellido, 
        apellido2 = v_apellido2, 
        email = v_email, 
        dni = v_dni
    WHERE id = p_id;

    COMMIT;
END;
/
--Para ejecutarlo
EXEC normalizar_datos(1); -- Normaliza los datos de la persona con ID 1

