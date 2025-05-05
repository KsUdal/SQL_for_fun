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

/*Вывести информацию (автора, название и цену) о  книгах, 
цены которых меньше или равны средней цене книг на складе. 
Информацию вывести в отсортированном по убыванию цены виде*/
SELECT author, title, price
FROM book
WHERE price <= (
         SELECT AVG(price) 
         FROM book
      )
ORDER BY price DESC;


/*Вывести информацию (автора, название и цену) о тех книгах, 
цены которых превышают минимальную цену книги на складе не более 
чем на 150 рублей в отсортированном по возрастанию цены виде.*/
SELECT author, title,  price
FROM book
WHERE (price - (SELECT MIN(price) FROM book)) <= 150
ORDER BY price;

/*Вывести информацию (автора, книгу и количество) о тех книгах, 
количество экземпляров которых в таблице book не дублируется.*/
SELECT author, title, amount
FROM book
WHERE amount IN (
        SELECT amount
        FROM book 
        GROUP BY amount 
        HAVING count(amount) = 1
      );

/*Вывести информацию о книгах(автор, название, цена), цена которых 
меньше самой большой из минимальных цен, вычисленных для каждого автора.*/
SELECT author, title, price
FROM book
WHERE price < ANY (
        SELECT AVG(price) 
        FROM book 
        GROUP BY author 
      );

/*Посчитать сколько и каких экземпляров книг нужно заказать поставщикам, чтобы на складе стало 
одинаковое количество экземпляров каждой книги, равное значению самого большего 
количества экземпляров одной книги на складе. Вывести название книги, ее автора, 
текущее количество экземпляров на складе и количество заказываемых экземпляров книг. 
Последнему столбцу присвоить имя Заказ. В результат не включать книги, которые заказывать не нужно.*/
SELECT title, author, amount, 
      (SELECT MAX(amount) FROM book) - amount AS Заказ 
FROM book
WHERE ABS(amount - (SELECT MAX(amount) FROM book)) >0;

-- Определить стоимость покупки, если купить самую дешевую книгу каждого автора.
SELECT SUM(price)
FROM book
WHERE price = ANY(SELECT MIN(price) FROM book GROUP BY author);

---------------------
-- добавление новой таблицы
DROP TABLE IF EXISTS supply;
CREATE SEQUENCE supply_id_seq;
CREATE TABLE supply(
    supply_id INT DEFAULT nextval('supply_id_seq'),
    title VARCHAR(50),
    author VARCHAR(30),
    price DECIMAL(8, 2),
    amount INT
);
ALTER SEQUENCE supply_id_seq OWNED BY supply.supply_id;
/*AUTO_INCREMENT doesn't work in PostgreSQL*/

INSERT INTO supply(title, author, price, amount)
VALUES
    ('Лирика', 'Пастернак Б.Л.', 518.99, 2),
    ('Черный человек', 'Есенин С.А.', 570.20, 6),
    ('Белая гвардия', 'Булгаков М.А.', 540.50, 7),
    ('Идиот', 'Достоевский Ф.М.', 360.80, 3);

/*Добавить из таблицы supply в таблицу book, все книги, 
кроме книг, написанных Булгаковым М.А. и Достоевским Ф.М.*/
INSERT INTO book (title, author, price, amount) 
SELECT title, author, price, amount 
FROM supply
WHERE author NOT IN ('Булгаков М.А.', 'Достоевский Ф.М.');
SELECT * FROM book;

--Занести из таблицы supply в таблицу book только те книги, авторов которых нет в  book.
INSERT INTO book (title, author, price, amount) 
SELECT title, author, price, amount 
FROM supply
WHERE author NOT IN (
        SELECT author
        FROM book
      );
SELECT * FROM book;

/*Уменьшить на 10% цену тех книг в таблице book, 
количество которых принадлежит интервалу от 5 до 10, включая границы.*/
UPDATE book 
SET price = 0.9 * price
WHERE amount BETWEEN 5 AND 10;
SELECT * FROM book ;

/* ! buy column has to be added ! */

/*В таблице book необходимо скорректировать значение для покупателя в столбце buy таким образом, 
чтобы оно не превышало количество экземпляров книг, указанных в столбце amount. 
А цену тех книг, которые покупатель не заказывал, снизить на 10%.*/
UPDATE book 
SET buy = amount
WHERE buy > amount;
UPDATE book
SET price = 0.9*price
WHERE buy = 0;
SELECT * FROM book;

/*Для тех книг в таблице book , которые есть в таблице supply, не только увеличить их количество 
в таблице book ( увеличить их количество на значение столбца amountтаблицы supply), 
но и пересчитать их цену (для каждой книги найти сумму цен из таблиц book и supply и разделить на 2).*/
UPDATE book, supply 
SET book.amount = book.amount + supply.amount,
    book.price = (book.price + supply.price)/2
WHERE book.title = supply.title AND book.author = supply.author;
SELECT * FROM book;

/*Удалить из таблицы supply книги тех авторов, 
общее количество экземпляров книг которых в таблице book превышает 10.*/
DELETE FROM supply 
WHERE author IN (
        SELECT author 
        FROM book
        GROUP BY author
        HAVING SUM(amount) > 10
      );
SELECT * FROM supply;


/*Создать таблицу заказ (ordering), куда включить авторов и названия тех книг, количество экземпляров 
которых в таблице book меньше среднего количества экземпляров книг в таблице book. 
В таблицу включить столбец   amount, в котором для всех книг 
указать одинаковое значение - среднее количество экземпляров книг в таблице book.*/
CREATE TABLE ordering AS
SELECT author, title, (
    SELECT ROUND(AVG(amount),0)
    FROM book) AS amount
FROM book
WHERE amount < (SELECT AVG(amount) FROM book);
SELECT * FROM ordering;

/*В стране Х введена цензура - все книги авторства Достоевского нужно изъять, более 10 книг 
одного экземпляра на складе хранить нельзя (кроме Кодекса хорошего гражданина), а книги, 
в названии или авторе которых есть буква "н" нужно удорожить на 100%! 
При этом по одному экземпляру изымаемых книг Достоевского хочет оставить себе букинист-директор 
на память, а все изъятые книги нужно заменить тем же количеством книг 
"Кодекс хорошего гражданина" авторства Министерство патриотизма, чтобы на полках не было пробелов. 
- Обновить список наличия и цену книг в book;
- Сделать для директора список книг archive, которые он заберёт;
- Исправить список на закупку supply так, 
чтобы купить Кодексы в правильном количестве и не купить запрещёнку.*/
CREATE TABLE archive AS 
SELECT author, title 
FROM book 
WHERE author = 'Достоевский Ф.М.';
SELECT * FROM archive;

UPDATE supply 
SET title = 'Кодекс хорошего гражданина', 
  author = 'Министерство патриотизма', 
  price = 146.00, 
  amount = (
    SELECT SUM(amount) 
    FROM book 
    WHERE author = 'Достоевский Ф.М.' OR amount > 10
  ) 
WHERE author = 'Достоевский Ф.М.';
SELECT * FROM supply;

DELETE FROM book 
WHERE author = 'Достоевский Ф.М.';

UPDATE book 
SET amount = 10 
WHERE amount > 10 AND author <> 'Министерство патриотизма';

UPDATE book 
SET price = price * 2 
WHERE title LIKE "%н%" OR author LIKE "%н%";
SELECT * FROM book;
