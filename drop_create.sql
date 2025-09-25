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
    CONSTRAINT fk_spots_sector FOREIGN KEY (sector_id) REFERENCES sectors(id)
);

CREATE TABLE Motorcycles (
    id CHAR(36) PRIMARY KEY,
    model VARCHAR2(100) NOT NULL,
    enginetype VARCHAR2(50) NOT NULL,
    plate VARCHAR2(8) NOT NULL,
    lastrevisiondate DATE NOT NULL,
    spotid CHAR(36) NOT NULL UNIQUE,
    CONSTRAINT fk_motorcycles_spot FOREIGN KEY (spotid) REFERENCES spots(spot_id)
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
