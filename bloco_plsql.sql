SET SERVEROUTPUT ON;

-- 1. Motores por tipo, ano de revisão, setor e pátio (3 JOINs)
BEGIN
  FOR rec IN (
    SELECT 
      m.enginetype,
      EXTRACT(YEAR FROM m.lastrevisiondate) AS revision_year,
      st.name AS sector_type,
      y.name AS yard_name,
      COUNT(*) AS total_motorcycles
    FROM Motorcycles m
    JOIN spots s ON m.spotid = s.spot_id
    JOIN sectors sec ON s.sector_id = sec.id
    JOIN sector_types st ON sec.sector_type_id = st.id
    JOIN yards y ON sec.yard_id = y.id
    GROUP BY m.enginetype, EXTRACT(YEAR FROM m.lastrevisiondate), st.name, y.name
    ORDER BY revision_year DESC, total_motorcycles DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Engine Type: ' || rec.enginetype || 
                         ', Revision Year: ' || rec.revision_year ||
                         ', Sector Type: ' || rec.sector_type ||
                         ', Yard: ' || rec.yard_name ||
                         ', Total: ' || rec.total_motorcycles);
  END LOOP;
END;
/

-- 2. Pátios, total de setores, área total dos setores, tipo de setor e cidade (3 JOINs)
BEGIN
  FOR rec IN (
    SELECT 
      y.name AS yard_name,
      COUNT(sec.id) AS total_sectors,
      st.name AS sector_type,
      a.city AS city,
      COUNT(s.spot_id) AS total_spots
    FROM yards y
    JOIN addresses a ON y.address_id = a.id
    JOIN sectors sec ON sec.yard_id = y.id
    JOIN sector_types st ON sec.sector_type_id = st.id
    JOIN spots s ON s.sector_id = sec.id
    GROUP BY y.name, st.name, a.city
    ORDER BY total_spots DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Yard: ' || rec.yard_name || 
                         ', Sectors: ' || rec.total_sectors ||
                         ', Sector Type: ' || rec.sector_type ||
                         ', City: ' || rec.city ||
                         ', Total Spots: ' || rec.total_spots);
  END LOOP;
END;
/

-- 3. Cidades, total de pátios, total de setores, total de motos (3 JOINs)
BEGIN
  FOR rec IN (
    SELECT 
      a.city,
      COUNT(DISTINCT y.id) AS total_yards,
      COUNT(DISTINCT sec.id) AS total_sectors,
      COUNT(DISTINCT m.id) AS total_motorcycles
    FROM addresses a
    JOIN yards y ON y.address_id = a.id
    JOIN sectors sec ON sec.yard_id = y.id
    JOIN spots s ON s.sector_id = sec.id
    LEFT JOIN Motorcycles m ON m.spotid = s.spot_id
    GROUP BY a.city
    ORDER BY total_motorcycles DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('City: ' || rec.city ||
                         ', Yards: ' || rec.total_yards ||
                         ', Sectors: ' || rec.total_sectors ||
                         ', Motorcycles: ' || rec.total_motorcycles);
  END LOOP;
END;
/

-- 4. Exibir setores, tipo, pátio, área anterior, atual e próxima (3 JOINs)
DECLARE
  CURSOR c_sectors IS
    SELECT 
      sec.id AS sector_id,
      sec_type.name AS sector_type,
      y.name AS yard_name,
      sec.id AS sector_id_repeat,  -- Alias para a segunda coluna sec.id
      sec_type.name AS sector_type_repeat, -- Alias para a segunda coluna sec_type.name
      y.name AS yard_name_repeat  -- Alias para a segunda coluna y.name
    FROM sectors sec
    JOIN sector_types sec_type ON sec.sector_type_id = sec_type.id
    JOIN yards y ON sec.yard_id = y.id
    ORDER BY sec.id;

  TYPE id_table IS TABLE OF sectors.id%TYPE INDEX BY PLS_INTEGER;
  TYPE type_table IS TABLE OF sector_types.name%TYPE INDEX BY PLS_INTEGER;
  TYPE yard_table IS TABLE OF yards.name%TYPE INDEX BY PLS_INTEGER;

  ids        id_table;
  types      type_table;
  yards_arr  yard_table;
  total      INTEGER := 0;

  v_prev_id  sectors.id%TYPE;
  v_next_id  sectors.id%TYPE;
BEGIN
  -- Carrega os dados ordenados no array
  FOR rec IN c_sectors LOOP
    total := total + 1;
    ids(total) := rec.sector_id;
    types(total) := rec.sector_type;
    yards_arr(total) := rec.yard_name;
  END LOOP;

  -- Cabeçalho
  DBMS_OUTPUT.PUT_LINE(RPAD('Setor', 38) || RPAD('Anterior', 38) || RPAD('Atual', 38) || RPAD('Próximo', 38) || RPAD('Tipo', 12) || 'Pátio');

  FOR i IN 1..total LOOP
    -- Anterior
    IF i = 1 THEN
      v_prev_id := NULL;
    ELSE
      v_prev_id := ids(i - 1);
    END IF;

    -- Próximo
    IF i = total THEN
      v_next_id := NULL;
    ELSE
      v_next_id := ids(i + 1);
    END IF;

    DBMS_OUTPUT.PUT_LINE(
      RPAD(ids(i), 38) ||
      RPAD(NVL(v_prev_id, 'Vazio'), 38) ||
      RPAD(ids(i), 38) ||
      RPAD(NVL(v_next_id, 'Vazio'), 38) ||
      RPAD(types(i), 12) ||
      yards_arr(i)
    );
  END LOOP;
END;
/