SET SERVEROUTPUT ON;

-- Função 1: Converter Dados de uma Vaga (Spot) em JSON
CREATE OR REPLACE FUNCTION FN_SPOT_PARA_JSON (
    p_spot_id IN CHAR
) RETURN VARCHAR2 IS
    v_spot_id      SPOTS.SPOT_ID%TYPE;
    v_sector_id    SPOTS.SECTOR_ID%TYPE;
    v_status       SPOTS.STATUS%TYPE;
    v_motorcycle_id SPOTS.MOTORCYCLE_ID%TYPE;
    v_json         VARCHAR2(4000);
BEGIN
    -- Busca os dados relacionais
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


-- Execução normal
SELECT FN_SPOT_PARA_JSON('spot0001-0000-0000-0000-000000000001') FROM dual;

-- Execução com exceção NO_DATA_FOUND
SELECT FN_SPOT_PARA_JSON('id_inexistente') FROM dual;


-- Função 2: Validação de Placa de Moto
CREATE OR REPLACE FUNCTION fn_validate_plate(p_plate IN VARCHAR2) 
RETURN VARCHAR2 IS
BEGIN
  -- Verifica se a placa é nula
  IF p_plate IS NULL THEN
    RAISE NO_DATA_FOUND; -- força uma exception específica
  END IF;

  -- Verifica tamanho inválido
  IF LENGTH(p_plate) != 7 AND LENGTH(p_plate) != 8 THEN
    RAISE VALUE_ERROR; -- força a exception
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

-- Execução normal
SELECT fn_validate_plate('ABC1234') FROM dual;

-- Execução com exceção VALUE_ERROR
SELECT fn_validate_plate('ABC') FROM dual;


-- Esse pega as vagas (SPOTS) junto com os setores (SECTORS) e retorna tudo em formato JSON.
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

    -- Força NO_DATA_FOUND se não houver registros
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

-- Execução normal
EXEC PRC_SPOTS_COM_SECTOR_JSON;

-- Execução com exceção forçada
DELETE FROM LOGS;
COMMIT;

DELETE FROM Motorcycles;
COMMIT;

DELETE FROM Spots;
COMMIT;

EXEC PRC_SPOTS_COM_SECTOR_JSON;


-- Procedimento 2: A procedure contagem_motos_setor tem como objetivo gerar um relatório manual de contagem de motos por setor dentro do pátio, exibindo também o total geral de motos no pátio.
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
    DBMS_OUTPUT.PUT_LINE('TOTAL PATIO ' || v_total_patio);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro geral: não foram encontrados registros');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Erro geral: valor inválido durante a execução');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro geral desconhecido: ' || SQLERRM);

END relatorio_motos_por_vaga;
/

-- Execução normal
EXEC relatorio_motos_por_vaga;

-- Execução com exceção forçada
DELETE FROM SECTORS;
COMMIT;

EXEC relatorio_motos_por_vaga;


-- Trigger de Auditoria
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

    -- Inserção na tabela de auditoria
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


-- Execução normal (INSERT + UPDATE)
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
