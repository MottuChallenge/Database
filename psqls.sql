-- Função 1: Conversão Manual para JSON
CREATE OR REPLACE FUNCTION fn_relational_to_json(
  p_id IN VARCHAR2,
  p_model IN VARCHAR2,
  p_enginetype IN VARCHAR2,
  p_plate IN VARCHAR2,
  p_lastrevisiondate IN DATE
) RETURN VARCHAR2 IS
  v_json VARCHAR2(4000);
BEGIN
  v_json := '{' ||
    '"id":"' || p_id || '",' ||
    '"model":"' || p_model || '",' ||
    '"enginetype":"' || p_enginetype || '",' ||
    '"plate":"' || p_plate || '",' ||
    '"lastrevisiondate":"' || TO_CHAR(p_lastrevisiondate, 'YYYY-MM-DD') || '"' ||
    '}';
  RETURN v_json;
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN '{"error":"VALUE_ERROR"}';
  WHEN OTHERS THEN
    RETURN '{"error":"UNEXPECTED_ERROR"}';
  WHEN NO_DATA_FOUND THEN
    RETURN '{"error":"NO_DATA_FOUND"}';
END;
/

-- Função 2: Validação de Placa de Moto
CREATE OR REPLACE FUNCTION fn_validate_plate(p_plate IN VARCHAR2) RETURN NUMBER IS
BEGIN
  IF LENGTH(p_plate) != 7 AND LENGTH(p_plate) != 8 THEN
    RETURN 0;
  ELSIF REGEXP_LIKE(p_plate, '^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$') THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN -1;
  WHEN OTHERS THEN
    RETURN -2;
  WHEN NO_DATA_FOUND THEN
    RETURN -3;
END;
/

-- Procedimento 1: JOIN + JSON Manual + 3 Exceções
CREATE OR REPLACE PROCEDURE prc_motorcycle_json IS
  CURSOR c IS
    SELECT m.id, m.model, m.enginetype, m.plate, m.lastrevisiondate, s.spot_id, y.name AS yard_name
    FROM Motorcycles m
    JOIN spots s ON m.spotid = s.spot_id
    JOIN sectors sec ON s.sector_id = sec.id
    JOIN yards y ON sec.yard_id = y.id;
  v_json VARCHAR2(4000);
BEGIN
  FOR rec IN c LOOP
    v_json := fn_relational_to_json(rec.id, rec.model, rec.enginetype, rec.plate, rec.lastrevisiondate);
    DBMS_OUTPUT.PUT_LINE('{"motorcycle":' || v_json ||
                         ',"spot":"' || rec.spot_id ||
                         '","yard":"' || rec.yard_name || '"}');
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('{"error":"NO_DATA_FOUND"}');
  WHEN VALUE_ERROR THEN
    DBMS_OUTPUT.PUT_LINE('{"error":"VALUE_ERROR"}');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('{"error":"UNEXPECTED_ERROR"}');
END;
/

-- Procedimento 2: Soma Manual, Subtotal, Total, 3 Exceções
CREATE OR REPLACE PROCEDURE prc_logs_summary IS
  CURSOR c IS
    SELECT l.motorcycle_id, s.sector_id, l.id AS log_id
    FROM logs l
    JOIN spots s ON l.destination_spot_id = s.spot_id
    ORDER BY s.sector_id, l.motorcycle_id;
  v_sector_id VARCHAR2(36);
  v_motorcycle_id VARCHAR2(36);
  v_count NUMBER := 0;
  v_subtotal NUMBER := 0;
  v_total NUMBER := 0;
  v_last_sector VARCHAR2(36) := NULL;
BEGIN
  FOR rec IN c LOOP
    IF v_last_sector IS NULL OR v_last_sector != rec.sector_id THEN
      IF v_last_sector IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Subtotal for sector ' || v_last_sector || ': ' || v_subtotal);
        v_subtotal := 0;
      END IF;
      v_last_sector := rec.sector_id;
    END IF;
    v_count := v_count + 1;
    v_subtotal := v_subtotal + 1;
    v_total := v_total + 1;
    DBMS_OUTPUT.PUT_LINE('Sector: ' || rec.sector_id || ', Motorcycle: ' || rec.motorcycle_id || ', Log: ' || rec.log_id);
  END LOOP;
  IF v_last_sector IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Subtotal for sector ' || v_last_sector || ': ' || v_subtotal);
  END IF;
  DBMS_OUTPUT.PUT_LINE('Total geral: ' || v_total);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND');
  WHEN VALUE_ERROR THEN
    DBMS_OUTPUT.PUT_LINE('VALUE_ERROR');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('UNEXPECTED_ERROR');
END;
/

-- Trigger de Auditoria
CREATE TABLE audit_motorcycles (
  audit_id NUMBER GENERATED ALWAYS AS IDENTITY,
  username VARCHAR2(100),
  operation VARCHAR2(10),
  operation_date DATE,
  old_values VARCHAR2(4000),
  new_values VARCHAR2(4000)
);

CREATE OR REPLACE TRIGGER trg_audit_motorcycles
AFTER INSERT OR UPDATE OR DELETE ON Motorcycles
FOR EACH ROW
DECLARE
  v_user VARCHAR2(100);
BEGIN
  v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
  INSERT INTO audit_motorcycles (
    username, operation, operation_date, old_values, new_values
  ) VALUES (
    v_user,
    CASE
      WHEN INSERTING THEN 'INSERT'
      WHEN UPDATING THEN 'UPDATE'
      WHEN DELETING THEN 'DELETE'
    END,
    SYSDATE,
    CASE WHEN DELETING OR UPDATING THEN
      '{' ||
      '"id":"' || :OLD.id || '",' ||
      '"model":"' || :OLD.model || '",' ||
      '"enginetype":"' || :OLD.enginetype || '",' ||
      '"plate":"' || :OLD.plate || '",' ||
      '"lastrevisiondate":"' || TO_CHAR(:OLD.lastrevisiondate, 'YYYY-MM-DD') || '"' ||
      '}'
    ELSE NULL END,
    CASE WHEN INSERTING OR UPDATING THEN
      '{' ||
      '"id":"' || :NEW.id || '",' ||
      '"model":"' || :NEW.model || '",' ||
      '"enginetype":"' || :NEW.enginetype || '",' ||
      '"plate":"' || :NEW.plate || '",' ||
      '"lastrevisiondate":"' || TO_CHAR(:NEW.lastrevisiondate, 'YYYY-MM-DD') || '"' ||
      '}'
    ELSE NULL END
  );
END;
/