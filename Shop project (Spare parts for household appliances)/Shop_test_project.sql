CREATE SCHEMA IF NOT EXISTS shop AUTHORIZATION postgres;

DROP TABLE IF EXISTS shop.feedbacks;
drop view shop.suplies_in_order;
DROP TABLE IF EXISTS shop.sup_in_order;
DROP TABLE IF EXISTS shop.suplies;
DROP TABLE IF EXISTS shop.category;
DROP TABLE IF EXISTS shop.providers;
DROP TABLE IF EXISTS shop.orders;
DROP TABLE IF EXISTS shop.customers;
drop table if exists shop.sup_bad;

CREATE SEQUENCE shop.id_provider;
CREATE TABLE IF NOT EXISTS shop.providers (
	id integer DEFAULT nextval('shop.id_provider'),
	phone_num bigint NOT NULL,
	adress character varying(30) NOT NULL,
	PRIMARY KEY (id)
);
ALTER SEQUENCE shop.id_provider OWNED BY shop.providers.id;

CREATE SEQUENCE shop.id_category;
CREATE TABLE IF NOT EXISTS shop.category (
	id integer DEFAULT nextval('shop.id_category'),
 	device_name character varying(30) NOT NULL,
 	PRIMARY KEY (id)
);
ALTER SEQUENCE shop.id_category OWNED BY shop.category.id;

CREATE SEQUENCE shop.id_suplies;
CREATE TABLE IF NOT EXISTS shop.suplies (
	id integer DEFAULT nextval('shop.id_suplies'),
	provider_id bigint NOT NULL,
	device_id bigint NOT NULL,
	sup_name character varying(30) NOT NULL,
	availability character varying(30) NOT NULL
	CHECK(
		availability IN ('YES', 'NO', 'PREORDER')
	),
	PRIMARY KEY (id),
	FOREIGN KEY (provider_id)
	REFERENCES shop.providers(id) MATCH SIMPLE
		ON UPDATE RESTRICT
        ON DELETE CASCADE,
	FOREIGN KEY (device_id)
	REFERENCES shop.category(id) MATCH SIMPLE
		ON UPDATE RESTRICT
        ON DELETE CASCADE
);
ALTER SEQUENCE shop.id_suplies OWNED BY shop.suplies.id;

CREATE SEQUENCE shop.id_customers;
CREATE TABLE IF NOT EXISTS shop.customers (
	id integer DEFAULT nextval('shop.id_customers'),
 	full_name character varying(30) NOT NULL,
 	phone_num bigint NOT NULL,
 	PRIMARY KEY (id)
);
ALTER SEQUENCE shop.id_customers OWNED BY shop.customers.id;

CREATE SEQUENCE shop.id_orders;
CREATE TABLE IF NOT EXISTS shop.orders (
	id integer DEFAULT nextval('shop.id_orders'),
	customer_id integer NOT NULL,
	order_adress character varying(30) NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (customer_id)
		REFERENCES shop.customers(id)
		ON DELETE CASCADE
);
ALTER SEQUENCE shop.id_orders OWNED BY shop.orders.id;

CREATE SEQUENCE shop.id_feedbacks;
CREATE TABLE IF NOT EXISTS shop.feedbacks (
	id integer DEFAULT nextval('shop.id_feedbacks'),
	customer_id bigint NOT NULL,
	suply_id bigint NOT NULL,
	fb_stars bigint NOT NULL,
	fb_text character varying(50) NOT NULL,
	CHECK( 
		fb_stars IN (1, 2, 3, 4, 5)
	),
	PRIMARY KEY (id),
	FOREIGN KEY (customer_id)
		REFERENCES shop.customers(id)
		ON DELETE CASCADE,
	FOREIGN KEY (suply_id)
		REFERENCES shop.suplies(id)
		ON DELETE CASCADE
);
ALTER SEQUENCE shop.id_feedbacks OWNED BY shop.feedbacks.id;

CREATE TABLE IF NOT EXISTS shop.sup_in_order (
	suply_id bigint NOT NULL,
	order_id bigint NOT NULL,
	PRIMARY KEY (suply_id, order_id),
	FOREIGN KEY (suply_id)
		REFERENCES shop.suplies(id)
		ON DELETE CASCADE,
	FOREIGN KEY (order_id)
		REFERENCES shop.orders(id)
		ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS shop.sup_bad (
	suply_id bigint NOT NULL,
	one_stars bigint NOT NULL,
	PRIMARY KEY (suply_id)
);


-- заполнение таблиц
--DELETE FROM shop.providers WHERE id > 0;

insert into shop.providers (phone_num, adress) values ('9102003456','CrossStreet6');
insert into shop.providers (phone_num, adress) values ('9102003010','RootStreet40');
insert into shop.providers (phone_num, adress) values ('8005553535','AvenueBlack23');
insert into shop.providers (phone_num, adress) values ('8008008080','GarkStreet48');

insert into shop.category (device_name) values ('fridge');
insert into shop.category (device_name) values ('microwave');
insert into shop.category (device_name) values ('vacuum cleaner');

insert into shop.suplies (provider_id,device_id,sup_name,availability) 
values ('1','2','door','PREORDER');
insert into shop.suplies (provider_id,device_id,sup_name,availability) 
values ('3','1','magnet','YES');
insert into shop.suplies (provider_id,device_id,sup_name,availability) 
values ('2','1','shell','NO');
insert into shop.suplies (provider_id,device_id,sup_name,availability) 
values ('1','3','wire','YES');

insert into shop.customers (full_name, phone_num) values ('Michel', '9166007080');
insert into shop.customers (full_name, phone_num) values ('Mary', '9009009090');

insert into shop.orders (customer_id, order_adress) 
values ('1', 'GreenAlley2');
insert into shop.orders (customer_id, order_adress) 
values ('1', 'GreenAlley2');
insert into shop.orders (customer_id, order_adress) 
values ('2', 'OddRoad17');

insert into shop.sup_in_order (suply_id, order_id) values ('1', '2');
insert into shop.sup_in_order (suply_id, order_id) values ('2', '1');
insert into shop.sup_in_order (suply_id, order_id) values ('3', '1');
insert into shop.sup_in_order (suply_id, order_id) values ('1', '1');

insert into shop.feedbacks (customer_id, suply_id, fb_stars, fb_text) 
values ('1', '1', '1', 'bad');
insert into shop.feedbacks (customer_id, suply_id, fb_stars, fb_text) 
values ('2', '1', '1', 'very bad');
insert into shop.feedbacks (customer_id, suply_id, fb_stars, fb_text) 
values ('1', '2', '4', 'normal');
insert into shop.feedbacks (customer_id, suply_id, fb_stars, fb_text) 
values ('1', '3', '5', 'lovely');
insert into shop.feedbacks (customer_id, suply_id, fb_stars, fb_text) 
values ('2', '3', '1', 'broken');
	

--select * from shop.providers;
--select * from shop.category;
--select * from shop.suplies;
--select * from shop.customers;
--select * from shop.orders;

-- хранимые процедуры

-- 1) добавление нового пользователя, если его не существует
create or replace procedure shop.add_customer(
    ask_full_name character varying(30),
    ask_phone_num bigint
)
as $$
begin
	if exists (select 1 from shop.customers cu
		where cu.full_name = ask_full_name and cu.phone_num = ask_phone_num) then
    	--rollback;
	else
		insert into shop.customers (full_name, phone_num)
			values (ask_full_name, ask_phone_num);
		--commit;
	end if;
end;
$$ language plpgsql;

--drop procedure shop.add_customer
call shop.add_customer('Michel', '9166007080');
--select * from shop.customers

-- 2) удаление поставщика по id, если у него нет товаров
create or replace procedure shop.delete_provider(
	ask_id integer
)
as $$
begin
	if ask_id in (select provider_id from shop.suplies where availability != 'NO') then
		--rollback;
	else
		delete from shop.providers
			where id = ask_id;
		--commit;
	end if;
end;
$$ language plpgsql;

--drop procedure shop.delete_provider
--call shop.delete_provider('3');
--call shop.delete_provider('4');
--select * from shop.providers

-- 3) подсчёт негативных отзывов
create or replace procedure shop.counter_of_bad( s_id integer )
as $$
	declare counter int;
begin
	counter = (select count(*) from shop.feedbacks where fb_stars = 1 and suply_id = s_id);
	if exists (select 1 from shop.sup_bad where suply_id = s_id) then
		update shop.sup_bad set one_stars = counter
			where suply_id = s_id;
	else
		insert into shop.sup_bad (suply_id, one_stars) values (s_id, counter);
	end if;
end;
$$ language plpgsql;
CALL shop.counter_of_bad(1);
CALL shop.counter_of_bad(2);
CALL shop.counter_of_bad(3);
CALL shop.counter_of_bad(4);

-- view
-- 4) выводит список товаров в заказах (сортирует по id заказа)
create view shop.suplies_in_order as
	select order_id, order_adress, suply_id, sup_name
		from shop.sup_in_order sio left join shop.orders o
			on sio.order_id = o.id
		left join shop.suplies s
			on sio.suply_id = s.id
	order by order_id;
	
-- триггер
-- 5) пересчёт плохих отзывов после добавления нового
create or replace function shop.recount_stars() returns trigger as $emp_stamp$
	begin
		call shop.counter_of_bad(CAST(new.suply_id as int));
		return new;
	end;
$emp_stamp$ LANGUAGE plpgsql;

create or replace trigger recount_stars after INSERT on shop.feedbacks
    for each row execute procedure shop.recount_stars();


-- 6) в наличии не будет товаров, у которых много плохих отзывов
create or replace function shop.stars_check() returns trigger as $emp_stamp$
	begin
		if (select one_stars from shop.sup_bad where suply_id = new.suply_id) > 1 then
			update shop.suplies set availability = 'NO'
			where id = new.suply_id;
		end if;
		return new;
	end;
$emp_stamp$ LANGUAGE plpgsql;

create or replace trigger stars_check after UPDATE on shop.sup_bad
    for each row execute procedure shop.stars_check();


-- вставка для проверки
/*
insert into shop.feedbacks (customer_id, suply_id, fb_stars, fb_text) 
values ('2', '2', '1', 'expensive');
insert into shop.feedbacks (customer_id, suply_id, fb_stars, fb_text) 
values ('1', '2', '1', 'broken');
*/

--select * from shop.suplies_in_order;
--drop view shop.suplies_in_order;

--select * from shop.providers;
--select * from shop.category;
select * from shop.suplies;
--select * from shop.customers;
--select * from shop.orders;
--select * from shop.sup_in_order;
--select * from shop.sup_bad;
