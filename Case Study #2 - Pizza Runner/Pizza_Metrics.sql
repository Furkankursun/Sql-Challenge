 -- Pizza Metrics
 
-- 1 How many pizzas were ordered?
-- Kaç adet pizza sipariþ edildi?

select count(*) as pizzas_ordered
 from customer_orders


 -- 2 How many unique customer orders were made?
 -- Kaç farklý müþteri sipariþi verildi?

 select count(distinct(order_id)) as unique_customer_orders
 from customer_orders

 -- 3 How many successful orders were delivered by each runner?
 -- Her görevli kaç baþarýlý teslimat yaptý?


 select runner_id,count(distance) as successful_orders  from runner_orders_temp
 where pickup_time !=0
 group by runner_id



-- 4 How many of each type of pizza was delivered?
-- 4 Her tür pizzadan kaç adet teslim edildi?

select p.pizza_id,count(*) from  customer_orders c
 join pizza_names  p on c.pizza_id=p.pizza_id
 join runner_orders_temp r on r.order_id=c.order_id
 where cancellation like ''
 GROUP BY p.pizza_id 

 -- 5 How many Vegetarian and Meatlovers were ordered by each customer?
 -- Her müþteri kaç adet vejetaryen ve et seven pizza sipariþi verdi?
 SELECT customer_id,
	sum(
		CASE
			WHEN pizza_id = 1 THEN 1
			ELSE 0
		END
	) AS meat_lovers,
	sum(
		CASE
			WHEN pizza_id = 2 THEN 1
			ELSE 0
		END
	) AS vegetarian
FROM customer_orders
GROUP BY customer_id

-- 6 Tek bir sipariþte kaç adet pizza teslim edildi? 
-- 6 What was the maximum number of pizzas delivered in a single order?


with cte_order_max as
(	select c.order_id,count(c.order_id) order_count from  customer_orders c
	join runner_orders_temp r on r.order_id=c.order_id
	where cancellation like ''
	 group by c.order_id
)

 select max(order_count) max_order  
 from cte_order_max

-- 7 Her müþteri için, kaç teslim edilen pizzada en az 1 deðiþiklik yapýldý ve kaçýnda hiç deðiþiklik yapýlmadý?
-- 7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select customer_id,
sum(CASE
		WHEN c.exclusions = ''  and c.extras='' then 1
		ELSE 0
	END
	) AS no_changes,
	sum(CASE
			WHEN c.exclusions != ''   or c.extras != ''  then 1
			ELSE 0
		END
	) AS has_changes

from  customer_orders c
	join runner_orders_temp r on r.order_id=c.order_id
	where cancellation like ''
GROUP BY c.customer_id

-- 8 How many pizzas were delivered that had both exclusions and extras?
--  Hem istisnalarý (exclusions) hem de ekstralarý (extras) olan kaç pizza teslim edildi?



select
	sum(CASE
			WHEN c.exclusions != ''   and c.extras != ''  then 1
			ELSE 0
		END
		) AS both_changes

from  customer_orders c
	join runner_orders_temp r on r.order_id=c.order_id
	where cancellation like ''


--9 What was the total volume of pizzas ordered for each hour of the day?
-- 9 Günün her saati için sipariþ edilen toplam pizza hacmi nedir?


select DATEPART(HOUR, [order_time]) hour_of_the_day,count(customer_id) as pizza_count
from  customer_orders c
	join runner_orders_temp r on r.order_id=c.order_id
	where cancellation like ''
group by DATEPART(HOUR, [order_time])

--10 What was the volume of orders for each day of the week?
-- Haftanýn her günü için sipariþ hacmi nedir?


-- FORMAT([order_time], 'dddd')
select DATENAME(weekday, [order_time]) hour_of_the_day,count(customer_id) as pizza_count
from  customer_orders c
	join runner_orders_temp r on r.order_id=c.order_id
	where cancellation like ''
group by DATENAME(weekday, [order_time])



select FORMAT( [order_time],'dddd') hour_of_the_day,count(customer_id) as pizza_count
from  customer_orders c
	join runner_orders_temp r on r.order_id=c.order_id
	where cancellation like ''
group by FORMAT( [order_time],'dddd')

























