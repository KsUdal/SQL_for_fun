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
--SELECT author, title, price FROM book WHERE amount<10;

--цена которых меньше 500 или больше 600, а стоимость всех экземпляров этих книг больше или равна 5000
--SELECT title, author, price, amount FROM book WHERE (price<500 OR price>600) AND price*amount>=5000;

--цены которых принадлежат интервалу от 540.50 до 800 (включая границы)
--а количество или 2, или 3, или 5, или 7
--SELECT title, author FROM book WHERE (price BETWEEN 540.50 AND 800) AND (amount IN (2, 3, 5, 7));

--количество принадлежит интервалу от 2 до 14 (включая границы)  
--отсортировать сначала по авторам (в обратном порядке), затем по названиям книг (по алфавиту)
/*SELECT author, title FROM book
WHERE amount BETWEEN 2 AND 14
ORDER BY author DESC, title;*/

-- цена книг упала на 30%
/*SELECT title, author, amount, 
    ROUND(price*(1-30/100),2) AS new_price
FROM book;*/

-- книги Булгакова +10% в цене, Есенина +5% в цене
/*SELECT author, title,
    IF(author='Булгаков М.А.', ROUND(price*(1 + 10/100),2),
        IF(author='Есенин С.А.', ROUND(price*(1 + 5/100),2), price)) AS new_price
FROM book;*/
-- в postgresql функция IF работает не так

/*Вывести название и автора тех книг, название которых состоит из двух и более слов, 
а инициалы автора содержат букву «С». 
Считать, что в названии слова отделяются друг от друга пробелами 
и не содержат знаков препинания, между фамилией автора и инициалами обязателен пробел, 
инициалы записываются без пробела в формате: буква, точка, буква, точка. 
Информацию отсортировать по названию книги в алфавитном порядке.*/
/*SELECT title, author FROM book
WHERE title LIKE "_% _%"
    AND (author LIKE "_% С._." OR author LIKE "_% _.С.")
ORDER BY title;*/
-- в postgresql это ^ не работает (не работает _%)

/*Магазин счёл, что классика уже не пользуется популярностью, поэтому необходимо в выборке:
1. Сменить всех авторов на "Донцова Дарья".
2. К названию каждой книги в начале дописать "Евлампия Романова и".
3. Цену поднять на 42%.
4. Отсортировать по убыванию цены и убыванию названия.*/
SELECT 'Донцова Дарья'AS author, 
    CONCAT_WS(' ', 'Евлампия романова и', title) AS title, 
    ROUND(price*(1 + 42/100),2) AS price
FROM book
ORDER BY author DESC, price DESC;
