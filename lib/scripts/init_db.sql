CREATE TABLE user(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    password VARCHAR NOT NULL
);

INSERT INTO user(name, email, password) VALUES('Teste 1', 'teste1@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 2', 'teste2@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 3', 'teste3@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 4', 'teste4@teste', '123456');
INSERT INTO user(name, email, password) VALUES('Teste 5', 'teste5@teste', '123456');

CREATE TABLE address(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cep VARCHAR NOT NULL UNIQUE,
    logradouro VARCHAR NOT NULL,
    bairro VARCHAR NOT NULL,
    localidade VARCHAR NOT NULL,
    uf VARCHAR NOT NULL,
    estado VARCHAR NOT NULL
);

INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('01001000', 'Praça da Sé', 'Sé', 'São Paulo', 'SP', 'São Paulo');
INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('24210346', 'Avenida General Milton Tavares de Souza', 'Gragoatá', 'Niterói', 'RJ', 'Rio de Janeiro');

CREATE TABLE property(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
	address_id INTEGER NOT NULL,
    title VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
	number INTEGER NOT NULL,
    complement VARCHAR,
    price REAL NOT NULL,
    max_guest INTEGER NOT NULL,
    thumbnail VARCHAR NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(id),
	FOREIGN KEY(address_id) REFERENCES address(id)
);

INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Apartamento Quarto Privativo', 'Apartamento perto do Centro com 2 quartos, cozinha e lavanderia.', 100, 'Apto 305', 120.0, 2, 'image_path');
INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Hotel Ibis', 'Quarto Básico com cama casal.', 200, NULL, 220.0, 2, 'image_path');
INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Pousada X', 'Quarto Básico com cama casal e cama de solteiro.', 300, NULL, 320.0, 3, 'image_path');
INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Chalé perto de praia', 'Quarto com cama casal.', 400, NULL, 420.0, 2, 'image_path');


CREATE TABLE images(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    property_id INTEGER NOT NULL,
    path VARCHAR NOT NULL,    
	FOREIGN KEY(property_id) REFERENCES property(id)
);

INSERT INTO images(property_id, path) VALUES(1, 'image_path_1' );
INSERT INTO images(property_id, path) VALUES(1, 'image_path_2' );
INSERT INTO images(property_id, path) VALUES(1, 'image_path_3' );
INSERT INTO images(property_id, path) VALUES(2, 'image_path_1' );
INSERT INTO images(property_id, path) VALUES(2, 'image_path_2' );
INSERT INTO images(property_id, path) VALUES(2, 'image_path_3' );

CREATE TABLE booking(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	user_id INTEGER NOT NULL,
	property_id INTEGER NOT NULL,
    checkin_date VARCHAR NOT NULL,
	checkout_date VARCHAR NOT NULL,
    total_days INTEGER NOT NULL,
    total_price REAL NOT NULL,
    amount_guest INTEGER NOT NULL,
    rating REAL,
	FOREIGN KEY(user_id) REFERENCES user(id),
	FOREIGN KEY(property_id) REFERENCES property(id)
);

INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 1, '2025-02-01', '2025-02-03', 2, 240.0, 2, NULL);

INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 2, '2025-04-01', '2025-04-03', 2, 480.0, 1, NULL);
INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(3, 3, '2025-05-09', '2025-05-15', 6, 1920.0, 2, NULL);
INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(5, 3, '2025-09-09', '2025-09-15', 6, 1920.0, 2, NULL);
INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(1, 4, '2025-09-09', '2025-09-15', 6, 2520.0, 2, NULL);