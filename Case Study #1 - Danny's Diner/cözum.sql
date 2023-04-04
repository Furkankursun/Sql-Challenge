
--Case Study #1: Danny's Diner

-- 1) What is the total amount each customer spent at the restaurant?
-- Her müþteri restoranda toplam ne kadar harcadý?

select customer_id as customers ,sum((m.price)) as total_amount 
from sales as S
join menu  as M
on s.product_id=m.product_id
group by customer_id


-- 2 ) How many days has each customer visited the restaurant?
-- Her müþteri restoraný kaç gün ziyaret etti?

select customer_id as customers ,count(distinct(order_date)) as spent_day
from sales
group by customer_id

-- 3 ) What was the first item from the menu purchased by each customer?
-- Her müþteri tarafýndan menüden satýn alýnan ilk ürün nedir?


WITH ordered_sales_cte  AS
(
	select customer_id,order_date,m.product_name,
	DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as custumer_rank
	from sales as S
	join menu  as M
	on s.product_id=m.product_id 
)

SELECT customer_id,product_name
FROM ordered_sales_cte
where custumer_rank = 1
GROUP BY customer_id, product_name


--4 ) What is the most purchased item on the menu and how many times was it purchased by all customers?
--Menüde en çok satýn alýnan ürün nedir ve tüm müþteriler tarafýndan kaç kez satýn alýndý?

WITH result2 AS
(
select product_name as names ,count((m.product_name)) as total_amount 
from sales as S
join menu  as M
on s.product_id=m.product_id
group by m.product_name
)

SELECT names,total_amount
FROM result2 
where total_amount = (select max(total_amount) from result2)

-----------
select top(1) product_name as names ,count((m.product_name)) as total_amount 
from sales as S
join menu  as M
on s.product_id=m.product_id
group by m.product_name
order by 2 desc

 


-- 5 ) Which item was the most popular for each customer?
-- Her müþteri için en popüler ürün hangisiydi?

WITH fav_item_cte AS
(
	select  customer_id  ,m.product_name,count(m.product_name) as order_count,
	DENSE_RANK() over (partition by s.customer_id order by count(m.product_name) desc) as order_count_rank
	from sales as S
	join menu  as M
	on s.product_id=m.product_id 
	group by customer_id,product_name
)

SELECT customer_id, product_name, order_count
FROM fav_item_cte 
WHERE order_count_rank = 1;

--6)Which item was purchased first by the customer after they became a member?
-- Müþteri üye olduktan sonra ilk satýn aldýðý ürün hangisiydi?


WITH first_order_after_join_cte AS
(select s.*,m.join_date,m2.product_name,
	DENSE_RANK() over( partition by s.customer_id order by s.order_date) as first_order_after_join	
	from sales S
		join members m
		on s.customer_id=m.customer_id
		join menu m2 
		on s.product_id=m2.product_id
		and s.order_date>m.join_date
)

SELECT  customer_id,product_name
FROM first_order_after_join_cte 
WHERE first_order_after_join = 1;



--7) Which item was purchased just before the customer became a member?
-- Müþteri üye olmadan hemen önce satýn aldýðý ürün hangisiydi?

WITH first_order_before_join_cte AS
(select s.*,m.join_date,m2.product_name,
	DENSE_RANK() over( partition by s.customer_id order by s.order_date) as first_order_before_join	
	from sales S
		join members m
		on s.customer_id=m.customer_id
		join menu m2 
		on s.product_id=m2.product_id
		and s.order_date<m.join_date
)

SELECT  customer_id,product_name
FROM first_order_before_join_cte 
WHERE first_order_before_join = 1;


--8. What is the total items and amount spent for each member before they became a member?
-- Her üye olmadan önceki toplam ürün sayýsý ve harcanan tutar nedir?


WITH total_count_cte AS
(select s.*,m.join_date,m2.product_name,m2.price
	from sales S
		left join members m
		on s.customer_id=m.customer_id
		 join menu m2 
		on s.product_id=m2.product_id
where s.order_date<m.join_date	or m.join_date is null	
)

SELECT  customer_id,count(customer_id) total_items ,sum(price) total_amount
FROM total_count_cte 
group by  customer_id


--9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Eðer her harcanan 1 dolar 10 puan olarak kabul edilirse ve sushi'nin puanlarý 2 katýna çýkaracak bir çarpaný varsa - her müþterinin kaç puaný olur?


select s.customer_id,
sum(case when  m.product_name ='sushi'  then m.price*20 else m.price*10 end) as points
from sales S,menu M
where S.product_id=M.product_id
group by s.customer_id


--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January
-- Bir müþteri programýna katýldýktan sonra ilk hafta (katýlým tarihini de içererek) sadece sushi deðil, tüm ürünlerde 2 kat puan kazanýrlar - müþteri A ve B Ocak sonunda kaç puaný vardýr?

select s.customer_id,s.order_date,m2.join_date,DATEADD(day, 6, m2.join_date) as last_day,
(case 
	when s.order_date BETWEEN m2.join_date  and DATEADD(day, 6, m2.join_date)   then m.price*20 
	else m.price*10 
end) as points
from sales S,menu M,members M2
where S.product_id=M.product_id and s.customer_id = m2.customer_id and s.order_date <= '2021-01-31' 




select s.customer_id,
sum(
case 
	when s.order_date BETWEEN m2.join_date  and DATEADD(day, 6, m2.join_date)  then m.price*20 
	else
	m.price*10 
end) as points
from sales S,menu M,members M2
where S.product_id=M.product_id and s.customer_id = m2.customer_id and s.order_date <= '2021-01-31' 
group by s.customer_id



--- BONUS QUESTIONS  1 
-- Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)



select s.customer_id,s.order_date,m.product_name,m.price,
(CASE
      WHEN  s.order_date>m2.join_date  THEN 'Y' 
	  WHEN  s.order_date<m2.join_date  THEN 'N' 
	  else 'N'
End) as members
from sales as S
	 left join menu as M
	 on S.product_id=M.product_id
	 left join members as M2
	 on S.customer_id=M2.customer_id



--- BONUS QUESTIONS 2 
-- Rank All The Things - Danny also requires further information about the ranking of customer products
--but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

WITH summary_cte AS 
(
	select s.customer_id,s.order_date,m.product_name,m.price,
	(CASE
		WHEN  s.order_date>m2.join_date  THEN 'Y' 
		WHEN  s.order_date<m2.join_date  THEN 'N' 
		 else 'N'
	End) as members
from sales as S
	 left join menu as M
	 on S.product_id=M.product_id
	 left join members as M2
	 on S.customer_id=M2.customer_id
)

select *,
(CASE
      WHEN  members='N'  THEN  Null
	  else  
	  rank() over (partition by customer_id,members order by order_date)  
End) as raking
from summary_cte

