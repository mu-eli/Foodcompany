CREATE VIEW orderdetails_with_sum AS
SELECT 
    order_detailID,
    orderID,
    productID,
    quantity,
    unit_price,
    discount,
    total_amount,
    (SELECT SUM(total_amount) FROM orderdetails) AS sum_of_orders
FROM orderdetails;