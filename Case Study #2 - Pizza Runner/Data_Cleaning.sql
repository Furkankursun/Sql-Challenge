

-- Customer_orders --> Remove null values in exlusions and extras columns and replace with blank space ' '.
select * from customer_orders

 
UPDATE customer_orders
SET exclusions = REPLACE(exclusions, 'null', ' '),
    extras = REPLACE(extras, 'null', ' ')
WHERE exclusions LIKE 'null' OR extras LIKE 'null';


-- runner_orders
-- In distance column, remove "km" and nulls and replace with blank space ' '.
-- In duration column, remove "minutes", "minute" and nulls and replace with blank space ' '.
-- In cancellation column, remove NULL and null and and replace with blank space ' '.
-- Then, we alter the pickup_time, distance and duration columns to the correct data type.

SELECT 
order_id, 
runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN ''
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance LIKE 'null' THEN ''
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
    END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN ''
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
	  ELSE cancellation
	  END AS cancellation
INTO runner_orders_temp
FROM runner_orders

ALTER TABLE runner_orders_temp  ALTER COLUMN   pickup_time DATETIME
ALTER TABLE runner_orders_temp ALTER COLUMN   distance FLOAT
ALTER TABLE runner_orders_temp ALTER COLUMN   duration INT


select * from runner_orders
select * from runner_orders_temp