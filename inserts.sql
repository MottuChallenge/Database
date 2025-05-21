-- Insert data into address
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
 
 
-- Insert data into branch
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
 
-- Insert data into yard
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
 
-- Insert data into section
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
 
-- Insert data into motorcycle
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
 
-- Insert data into logs
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