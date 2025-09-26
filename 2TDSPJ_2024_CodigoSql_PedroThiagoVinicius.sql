DROP TABLE logs CASCADE CONSTRAINTS;
DROP TABLE Motorcycles CASCADE CONSTRAINTS;
DROP TABLE spots CASCADE CONSTRAINTS;
DROP TABLE sector_points CASCADE CONSTRAINTS;
DROP TABLE yard_points CASCADE CONSTRAINTS;
DROP TABLE sectors CASCADE CONSTRAINTS;
DROP TABLE sector_types CASCADE CONSTRAINTS;
DROP TABLE yards CASCADE CONSTRAINTS;
DROP TABLE addresses CASCADE CONSTRAINTS;


CREATE TABLE addresses (
    id CHAR(36) PRIMARY KEY,
    street VARCHAR2(150) NOT NULL,
    number_address NUMBER NOT NULL,
    neighborhood VARCHAR2(100) NOT NULL,
    city VARCHAR2(100) NOT NULL,
    state VARCHAR2(50) NOT NULL,
    zip_code VARCHAR2(8) NOT NULL,
    country VARCHAR2(100) NOT NULL
);

CREATE TABLE sector_types (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR2(100) NOT NULL
);

CREATE TABLE yards (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    address_id CHAR(36) NOT NULL UNIQUE,
    CONSTRAINT fk_yards_address FOREIGN KEY (address_id) REFERENCES addresses(id)
);

CREATE TABLE sectors (
    id CHAR(36) PRIMARY KEY,
    yard_id CHAR(36) NOT NULL,
    sector_type_id CHAR(36) NOT NULL,
    CONSTRAINT fk_sectors_yard FOREIGN KEY (yard_id) REFERENCES yards(id),
    CONSTRAINT fk_sectors_sector_type FOREIGN KEY (sector_type_id) REFERENCES sector_types(id)
);

CREATE TABLE spots (
    spot_id CHAR(36) PRIMARY KEY,
    sector_id CHAR(36) NOT NULL,
    x NUMBER NOT NULL,
    y NUMBER NOT NULL,
    status VARCHAR2(50) NOT NULL,
    motorcycle_id CHAR(36),
    CONSTRAINT fk_spots_sector FOREIGN KEY (sector_id) REFERENCES sectors(id),
    CONSTRAINT chk_spots_status CHECK (status IN ('FREE', 'OCCUPIED', 'RESERVED'))
);

CREATE TABLE Motorcycles (
    id CHAR(36) PRIMARY KEY,
    model VARCHAR2(100) NOT NULL,
    enginetype VARCHAR2(50) NOT NULL,
    plate VARCHAR2(8) NOT NULL,
    lastrevisiondate DATE NOT NULL,
    spotid CHAR(36) UNIQUE,
    CONSTRAINT fk_motorcycles_spot FOREIGN KEY (spotid) REFERENCES spots(spot_id),
    CONSTRAINT chk_motorcycles_enginetype CHECK (enginetype IN ('COMBUSTION', 'ELECTRIC'))
);

CREATE TABLE logs (
    id CHAR(36) PRIMARY KEY,
    message VARCHAR2(150) NOT NULL,
    created_at DATE NOT NULL,
    motorcycle_id CHAR(36) NOT NULL,
    previous_spot_id CHAR(36) NOT NULL,
    destination_spot_id CHAR(36) NOT NULL,
    CONSTRAINT fk_logs_motorcycle FOREIGN KEY (motorcycle_id) REFERENCES Motorcycles(id),
    CONSTRAINT fk_logs_prev_spot FOREIGN KEY (previous_spot_id) REFERENCES spots(spot_id),
    CONSTRAINT fk_logs_dest_spot FOREIGN KEY (destination_spot_id) REFERENCES spots(spot_id)
);

CREATE TABLE sector_points (
    id CHAR(36) PRIMARY KEY,
    sector_id CHAR(36) NOT NULL,
    point_order NUMBER NOT NULL,
    x NUMBER NOT NULL,
    y NUMBER NOT NULL,
    CONSTRAINT fk_sector_points_sector FOREIGN KEY (sector_id) REFERENCES sectors(id)
);

CREATE TABLE yard_points (
    id CHAR(36) PRIMARY KEY,
    yard_id CHAR(36) NOT NULL,
    point_order NUMBER NOT NULL,
    x NUMBER NOT NULL,
    y NUMBER NOT NULL,
    CONSTRAINT fk_yard_points_yard FOREIGN KEY (yard_id) REFERENCES yards(id)
);


-- INSERTS PARA addresses
INSERT INTO addresses VALUES ('11111111-1111-1111-1111-111111111111', 'Main St', 100, 'Downtown', 'Metropolis', 'StateA', '12345678', 'CountryX');
INSERT INTO addresses VALUES ('22222222-2222-2222-2222-222222222222', 'Second Ave', 200, 'Uptown', 'Gotham', 'StateB', '87654321', 'CountryY');
INSERT INTO addresses VALUES ('33333333-3333-3333-3333-333333333333', 'Third Blvd', 300, 'Midtown', 'Star City', 'StateC', '11223344', 'CountryZ');
INSERT INTO addresses VALUES ('44444444-4444-4444-4444-444444444444', 'Fourth Rd', 400, 'Oldtown', 'Central City', 'StateD', '44332211', 'CountryW');
INSERT INTO addresses VALUES ('55555555-5555-5555-5555-555555555555', 'Fifth Ln', 500, 'Newtown', 'Coast City', 'StateE', '55667788', 'CountryV');

-- INSERTS PARA sector_types
INSERT INTO sector_types VALUES ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Type A');
INSERT INTO sector_types VALUES ('aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Type B');
INSERT INTO sector_types VALUES ('aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Type C');
INSERT INTO sector_types VALUES ('aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Type D');
INSERT INTO sector_types VALUES ('aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Type E');

-- INSERTS PARA yards
INSERT INTO yards VALUES ('yard0001-0000-0000-0000-000000000001', 'Yard One', '11111111-1111-1111-1111-111111111111');
INSERT INTO yards VALUES ('yard0002-0000-0000-0000-000000000002', 'Yard Two', '22222222-2222-2222-2222-222222222222');
INSERT INTO yards VALUES ('yard0003-0000-0000-0000-000000000003', 'Yard Three', '33333333-3333-3333-3333-333333333333');
INSERT INTO yards VALUES ('yard0004-0000-0000-0000-000000000004', 'Yard Four', '44444444-4444-4444-4444-444444444444');
INSERT INTO yards VALUES ('yard0005-0000-0000-0000-000000000005', 'Yard Five', '55555555-5555-5555-5555-555555555555');

-- INSERTS PARA sectors
INSERT INTO sectors VALUES ('sect0001-0000-0000-0000-000000000001', 'yard0001-0000-0000-0000-000000000001', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1');
INSERT INTO sectors VALUES ('sect0002-0000-0000-0000-000000000002', 'yard0002-0000-0000-0000-000000000002', 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2');
INSERT INTO sectors VALUES ('sect0003-0000-0000-0000-000000000003', 'yard0003-0000-0000-0000-000000000003', 'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3');
INSERT INTO sectors VALUES ('sect0004-0000-0000-0000-000000000004', 'yard0004-0000-0000-0000-000000000004', 'aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4');
INSERT INTO sectors VALUES ('sect0005-0000-0000-0000-000000000005', 'yard0005-0000-0000-0000-000000000005', 'aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5');

-- INSERTS PARA spots
INSERT INTO spots VALUES ('spot0001-0000-0000-0000-000000000001', 'sect0001-0000-0000-0000-000000000001', 10, 20, 'FREE', NULL);
INSERT INTO spots VALUES ('spot0001-0000-0000-0000-000000000002', 'sect0001-0000-0000-0000-000000000001', 10, 30, 'FREE', NULL);
INSERT INTO spots VALUES ('spot0002-0000-0000-0000-000000000002', 'sect0002-0000-0000-0000-000000000002', 15, 25, 'OCCUPIED', NULL);
INSERT INTO spots VALUES ('spot0003-0000-0000-0000-000000000003', 'sect0003-0000-0000-0000-000000000003', 20, 30, 'FREE', NULL);
INSERT INTO spots VALUES ('spot0004-0000-0000-0000-000000000004', 'sect0004-0000-0000-0000-000000000004', 25, 35, 'OCCUPIED', NULL);
INSERT INTO spots VALUES ('spot0005-0000-0000-0000-000000000005', 'sect0005-0000-0000-0000-000000000005', 30, 40, 'FREE', NULL);

-- INSERTS PARA Motorcycles
INSERT INTO Motorcycles VALUES ('moto0001-0000-0000-0000-000000000001', 'Model X', 'COMBUSTION', 'ABC1234', TO_DATE('2024-01-01','YYYY-MM-DD'), 'spot0001-0000-0000-0000-000000000001');
INSERT INTO Motorcycles VALUES ('moto0002-0000-0000-0000-000000000002', 'Model Y', 'COMBUSTION', 'DEF5678', TO_DATE('2024-02-01','YYYY-MM-DD'), 'spot0002-0000-0000-0000-000000000002');
INSERT INTO Motorcycles VALUES ('moto0003-0000-0000-0000-000000000003', 'Model Z', 'COMBUSTION', 'GHI9012', TO_DATE('2024-03-01','YYYY-MM-DD'), 'spot0003-0000-0000-0000-000000000003');
INSERT INTO Motorcycles VALUES ('moto0004-0000-0000-0000-000000000004', 'Model W', 'COMBUSTION', 'JKL3456', TO_DATE('2024-04-01','YYYY-MM-DD'), 'spot0004-0000-0000-0000-000000000004');
INSERT INTO Motorcycles VALUES ('moto0005-0000-0000-0000-000000000005', 'Model V', 'ELECTRIC', 'MNO7890', TO_DATE('2024-05-01','YYYY-MM-DD'), 'spot0005-0000-0000-0000-000000000005');
INSERT INTO Motorcycles VALUES ('moto0001-0000-0000-0000-000000000006', 'Model H', 'COMBUSTION', 'ABC1235', TO_DATE('2024-01-01','YYYY-MM-DD'), 'spot0001-0000-0000-0000-000000000002');

-- Atualize os spots para associar as motos
UPDATE spots SET motorcycle_id = 'moto0001-0000-0000-0000-000000000001' WHERE spot_id = 'spot0001-0000-0000-0000-000000000001';
UPDATE spots SET motorcycle_id = 'moto0002-0000-0000-0000-000000000002' WHERE spot_id = 'spot0002-0000-0000-0000-000000000002';
UPDATE spots SET motorcycle_id = 'moto0003-0000-0000-0000-000000000003' WHERE spot_id = 'spot0003-0000-0000-0000-000000000003';
UPDATE spots SET motorcycle_id = 'moto0004-0000-0000-0000-000000000004' WHERE spot_id = 'spot0004-0000-0000-0000-000000000004';
UPDATE spots SET motorcycle_id = 'moto0005-0000-0000-0000-000000000005' WHERE spot_id = 'spot0005-0000-0000-0000-000000000005';
UPDATE spots SET motorcycle_id = 'moto0001-0000-0000-0000-000000000006' WHERE spot_id = 'spot0001-0000-0000-0000-000000000002';

-- INSERTS PARA logs
INSERT INTO logs VALUES ('log0001-0000-0000-0000-000000000001', 'Moved to new spot', TO_DATE('2024-06-01','YYYY-MM-DD'), 'moto0001-0000-0000-0000-000000000001', 'spot0001-0000-0000-0000-000000000001', 'spot0002-0000-0000-0000-000000000002');
INSERT INTO logs VALUES ('log0002-0000-0000-0000-000000000002', 'Routine check', TO_DATE('2024-06-02','YYYY-MM-DD'), 'moto0002-0000-0000-0000-000000000002', 'spot0002-0000-0000-0000-000000000002', 'spot0003-0000-0000-0000-000000000003');
INSERT INTO logs VALUES ('log0003-0000-0000-0000-000000000003', 'Maintenance', TO_DATE('2024-06-03','YYYY-MM-DD'), 'moto0003-0000-0000-0000-000000000003', 'spot0003-0000-0000-0000-000000000003', 'spot0004-0000-0000-0000-000000000004');
INSERT INTO logs VALUES ('log0004-0000-0000-0000-000000000004', 'Inspection', TO_DATE('2024-06-04','YYYY-MM-DD'), 'moto0004-0000-0000-0000-000000000004', 'spot0004-0000-0000-0000-000000000004', 'spot0005-0000-0000-0000-000000000005');
INSERT INTO logs VALUES ('log0005-0000-0000-0000-000000000005', 'Returned', TO_DATE('2024-06-05','YYYY-MM-DD'), 'moto0005-0000-0000-0000-000000000005', 'spot0005-0000-0000-0000-000000000005', 'spot0001-0000-0000-0000-000000000001');

-- INSERTS PARA sector_points
INSERT INTO sector_points VALUES ('spnt0001-0000-0000-0000-000000000001', 'sect0001-0000-0000-0000-000000000001', 1, 10, 20);
INSERT INTO sector_points VALUES ('spnt0002-0000-0000-0000-000000000002', 'sect0002-0000-0000-0000-000000000002', 2, 15, 25);
INSERT INTO sector_points VALUES ('spnt0003-0000-0000-0000-000000000003', 'sect0003-0000-0000-0000-000000000003', 3, 20, 30);
INSERT INTO sector_points VALUES ('spnt0004-0000-0000-0000-000000000004', 'sect0004-0000-0000-0000-000000000004', 4, 25, 35);
INSERT INTO sector_points VALUES ('spnt0005-0000-0000-0000-000000000005', 'sect0005-0000-0000-0000-000000000005', 5, 30, 40);

-- INSERTS PARA yard_points
INSERT INTO yard_points VALUES ('ypnt0001-0000-0000-0000-000000000001', 'yard0001-0000-0000-0000-000000000001', 1, 100, 200);
INSERT INTO yard_points VALUES ('ypnt0002-0000-0000-0000-000000000002', 'yard0002-0000-0000-0000-000000000002', 2, 150, 250);
INSERT INTO yard_points VALUES ('ypnt0003-0000-0000-0000-000000000003', 'yard0003-0000-0000-0000-000000000003', 3, 200, 300);
INSERT INTO yard_points VALUES ('ypnt0004-0000-0000-0000-000000000004', 'yard0004-0000-0000-0000-000000000004', 4, 250, 350);
INSERT INTO yard_points VALUES ('ypnt0005-0000-0000-0000-000000000005', 'yard0005-0000-0000-0000-000000000005', 5, 300, 400);

SET SERVEROUTPUT ON;

--- Função 1: Converte os dados de uma vaga (Spot) em JSON
CREATE OR REPLACE FUNCTION FN_SPOT_PARA_JSON (
    p_spot_id IN CHAR
) RETURN VARCHAR2 IS
    v_spot_id      SPOTS.SPOT_ID%TYPE;
    v_sector_id    SPOTS.SECTOR_ID%TYPE;
    v_status       SPOTS.STATUS%TYPE;
    v_motorcycle_id SPOTS.MOTORCYCLE_ID%TYPE;
    v_json         VARCHAR2(4000);
BEGIN
    -- Busca os dados relacionais da vaga
    SELECT SPOT_ID, SECTOR_ID, STATUS, NVL(MOTORCYCLE_ID, 'NULL')
    INTO v_spot_id, v_sector_id, v_status, v_motorcycle_id
    FROM SPOTS
    WHERE SPOT_ID = p_spot_id;

    -- Monta o JSON manualmente
    v_json := '{' ||
                '"spotId": "' || v_spot_id || '", ' ||
                '"sectorId": "' || v_sector_id || '", ' ||
                '"status": "' || v_status || '", ' ||
                '"motorcycleId": "' || v_motorcycle_id || '"' ||
              '}';

    RETURN v_json;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '{"erro": "Vaga não encontrada."}';
    WHEN TOO_MANY_ROWS THEN
        RETURN '{"erro": "Mais de uma vaga encontrada com o mesmo ID."}';
    WHEN OTHERS THEN
        RETURN '{"erro": "Erro inesperado: ' || SQLERRM || '"}';
END;
/


SELECT FN_SPOT_PARA_JSON('spot0001-0000-0000-0000-000000000001') FROM dual;




-- Função 2: Valida uma placa de moto
CREATE OR REPLACE FUNCTION fn_validate_plate(p_plate IN VARCHAR2) 
RETURN VARCHAR2 IS
BEGIN
  -- Verifica se a placa é nula
  IF p_plate IS NULL THEN
    RAISE NO_DATA_FOUND; -- força uma exceção específica
  END IF;

  -- Verifica tamanho inválido
  IF LENGTH(p_plate) != 7 AND LENGTH(p_plate) != 8 THEN
    RAISE VALUE_ERROR; -- força a exceção
  END IF;

  -- Verifica se corresponde ao padrão AAA0A00 ou AAA0000
  IF REGEXP_LIKE(p_plate, '^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$') 
     OR REGEXP_LIKE(p_plate, '^[A-Z]{3}[0-9]{4}$') THEN
    RETURN 'Placa válida: ' || p_plate;
  ELSE
    RETURN 'Placa inválida: formato não corresponde.';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'Erro: A placa não pode ser nula.';
  WHEN VALUE_ERROR THEN
    RETURN 'Erro: Placa deve ter 7 ou 8 caracteres.';
  WHEN OTHERS THEN
    RETURN 'Erro inesperado: ' || SQLERRM;
END;
/


SELECT fn_validate_plate('ABC1234') FROM dual;



-- Procedure: Retorna todas as vagas (SPOTS) junto com seus setores (SECTORS) em formato JSON
CREATE OR REPLACE PROCEDURE PRC_SPOTS_COM_SECTOR_JSON IS
    CURSOR c_spots IS
        SELECT s.SPOT_ID, s.STATUS, s.X, s.Y, s.MOTORCYCLE_ID,
               sec.ID AS SECTOR_ID, sec.SECTOR_TYPE_ID, sec.YARD_ID
        FROM SPOTS s
        JOIN SECTORS sec ON s.SECTOR_ID = sec.ID;

    v_json   VARCHAR2(32767) := '[';
    v_count  NUMBER := 0;
BEGIN
    FOR rec IN c_spots LOOP
        v_count := v_count + 1;
        
        v_json := v_json || 
            CASE WHEN v_count > 1 THEN ',' ELSE '' END ||
            '{' ||
              '"spotId": "' || rec.SPOT_ID || '", ' ||
              '"status": "' || rec.STATUS || '", ' ||
              '"coords": {"x": ' || rec.X || ', "y": ' || rec.Y || '}, ' ||
              '"motorcycleId": "' || NVL(TO_CHAR(rec.MOTORCYCLE_ID), 'NULL') || '", ' ||
              '"sector": {' ||
                '"id": "' || rec.SECTOR_ID || '", ' ||
                '"typeId": "' || rec.SECTOR_TYPE_ID || '", ' ||
                '"yardId": "' || rec.YARD_ID || '"' ||
              '}' ||
            '}';
    END LOOP;

    v_json := v_json || ']';

    -- Força erro NO_DATA_FOUND se não houver registros
    IF v_count = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_json);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('{"erro": "Nenhum dado encontrado"}');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('{"erro": "Erro de conversão de valor"}');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('{"erro": "Erro inesperado: ' || SQLERRM || '"}');
END;
/


EXEC PRC_SPOTS_COM_SECTOR_JSON;



-- Procedure: Relatório de motos por vaga/setor
-- Mostra todas as vagas com a quantidade de motos e subtotais por setor
CREATE OR REPLACE PROCEDURE relatorio_motos_por_vaga IS

    CURSOR c_spots IS
        SELECT s.id AS sector_id,
               sp.spot_id,
               CASE WHEN m.id IS NOT NULL THEN 1 ELSE 0 END AS num_motos
        FROM sectors s
        JOIN spots sp ON sp.sector_id = s.id
        LEFT JOIN Motorcycles m ON m.spotid = sp.spot_id
        ORDER BY s.id, sp.spot_id;

    v_sector         sectors.id%TYPE;
    v_spot           spots.spot_id%TYPE;
    v_num_motos      NUMBER;

    v_sector_atual   sectors.id%TYPE := NULL;
    v_subtotal       NUMBER := 0;
    v_total_patio    NUMBER := 0;
    v_count          NUMBER := 0; -- contador de registros

BEGIN
    DBMS_OUTPUT.PUT_LINE('SECTOR | SPOT | NUM_MOTOS');

    FOR rec IN c_spots LOOP
        v_count := v_count + 1;

        BEGIN
            v_sector := rec.sector_id;
            v_spot   := rec.spot_id;
            v_num_motos := rec.num_motos;

            -- Se mudou de setor, imprime subtotal do setor anterior
            IF v_sector_atual IS NOT NULL AND v_sector_atual != v_sector THEN
                DBMS_OUTPUT.PUT_LINE(v_sector_atual || ' | SUBTOTAL | ' || v_subtotal);
                v_subtotal := 0; -- reseta subtotal
            END IF;

            -- Exibe linha detalhada por vaga
            DBMS_OUTPUT.PUT_LINE(v_sector || ' | ' || v_spot || ' | ' || v_num_motos);

            -- Acumula subtotal e total geral
            v_subtotal := v_subtotal + v_num_motos;
            v_total_patio := v_total_patio + v_num_motos;

            -- Atualiza setor atual
            v_sector_atual := v_sector;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Erro: registro de vaga ou setor não encontrado');
            WHEN VALUE_ERROR THEN
                DBMS_OUTPUT.PUT_LINE('Erro: valor inválido encontrado em num_motos');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erro desconhecido: ' || SQLERRM);
        END;
    END LOOP;

    -- Se não encontrou nenhum registro, lança NO_DATA_FOUND
    IF v_count = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;

    -- Imprime subtotal do último setor
    IF v_sector_atual IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE(v_sector_atual || ' | SUBTOTAL | ' || v_subtotal);
    END IF;

    -- Imprime total geral do pátio
    DBMS_OUTPUT.PUT_LINE('TOTAL PÁTIO ' || v_total_patio);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro geral: não foram encontrados registros');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Erro geral: valor inválido durante a execução');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro geral desconhecido: ' || SQLERRM);

END relatorio_motos_por_vaga;
/


EXEC relatorio_motos_por_vaga;


-- Trigger de Auditoria: Grava operações (INSERT, UPDATE, DELETE) na tabela Motorcycles
-- Registra o usuário, tipo de operação, data, valores antigos e valores novos
CREATE TABLE audit_motorcycles (
  audit_id NUMBER GENERATED ALWAYS AS IDENTITY,
  username VARCHAR2(100),
  operation VARCHAR2(10),
  operation_date DATE,
  old_values VARCHAR2(4000),
  new_values VARCHAR2(4000)
);

CREATE OR REPLACE TRIGGER trg_motorcycles_audit
AFTER INSERT OR UPDATE OR DELETE ON Motorcycles
FOR EACH ROW
DECLARE
    v_old_values VARCHAR2(4000);
    v_new_values VARCHAR2(4000);
    v_operation  VARCHAR2(10);
BEGIN
    -- Captura valores antigos (para UPDATE ou DELETE)
    IF DELETING OR UPDATING THEN
        v_old_values := 'ID=' || :OLD.id ||
                        ', MODEL=' || :OLD.model ||
                        ', ENGINETYPE=' || :OLD.enginetype ||
                        ', PLATE=' || :OLD.plate ||
                        ', LASTREVISIONDATE=' || TO_CHAR(:OLD.lastrevisiondate, 'DD/MM/YYYY') ||
                        ', SPOTID=' || :OLD.spotid;
    END IF;

    -- Captura valores novos (para INSERT ou UPDATE)
    IF INSERTING OR UPDATING THEN
        v_new_values := 'ID=' || :NEW.id ||
                        ', MODEL=' || :NEW.model ||
                        ', ENGINETYPE=' || :NEW.enginetype ||
                        ', PLATE=' || :NEW.plate ||
                        ', LASTREVISIONDATE=' || TO_CHAR(:NEW.lastrevisiondate, 'DD/MM/YYYY') ||
                        ', SPOTID=' || :NEW.spotid;
    END IF;

    -- Define o tipo de operação
    IF INSERTING THEN
        v_operation := 'INSERT';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
    ELSIF DELETING THEN
        v_operation := 'DELETE';
    END IF;

    -- Insere registro na tabela de auditoria
    INSERT INTO audit_motorcycles (
        username,
        operation,
        operation_date,
        old_values,
        new_values
    ) VALUES (
        USER,
        v_operation,
        SYSDATE,
        v_old_values,
        v_new_values
    );

END;
/



INSERT INTO Motorcycles (id, model, enginetype, plate, lastrevisiondate)
VALUES (
    SYS_GUID(),
    'Honda CG 160',
    'COMBUSTION',
    'ABC1234',
    SYSDATE
);

UPDATE Motorcycles
SET model = 'Honda CG 160 Titan',
    plate = 'XYZ9876'
WHERE plate = 'ABC1234';

SELECT *
FROM audit_motorcycles
ORDER BY audit_id;
