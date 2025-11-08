-- ==============================
-- PACKAGE: pkg_spots
-- ==============================
CREATE OR REPLACE PACKAGE pkg_spots AS
  FUNCTION fn_spot_para_json(p_spot_id IN CHAR) RETURN VARCHAR2;
  PROCEDURE prc_spots_com_sector_json;
  PROCEDURE relatorio_motos_por_vaga;
END pkg_spots;
/

CREATE OR REPLACE PACKAGE BODY pkg_spots AS

  -- Função que retorna uma vaga em formato JSON
  FUNCTION fn_spot_para_json(p_spot_id IN CHAR) RETURN VARCHAR2 IS
      v_spot_id       SPOTS.SPOT_ID%TYPE;
      v_sector_id     SPOTS.SECTOR_ID%TYPE;
      v_status        SPOTS.STATUS%TYPE;
      v_motorcycle_id SPOTS.MOTORCYCLE_ID%TYPE;
      v_json          VARCHAR2(4000);
  BEGIN
      SELECT SPOT_ID, SECTOR_ID, STATUS, NVL(MOTORCYCLE_ID, 'NULL')
      INTO v_spot_id, v_sector_id, v_status, v_motorcycle_id
      FROM SPOTS
      WHERE SPOT_ID = p_spot_id;

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
  END fn_spot_para_json;


  -- Procedure que retorna todas as vagas com seus setores em JSON
  PROCEDURE prc_spots_com_sector_json IS
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
  END prc_spots_com_sector_json;


  -- Procedure que gera relatório de motos por vaga
  PROCEDURE relatorio_motos_por_vaga IS
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
      v_count          NUMBER := 0;
  BEGIN
      DBMS_OUTPUT.PUT_LINE('SECTOR | SPOT | NUM_MOTOS');
      FOR rec IN c_spots LOOP
          v_count := v_count + 1;
          v_sector := rec.sector_id;
          v_spot   := rec.spot_id;
          v_num_motos := rec.num_motos;

          IF v_sector_atual IS NOT NULL AND v_sector_atual != v_sector THEN
              DBMS_OUTPUT.PUT_LINE(v_sector_atual || ' | SUBTOTAL | ' || v_subtotal);
              v_subtotal := 0;
          END IF;

          DBMS_OUTPUT.PUT_LINE(v_sector || ' | ' || v_spot || ' | ' || v_num_motos);

          v_subtotal := v_subtotal + v_num_motos;
          v_total_patio := v_total_patio + v_num_motos;
          v_sector_atual := v_sector;
      END LOOP;

      IF v_count = 0 THEN
          RAISE NO_DATA_FOUND;
      END IF;

      IF v_sector_atual IS NOT NULL THEN
          DBMS_OUTPUT.PUT_LINE(v_sector_atual || ' | SUBTOTAL | ' || v_subtotal);
      END IF;

      DBMS_OUTPUT.PUT_LINE('TOTAL PATIO ' || v_total_patio);
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('Erro: nenhum registro encontrado');
      WHEN VALUE_ERROR THEN
          DBMS_OUTPUT.PUT_LINE('Erro: valor inválido encontrado');
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro geral: ' || SQLERRM);
  END relatorio_motos_por_vaga;

END pkg_spots;
/

-- ==============================
-- TESTES: pkg_spots
-- ==============================
SET SERVEROUTPUT ON;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Teste fn_spot_para_json ---');
  DBMS_OUTPUT.PUT_LINE(pkg_spots.fn_spot_para_json('SPOT001'));

  DBMS_OUTPUT.PUT_LINE('--- Teste prc_spots_com_sector_json ---');
  pkg_spots.prc_spots_com_sector_json;

  DBMS_OUTPUT.PUT_LINE('--- Teste relatorio_motos_por_vaga ---');
  pkg_spots.relatorio_motos_por_vaga;
END;
/

-- ==============================
-- PACKAGE: pkg_utils
-- ==============================
CREATE OR REPLACE PACKAGE pkg_utils AS
  FUNCTION fn_validate_plate(p_plate IN VARCHAR2) RETURN VARCHAR2;
END pkg_utils;
/

CREATE OR REPLACE PACKAGE BODY pkg_utils AS
  FUNCTION fn_validate_plate(p_plate IN VARCHAR2) RETURN VARCHAR2 IS
    e_plate_null EXCEPTION;
    e_invalid_length EXCEPTION;
    e_invalid_format EXCEPTION;
  BEGIN
    IF p_plate IS NULL THEN
      RAISE e_plate_null;
    END IF;

    IF LENGTH(p_plate) NOT IN (7, 8) THEN
      RAISE e_invalid_length;
    END IF;

    IF NOT (REGEXP_LIKE(p_plate, '^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$')
         OR REGEXP_LIKE(p_plate, '^[A-Z]{3}[0-9]{4}$')) THEN
      RAISE e_invalid_format;
    END IF;

    RETURN 'Placa válida: ' || p_plate;

  EXCEPTION
    WHEN e_plate_null THEN
      RETURN 'Erro: A placa não pode ser nula.';
    WHEN e_invalid_length THEN
      RETURN 'Erro: Placa deve ter 7 ou 8 caracteres.';
    WHEN e_invalid_format THEN
      RETURN 'Erro: Placa inválida — formato incorreto.';
    WHEN OTHERS THEN
      RETURN 'Erro inesperado: ' || SQLERRM;
  END fn_validate_plate;
END pkg_utils;
/

-- ==============================
-- TESTES: pkg_utils
-- ==============================
SET SERVEROUTPUT ON;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Teste fn_validate_plate ---');
  DBMS_OUTPUT.PUT_LINE(pkg_utils.fn_validate_plate('ABC1234'));
  DBMS_OUTPUT.PUT_LINE(pkg_utils.fn_validate_plate('ABC1D23'));
  DBMS_OUTPUT.PUT_LINE(pkg_utils.fn_validate_plate('1234567'));
  DBMS_OUTPUT.PUT_LINE(pkg_utils.fn_validate_plate(NULL));
END;
/

-- ==============================
-- PACKAGE: pkg_auditoria
-- ==============================
CREATE OR REPLACE PACKAGE pkg_auditoria AS
  PROCEDURE registrar_auditoria(
    p_old_values IN VARCHAR2,
    p_new_values IN VARCHAR2,
    p_operation  IN VARCHAR2
  );
END pkg_auditoria;
/

CREATE OR REPLACE PACKAGE BODY pkg_auditoria AS
  PROCEDURE registrar_auditoria(
    p_old_values IN VARCHAR2,
    p_new_values IN VARCHAR2,
    p_operation  IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO audit_motorcycles (
      username,
      operation,
      operation_date,
      old_values,
      new_values
    ) VALUES (
      USER,
      p_operation,
      SYSDATE,
      p_old_values,
      p_new_values
    );
  END registrar_auditoria;
END pkg_auditoria;
/

-- ==============================
-- TRIGGER: auditoria de motocicletas
-- ==============================
CREATE OR REPLACE TRIGGER trg_motorcycles_audit
AFTER INSERT OR UPDATE OR DELETE ON Motorcycles
FOR EACH ROW
DECLARE
  v_old_values VARCHAR2(4000);
  v_new_values VARCHAR2(4000);
  v_operation  VARCHAR2(10);
BEGIN
  IF DELETING OR UPDATING THEN
    v_old_values := 'ID=' || :OLD.id || ', MODEL=' || :OLD.model || ', PLATE=' || :OLD.plate;
  END IF;

  IF INSERTING OR UPDATING THEN
    v_new_values := 'ID=' || :NEW.id || ', MODEL=' || :NEW.model || ', PLATE=' || :NEW.plate;
  END IF;

  IF INSERTING THEN
    v_operation := 'INSERT';
  ELSIF UPDATING THEN
    v_operation := 'UPDATE';
  ELSE
    v_operation := 'DELETE';
  END IF;

  pkg_auditoria.registrar_auditoria(v_old_values, v_new_values, v_operation);
END;
/

