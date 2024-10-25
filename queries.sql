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

--запрос, который выводит количество покупателей в разных возрастных группах
select
    '16-25' as age_category,
    COUNT(age) as age_count
from customers as c 
where age >= 16 and age <=25

UNION 

select
    '26-40' as age_category,
    COUNT(age) as age_count
from customers as c 
where age >= 26 and age <=40

UNION 

select
    '40+' as age_category,
    COUNT(age) as age_count
from customers as c 
where age > 40
order by age_category;

--запрос, который выводит количество уникальных покупателей и выручку, которую они принесли
select 
	to_char(s.sale_date, 'yyyy-mm') as selling_month,
	count(distinct s.customer_id) as total_customes,
	floor(sum(p.price*s.quantity)) as income
from sales as s
inner join products as p on p.product_id = s.product_id
group by selling_month;

--запрос, который выводит данные о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)
select DISTINCT ON (s.customer_id)
    (concat_ws(' ', c.first_name, c.last_name)) as customer,
    s.sale_date,
    concat_ws(' ', e.first_name, e.last_name) as seller
from sales as s 
inner join products as p on p.product_id = s.product_id
inner join customers as c on s.customer_id = c.customer_id 
inner join employees as e on s.sales_person_id = e.employee_id 
where p.price = 0
order by s.customer_id, s.sale_date;