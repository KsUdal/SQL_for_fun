--CREATE SCHEMA IF NOT EXISTS shop AUTHORIZATION postgres;
DROP TABLE IF EXISTS book;
CREATE SEQUENCE book_id_seq;
CREATE TABLE IF NOT EXISTS book(
    book_id INTEGER DEFAULT nextval('book_id_seq'),
    title VARCHAR(50),
    author VARCHAR(30),
    price DECIMAL(8, 2),
    amount INT
);
ALTER SEQUENCE book_id_seq OWNED BY book.book_id;

INSERT INTO book (title, author, price, amount) 
VALUES ('Мастер и Маргарита', 'Булгаков М.А.', '670.99', '3');
INSERT INTO book (title, author, price, amount) 
VALUES ('Белая гвардия', 'Булгаков М.А.', '540.50', '5');
INSERT INTO book (title, author, price, amount) 
VALUES ('Идиот', 'Достоевский Ф.М.', '460.00', '10');
INSERT INTO book (title, author, price, amount) 
VALUES ('Братья Карамазовы', 'Достоевский Ф.М.', '799.01', '2');

-- красивые выводы
--SELECT * FROM book;
--SELECT author, title, price FROM book;
--SELECT title AS Название, author AS Автор FROM book;
--SELECT title, amount, 1.65 * amount AS pack FROM book;

-- цена книг упала на 30%
SELECT title, author, amount, 
    ROUND(price*(1-30/100),2) AS new_price
FROM book;

-- книги Булгакова +10% в цене, Есенина +5% в цене
SELECT author, title,
    IF(author='Булгаков М.А.', ROUND(price*(1 + 10/100),2),
        IF(author='Есенин С.А.', ROUND(price*(1 + 5/100),2), price)) AS new_price
FROM book;
