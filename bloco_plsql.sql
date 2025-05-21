SET SERVEROUTPUT ON;

DECLARE
  CURSOR c_sections IS
    SELECT color, area
    FROM section
    ORDER BY area;

  v_color     section.color%TYPE;
  v_area      section.area%TYPE;
  v_prev_area section.area%TYPE;
  v_next_area section.area%TYPE;

  TYPE area_table IS TABLE OF section.area%TYPE INDEX BY PLS_INTEGER;
  TYPE color_table IS TABLE OF section.color%TYPE INDEX BY PLS_INTEGER;

  areas  area_table;
  colors color_table;
  total  INTEGER := 0;
BEGIN
  -- Carrega os dados ordenados no array
  FOR rec IN c_sections LOOP
    total := total + 1;
    areas(total) := rec.area;
    colors(total) := rec.color;
  END LOOP;

  -- Exibe a tabela conforme solicitado
  DBMS_OUTPUT.PUT_LINE(RPAD('Color', 12) || RPAD('Anterior', 12) || RPAD('Atual', 12) || 'Próximo');

  FOR i IN 1..total LOOP
    v_color := colors(i);
    v_area  := areas(i);

    -- Verifica anterior
    IF i = 1 THEN
      v_prev_area := NULL;
    ELSE
      v_prev_area := areas(i - 1);
    END IF;

    -- Verifica próximo
    IF i = total THEN
      v_next_area := NULL;
    ELSE
      v_next_area := areas(i + 1);
    END IF;

    DBMS_OUTPUT.PUT_LINE(
      RPAD(v_color, 12) ||
      RPAD(NVL(TO_CHAR(v_prev_area), 'Vazio'), 12) ||
      RPAD(TO_CHAR(v_area), 12) ||
      NVL(TO_CHAR(v_next_area), 'Vazio')
    );
  END LOOP;
END;
/
