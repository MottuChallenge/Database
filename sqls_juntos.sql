DROP TABLE logs CASCADE CONSTRAINTS;
DROP TABLE motorcycle CASCADE CONSTRAINTS;
DROP TABLE section CASCADE CONSTRAINTS;
DROP TABLE yard CASCADE CONSTRAINTS;
DROP TABLE branch CASCADE CONSTRAINTS;
DROP TABLE address CASCADE CONSTRAINTS;

CREATE TABLE address (
    id           RAW(16) NOT NULL,
    street       VARCHAR2(100) NOT NULL,
    "number"     VARCHAR2(7) NOT NULL,
    neighborhood VARCHAR2(100) NOT NULL,
    city         VARCHAR2(100) NOT NULL,
    state        VARCHAR2(100) NOT NULL,
    postal_code  VARCHAR2(20) NOT NULL,
    country      VARCHAR2(50) NOT NULL
);

ALTER TABLE address ADD CONSTRAINT address_pk PRIMARY KEY (id);

-- Inserts
INSERT INTO address (id, street, "number", neighborhood, city, state, postal_code, country)
VALUES (SYS_GUID(), 'Avenida Paulista', '123', 'Bela Vista', 'São Paulo', 'SP', '01311-000', 'Brazil');

INSERT INTO address (id, street, "number", neighborhood, city, state, postal_code, country)
VALUES (SYS_GUID(), 'Rua Augusta', '456', 'Consolação', 'São Paulo', 'SP', '01305-000', 'Brazil');

INSERT INTO address (id, street, "number", neighborhood, city, state, postal_code, country)
VALUES (SYS_GUID(), 'Rua Oscar Freire', '789', 'Jardins', 'São Paulo', 'SP', '01426-001', 'Brazil');

INSERT INTO address (id, street, "number", neighborhood, city, state, postal_code, country)
VALUES (SYS_GUID(), 'Avenida Brigadeiro Faria Lima', '101', 'Itaim Bibi', 'São Paulo', 'SP', '01452-911', 'Brazil');

INSERT INTO address (id, street, "number", neighborhood, city, state, postal_code, country)
VALUES (SYS_GUID(), 'Avenida Ibirapuera', '202', 'Moema', 'São Paulo', 'SP', '04029-200', 'Brazil');


CREATE TABLE branch (
    id         RAW(16) NOT NULL,
    name       VARCHAR2(100) NOT NULL,
    phone      VARCHAR2(20) NOT NULL,
    email      VARCHAR2(100) NOT NULL,
    cnpj       VARCHAR2(14) NOT NULL,
    address_id RAW(16) NOT NULL
);

ALTER TABLE branch ADD CONSTRAINT branch_pk PRIMARY KEY (id);
CREATE UNIQUE INDEX branch__idx ON branch (address_id ASC);

ALTER TABLE branch ADD CONSTRAINT branch_address_fk FOREIGN KEY (address_id) REFERENCES address(id);

-- Inserts
INSERT INTO branch (id, name, phone, email, cnpj, address_id)
VALUES (SYS_GUID(), 'Motos SP', '11987654321', 'contato@motossp.com', '12345678901234', (SELECT id FROM address WHERE street = 'Avenida Paulista'));

INSERT INTO branch (id, name, phone, email, cnpj, address_id)
VALUES (SYS_GUID(), 'Moto Clube', '11912345678', 'contato@motoclube.com', '23456789012345', (SELECT id FROM address WHERE street = 'Rua Augusta'));

INSERT INTO branch (id, name, phone, email, cnpj, address_id)
VALUES (SYS_GUID(), 'Speed Motors', '11955556666', 'contato@speedmotors.com', '34567890123456', (SELECT id FROM address WHERE street = 'Rua Oscar Freire'));

INSERT INTO branch (id, name, phone, email, cnpj, address_id)
VALUES (SYS_GUID(), 'Veloz Motos', '11944443333', 'contato@velozmotos.com', '45678901234567', (SELECT id FROM address WHERE street = 'Avenida Brigadeiro Faria Lima'));

INSERT INTO branch (id, name, phone, email, cnpj, address_id)
VALUES (SYS_GUID(), 'Moto Express', '11999998888', 'contato@motoexpress.com', '56789012345678', (SELECT id FROM address WHERE street = 'Avenida Ibirapuera'));


CREATE TABLE yard (
    id         RAW(16) NOT NULL,
    branch_id  RAW(16) NOT NULL,
    name       VARCHAR2(100) NOT NULL,
    address_id RAW(16) NOT NULL,
    area       NUMBER(10, 2) NOT NULL
);

ALTER TABLE yard ADD CONSTRAINT yard_pk PRIMARY KEY (id);
CREATE UNIQUE INDEX yard__idx ON yard (address_id ASC);

ALTER TABLE yard ADD CONSTRAINT yard_branch_fk FOREIGN KEY (branch_id) REFERENCES branch(id);
ALTER TABLE yard ADD CONSTRAINT yard_address_fk FOREIGN KEY (address_id) REFERENCES address(id);

-- Inserts
INSERT INTO yard (id, branch_id, name, address_id, area)
VALUES (SYS_GUID(), (SELECT id FROM branch WHERE name = 'Motos SP'), 'Central Yard', (SELECT id FROM address WHERE street = 'Avenida Paulista'), 100.0);

INSERT INTO yard (id, branch_id, name, address_id, area)
VALUES (SYS_GUID(), (SELECT id FROM branch WHERE name = 'Moto Clube'), 'East Yard', (SELECT id FROM address WHERE street = 'Rua Augusta'), 120.5);

INSERT INTO yard (id, branch_id, name, address_id, area)
VALUES (SYS_GUID(), (SELECT id FROM branch WHERE name = 'Speed Motors'), 'West Yard', (SELECT id FROM address WHERE street = 'Rua Oscar Freire'), 90.2);

INSERT INTO yard (id, branch_id, name, address_id, area)
VALUES (SYS_GUID(), (SELECT id FROM branch WHERE name = 'Veloz Motos'), 'South Yard', (SELECT id FROM address WHERE street = 'Avenida Brigadeiro Faria Lima'), 140.8);

INSERT INTO yard (id, branch_id, name, address_id, area)
VALUES (SYS_GUID(), (SELECT id FROM branch WHERE name = 'Moto Express'), 'North Yard', (SELECT id FROM address WHERE street = 'Avenida Ibirapuera'), 110.70);


CREATE TABLE section (
    id      RAW(16) NOT NULL,
    color   CHAR(50) NOT NULL,
    area    NUMBER(10, 2) NOT NULL,
    yard_id RAW(16) NOT NULL
);

ALTER TABLE section ADD CONSTRAINT section_pk PRIMARY KEY (id);
ALTER TABLE section ADD CONSTRAINT section_yard_fk FOREIGN KEY (yard_id) REFERENCES yard(id);

-- Inserts
INSERT INTO section (id, color, area, yard_id)
VALUES (SYS_GUID(), 'Red', 50.5, (SELECT id FROM yard WHERE name = 'Central Yard'));

INSERT INTO section (id, color, area, yard_id)
VALUES (SYS_GUID(), 'Blue', 60.0, (SELECT id FROM yard WHERE name = 'East Yard'));

INSERT INTO section (id, color, area, yard_id)
VALUES (SYS_GUID(), 'Green', 45.7, (SELECT id FROM yard WHERE name = 'West Yard'));

INSERT INTO section (id, color, area, yard_id)
VALUES (SYS_GUID(), 'Black', 80.3, (SELECT id FROM yard WHERE name = 'South Yard'));

INSERT INTO section (id, color, area, yard_id)
VALUES (SYS_GUID(), 'White', 92.1, (SELECT id FROM yard WHERE name = 'North Yard'));


CREATE TABLE motorcycle (
    id                 RAW(16) NOT NULL,
    model              VARCHAR2(50) NOT NULL,
    engine_type        VARCHAR2(50) NOT NULL,
    plate              CHAR(10) NOT NULL,
    last_revision_date DATE NOT NULL,
    section_id         RAW(16) NOT NULL
);

ALTER TABLE motorcycle ADD CONSTRAINT motorcycle_pk PRIMARY KEY (id);
ALTER TABLE motorcycle ADD CONSTRAINT motorcycle_section_fk FOREIGN KEY (section_id) REFERENCES section(id);

-- Inserts
INSERT INTO motorcycle (id, model, engine_type, plate, last_revision_date, section_id)
VALUES (SYS_GUID(), 'Honda CB500F', 'DOHC', 'ABC-1234', TO_DATE('2025-01-15', 'YYYY-MM-DD'), (SELECT id FROM section WHERE color = 'Red'));

INSERT INTO motorcycle (id, model, engine_type, plate, last_revision_date, section_id)
VALUES (SYS_GUID(), 'Yamaha MT-03', 'DOHC', 'XYZ-5678', TO_DATE('2025-02-10', 'YYYY-MM-DD'), (SELECT id FROM section WHERE color = 'Blue'));

INSERT INTO motorcycle (id, model, engine_type, plate, last_revision_date, section_id)
VALUES (SYS_GUID(), 'Kawasaki Z400', 'DOHC', 'LMN-3456', TO_DATE('2025-03-20', 'YYYY-MM-DD'), (SELECT id FROM section WHERE color = 'Green'));

INSERT INTO motorcycle (id, model, engine_type, plate, last_revision_date, section_id)
VALUES (SYS_GUID(), 'Suzuki GSX-S750', 'DOHC', 'PQR-6789', TO_DATE('2025-04-05', 'YYYY-MM-DD'), (SELECT id FROM section WHERE color = 'Black'));

INSERT INTO motorcycle (id, model, engine_type, plate, last_revision_date, section_id)
VALUES (SYS_GUID(), 'Ducati Monster 797', 'L-Twin', 'STU-9012', TO_DATE('2025-05-10', 'YYYY-MM-DD'), (SELECT id FROM section WHERE color = 'White'));


CREATE TABLE logs (
    id            RAW(16) NOT NULL,
    motorcycle_id RAW(16) NOT NULL,
    mensage       VARCHAR2(150) NOT NULL,
    created_at    DATE NOT NULL
);

ALTER TABLE logs ADD CONSTRAINT logs_pk PRIMARY KEY (id, motorcycle_id);
ALTER TABLE logs ADD CONSTRAINT logs_motorcycle_fk FOREIGN KEY (motorcycle_id) REFERENCES motorcycle(id);

-- Inserts
INSERT INTO logs (id, motorcycle_id, mensage, created_at)
VALUES (SYS_GUID(), (SELECT id FROM motorcycle WHERE plate = 'ABC-1234'), 'Revisão realizada com sucesso', SYSDATE);

INSERT INTO logs (id, motorcycle_id, mensage, created_at)
VALUES (SYS_GUID(), (SELECT id FROM motorcycle WHERE plate = 'XYZ-5678'), 'Troca de óleo efetuada', SYSDATE - 10);

INSERT INTO logs (id, motorcycle_id, mensage, created_at)
VALUES (SYS_GUID(), (SELECT id FROM motorcycle WHERE plate = 'LMN-3456'), 'Pneu traseiro substituído', SYSDATE - 20);

INSERT INTO logs (id, motorcycle_id, mensage, created_at)
VALUES (SYS_GUID(), (SELECT id FROM motorcycle WHERE plate = 'PQR-6789'), 'Lavagem e lubrificação', SYSDATE - 30);

INSERT INTO logs (id, motorcycle_id, mensage, created_at)
VALUES (SYS_GUID(), (SELECT id FROM motorcycle WHERE plate = 'STU-9012'), 'Inspeção de freios realizada', SYSDATE - 40);


SET SERVEROUTPUT ON;

BEGIN
  FOR rec IN (
    SELECT 
      m.engine_type,
      EXTRACT(YEAR FROM m.last_revision_date) AS revision_year,
      COUNT(*) AS total_motorcycles
    FROM motorcycle m
    GROUP BY m.engine_type, EXTRACT(YEAR FROM m.last_revision_date)
    ORDER BY revision_year DESC, total_motorcycles DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Engine Type: ' || rec.engine_type || 
                         ', Revision Year: ' || rec.revision_year || 
                         ', Total: ' || rec.total_motorcycles);
  END LOOP;
END;

BEGIN
  FOR rec IN (
    SELECT 
      y.name AS yard_name,
      COUNT(s.id) AS total_sections,
      SUM(s.area) AS total_section_area
    FROM yard y
    JOIN section s ON s.yard_id = y.id
    GROUP BY y.name
    ORDER BY total_section_area DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Yard: ' || rec.yard_name || 
                         ', Sections: ' || rec.total_sections || 
                         ', Total Area: ' || rec.total_section_area);
  END LOOP;
END;

BEGIN
  FOR rec IN (
    SELECT 
      b.name AS branch_name,
      COUNT(y.id) AS total_yards,
      SUM(y.area) AS total_area
    FROM branch b
    JOIN yard y ON y.branch_id = b.id
    GROUP BY b.name
    ORDER BY total_yards DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Branch: ' || rec.branch_name ||
                         ', Yards: ' || rec.total_yards ||
                         ', Total Area: ' || rec.total_area);
  END LOOP;
END;

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

