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

--различные (уникальные) элементы столбца amount
SELECT  amount FROM book GROUP BY amount;

--количество различных книг и количество экземпляров книг каждого автора , хранящихся на складе
SELECT author AS Автор, COUNT(author) AS Различных_книг, SUM(amount) AS Количество_экземпляров
FROM book
GROUP BY author;

--Вывести фамилию и инициалы автора, минимальную, максимальную и среднюю цену книг каждого автора
SELECT author, MIN(price) AS Минимальная_цена, MAX(price) AS Максимальная_цена, ROUND(AVG(price),2) AS Средняя_цена
FROM book
GROUP BY author;

/*Для каждого автора вычислить суммарную стоимость книг S (имя столбца Стоимость), 
а также вычислить налог на добавленную стоимость  для полученных сумм (имя столбца НДС ) , 
который включен в стоимость и составляет 18% (k=18),  
а также стоимость книг  (Стоимость_без_НДС) без него. 
Значения округлить до двух знаков после запятой*/
SELECT author, SUM(price*amount) AS Стоимость, 
	ROUND((SUM(price*amount)*18/100)/(1 + 18/100), 2) AS НДС, 
	ROUND(SUM(price*amount)/(1 + 18/100), 2) AS Стоимость_без_НДС
FROM book
GROUP BY author;

--Вывести цену самой дешевой книги, цену самой дорогой и среднюю цену всех книг на складе.
SELECT MIN(price) AS Минимальная_цена, 
    MAX(price) AS Максимальная_цена, 
    ROUND(AVG(price),2) AS Средняя_цена
FROM book;

--среднюю цену и суммарную стоимость тех книг, количество экземпляров которых  от 5 до 14
SELECT
    ROUND(AVG(price),2) AS Средняя_цена,    
    ROUND(SUM(price*amount),2) AS Стоимость
FROM book
WHERE amount BETWEEN 5 AND 14;

/* стоимость всех экземпляров каждого автора без учета книг «Идиот» и «Белая гвардия». 
В результат включить только тех авторов, у которых суммарная стоимость книг 
(без учета книг «Идиот» и «Белая гвардия») более 2000 руб. 
Вычисляемый столбец назвать Стоимость. Результат отсортировать по убыванию стоимости.*/
SELECT author,
    SUM(price*amount) AS Стоимость
FROM book
WHERE title NOT IN ('Идиот', 'Белая гвардия')
GROUP BY author
HAVING SUM(price*amount) > 2000
ORDER BY SUM(price*amount) DESC;

/*Сгенерировать алфавитный указатель по названию:
Объединить книги в разделы по первой букве названия.
Каждый раздел начинать со строки, в которой непустой является только колонка 'Буква' - первая буква названия.
Для строк с названиями книг колонка 'Буква' - пустая.
Упорядочить разделы и названия книг внутри разделов (а также авторов для одинаковых названий) по алфавиту.
Вывести колонки Буква, Название и Автор.*/
SELECT Буква, title, author 
FROM(SELECT DISTINCT SUBSTRING(title, 1, 1) AS Буква, 
        '' AS title, 
        '' AS author, 
        SUBSTRING(title, 1, 1) AS Скрытая_Буква
    FROM book
    UNION
    SELECT '' AS Буква, title, author, SUBSTRING(title, 1, 1) AS Скрытая_Буква
    FROM book
    ORDER BY Скрытая_Буква) AS X;
