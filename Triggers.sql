DELIMITER $$

/* Trigger to update sum on inserting a new record */
CREATE TRIGGER orderdetails_after_insert
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
    UPDATE orderdetails_sum
    SET sum_of_orders = sum_of_orders + NEW.total_amount
    WHERE id = 1;
END$$
DELIMITER ;

DELIMITER $$
/* Trigger to update sum after update */
CREATE TRIGGER orderdetails_after_update
AFTER UPDATE ON orderdetails
FOR EACH ROW
BEGIN
    UPDATE orderdetails_sum
    SET sum_of_orders = sum_of_orders + NEW.total_amount - OLD.total_amount
    WHERE id = 1;
END$$
DELIMITER ;

DELIMITER $$
/* Trigger to update sum on deleting an old record*/
CREATE TRIGGER orderdetails_after_delete
AFTER DELETE ON orderdetails
FOR EACH ROW
BEGIN
    UPDATE orderdetails_sum
    SET sum_of_orders = sum_of_orders - OLD.total_amount
    WHERE id = 1;
END$$

DELIMITER ;
