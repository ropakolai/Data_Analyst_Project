--Get total number of items, the total prices value, the average price value
--the minimum and maximum price value of the items
SELECT COUNT(*) AS Number_of_items, 
SUM(price) AS Total_prices, 
ROUND(AVG(price), 2) AS Average_price,
MIN(price) AS Minimum_price,
MAX(price) AS Maximum_price
FROM item;


--The total turnover per supplier
--per supplier
SELECT supplier, SUM((si.quantity * i.price)) AS Total 
FROM product p
JOIN item i
ON i.product_id = p.id
JOIN sales_item si
ON i.id = si.item_id
JOIN sales_order so
ON so.id = si.sales_order_id
GROUP BY Supplier
ORDER BY Total DESC;

--Looks like items from Johnston & Murphy have generated the highest turonver
--Let's check if it is due to their quantity or price
SELECT supplier, SUM(quantity)
FROM product p
JOIN item i
ON i.product_id = p.id
JOIN sales_item si
ON i.id = si.item_id
JOIN sales_order so
ON so.id = si.sales_order_id
GROUP BY supplier
ORDER BY SUM(quantity) DESC;

--it appears that the most numerous items in the inventory are 
--items from Johnston & Murphy 

--Let's check if items from Johnston & Murphy are the most expansive
SELECT supplier, MAX(price)
FROM product p
JOIN item i
ON i.product_id = p.id
JOIN sales_item si
ON i.id = si.item_id
JOIN sales_order so
ON so.id = si.sales_order_id
GROUP BY supplier
ORDER BY MAX(price) DESC;

--turns out that items from Johnston & Murphy are not the most expansive, 
--so the main reason why items from this supplier have generated the 
--highest turover is due to the quantity of items sold. 



--Create a function with the supplier as entry to check
--the total turover that would be generated if they sold all items of 
--that supplier. Here we will run that function for Johnston & Murphy items
CREATE OR REPLACE FUNCTION fn_get_supplier_value(the_supplier varchar) 
RETURNS varchar AS
$body$
DECLARE
	supplier_name varchar;
	price_sum numeric;
BEGIN
	SELECT product.supplier, SUM(item.price)
 	INTO supplier_name, price_sum
	FROM product, item
	WHERE product.supplier = the_supplier
	GROUP BY product.supplier;
	RETURN CONCAT(supplier_name, ' Inventory Value : $', price_sum);
END;
$body$
LANGUAGE plpgsql

SELECT fn_get_supplier_value('Johnston & Murphy');

-- The inventory value for Johnston & Murphy items is $21694.74

--Let's check from which state are the majority of the customers.
SELECT state, COUNT(so.id) 
FROM customer c
JOIN sales_order so
ON c.id = so.cust_id
GROUP BY state
ORDER BY COUNT(so.id) DESC;


-- it appears that more than half of them are from Texas.

--Let's check if the curstomers are mainly men or female.
SELECT sex, COUNT(so.id) 
FROM customer c
JOIN sales_order so
ON c.id = so.cust_id
GROUP BY sex
ORDER BY COUNT(so.id) DESC;

--Almost 80% of all customers are female.




