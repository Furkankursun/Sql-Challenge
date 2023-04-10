-- Runner and Customer Experience
--1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- Her 1 haftalýk dönemde kaç görevli kaydoldu?

select DATEPART(WEEK, registration_date)registration_week ,count(runner_id) registration_count
from runners
group by  DATEPART(WEEK, registration_date)

--2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- Her görevlinin, sipariþi almak için Pizza Runner HQ'ya varmasý için ortalama kaç dakika sürdü?

select r.runner_id,c.order_time,r.pickup_time,(DATEDIFF(MINUTE, c.order_time, r.pickup_time))  pickup_minutes from runner_orders_temp r
join  customer_orders c on r.order_id=c.order_id
where r.distance>0  and DATEDIFF(MINUTE, c.order_time, r.pickup_time)>0


select r.runner_id,avg(DATEDIFF(MINUTE, c.order_time, r.pickup_time))  avg_pickup_minutes from runner_orders_temp r
join  customer_orders c on r.order_id=c.order_id
where r.distance>0  and DATEDIFF(MINUTE, c.order_time, r.pickup_time)>0
group by runner_id


WITH time_taken_cte AS
(
  SELECT 
    c.order_id, 
    c.order_time, 
    r.runner_id, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
  FROM customer_orders AS c
  JOIN runner_orders_temp AS r
    ON c.order_id = r.order_id
  WHERE r.distance > 0 and DATEDIFF(MINUTE, c.order_time, r.pickup_time)>0
)

SELECT runner_id,
  AVG(pickup_minutes) AS avg_pickup_minutes
FROM time_taken_cte
group by 
	runner_id


--3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- Pizza sayýsý ile sipariþin hazýrlanmasý arasýnda herhangi bir iliþki var mý?

with time_pizza_cte  AS (
select c.order_id,
	COUNT(c.order_id) AS pizza_order,
	r.pickup_time,
	DATEDIFF(MINUTE, c.order_time, r.pickup_time) pickup_minutes
from runner_orders_temp r
join  
	customer_orders c on r.order_id=c.order_id
where 
	r.distance>0 and DATEDIFF(MINUTE, c.order_time, r.pickup_time)>0
GROUP BY 
	c.order_id, c.order_time, r.pickup_time
)
SELECT 
  pizza_order, 
  AVG(pickup_minutes) AS avg_prep_time_minutes
FROM time_pizza_cte
GROUP BY pizza_order;


--A single pizza order typically requires 12 minutes to prepare.
--At an average wait time of ten minutes per pizza for  a three-pizza order
--A single order of two pizzas has the highest efficiency rate 8 minutes for each pizza.


--4 What was the average distance travelled for each customer?
-- Her müþteri için ortalama seyahat mesafesi nedir?


select c.customer_id,avg(r.distance) avg_distance from runner_orders_temp r
join  customer_orders c on r.order_id=c.order_id
where r.distance>0 
group by  c.customer_id


--5 What was the difference between the longest and shortest delivery times for all orders?
-- Tüm sipariþlerin en uzun ve en kýsa teslim süresi arasýndaki fark nedir?


select max(duration)-min(duration) min_diff
from runner_orders_temp
where duration>0

--6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- Her teslimat için her görevlinin ortalama hýzý nedir ve bu deðerlerde herhangi bir trend fark ettiniz mi?

select c.order_id,
	r.runner_id,
	ROUND((r.distance/r.duration * 60), 2) AS avg_speed
from customer_orders c 
	join runner_orders_temp r
	on c.order_id=r.order_id 
where 
	r.distance>0

--Runner 1 speed runs from 37.5km/h to 60km/h.
--Runner 2 speed runs from 35km/h to 93km/h. should investigate Runner 2
--Runner 3 speed runs  40km/h.

with speed_cte as (
select c.order_id,
	r.runner_id,
	ROUND((r.distance/r.duration * 60), 2) AS avg_speed
from customer_orders c 
	join runner_orders_temp r
	on c.order_id=r.order_id 
where 
	r.distance>0
)
select  runner_id,ROUND(avg(avg_speed),2) avg_speed
from speed_cte
group by runner_id


--7 What is the successful delivery percentage for each runner?
--Her görevlinin baþarýlý teslimat yüzdesi nedir?

select runner_id,count(*) total_deliveriy,
sum(case when distance = 0 then 0 else 1 end) succes_delivery ,
sum(case when distance = 0 then 0 else 1 end) *100 /count(*) success_percentage
from runner_orders_temp
group by runner_id

-- It is wrong to blame runners for successful deliveries because they have no control over order cancellations.

















