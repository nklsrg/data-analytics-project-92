--запрос, который считает общее количество покупателей из таблицы customers
select count(customer_id) as customers_count from customers;

--запрос, который выводит данные о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок, и сортирует по убыванию выручки
with tab as (
	select
		e.employee_id,
		concat_ws(' ', e.first_name, e.last_name) as name,
		count(s.sales_id) as seller_deals,
		sum(p.price*s.quantity) as total_income
	from employees as e
	inner join sales as s on s.sales_person_id = e.employee_id
	inner join products as p on p.product_id = s.product_id
	group by e.employee_id
	order by total_income desc
)

select 
	t.name as seller,
	t.seller_deals as operations,
	t.total_income as income
from tab as t
order by total_income desc
limit 10;

--запрос, который выводит данные о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Сортирует по выручке по возрастанию
select 
	concat_ws(' ', e.first_name, e.last_name) as seller,
	round(avg(p.price * s.quantity), 0) as average_income
from employees as e
inner join sales as s on s.sales_person_id = e.employee_id
inner join products as p on p.product_id = s.product_id
group by e.employee_id
having round(avg(p.price * s.quantity), 0) < (
	select avg(p.price * s.quantity)
	from sales as s 
	inner join products as p on p.product_id = s.product_id
	)
order by average_income;

--запрос, котоырй выводит данные о выручке по дням недели. Сортирует данные по порядковому номеру дня недели и продавцу
select 
	concat_ws(' ', e.first_name, e.last_name) as seller,
	case to_char(s.sale_date, 'id')
		when '1' then 'monday'
		when '2' then 'tuesday'
		when '3' then 'wednesday'
		when '4' then 'thursday'
		when '5' then 'friday'
		when '6' then 'saturday'
		when '7' then 'sunday'
	end as day_of_week,
	round(avg(p.price * s.quantity), 0) as income
from employees as e
inner join sales as s on s.sales_person_id = e.employee_id
inner join products as p on p.product_id = s.product_id
group by e.employee_id, to_char(s.sale_date, 'id')
order by to_char(s.sale_date, 'id'), seller;