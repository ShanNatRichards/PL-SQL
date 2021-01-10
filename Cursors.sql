--The point of this exercise was totuilized parameterized cursors to 
--output a formatted list of invoices
--unfortunately, could not get a sqldump of the associated tables

CREATE OR REPLACE PROCEDURE LAB4_Invoicesummaries (p_start DATE, p_end DATE) 
AS
v_GrandTotal NUMBER;
v_lineTotal NUMBER;
v_String VARCHAR2(100);
v_counter NUMBER;

--cursor for the suppliers
--grabbing only those suppliers with an order for the specified time range.
CURSOR c_sup IS
        SELECT DISTINCT s.id, s.name
        FROM l4_suppliers s
        INNER JOIN l4_orders o ON o.sup_id = s.id 
                    AND o_date >= p_start
                    AND o_date <= p_end
        ORDER BY s.id;
--cursor fr the order table
--grabd only orders made in the specified time range
CURSOR c_orders (p_sup_id NUMBER) IS

        SELECT id, o_date
        FROM l4_orders
        WHERE  sup_id = p_sup_id 
               AND o_date >= p_start
               AND o_date <= p_end
        ORDER BY id;

--cursor which gets the details about the line items in  the order
CURSOR c_details (p_ord_id NUMBER) IS

        SELECT o.id, d.pro_id, d.quantity, 
               sp.price, o.o_date, prod.description, 
               (sp.price*d.quantity) as Cost
        FROM l4_orders o
        LEFT JOIN l4_details  d ON d.ord_id = o.id
        LEFT JOIN l4_sup_pro sp ON sp.pro_id = d.pro_id 
                  AND sp.sup_id = o.sup_id
        LEFT JOIN  l4_products prod ON prod.our_id = d.pro_id  
        WHERE o.id = p_ord_id;

BEGIN
--spit out the opening text
dbms_output.new_line;
dbms_output.put_line('Printing invoice summaries for ' ||TO_CHAR(p_start, 'DD-MON-YYYY') || ' to ' || TO_CHAR(p_end, 'DD-MON-YYYY'));
dbms_output.new_line;

FOR c_sup_rec in c_sup LOOP
    dbms_output.put_line('Orders placed with supplier ' || c_sup_rec.name );
    dbms_output.new_line;
   FOR c_ord_rec in c_orders(c_sup_rec.id) LOOP
        dbms_output.put_line(CHR(9) ||'Order number: ' || c_ord_rec.id || ' placed on ' || TO_CHAR(c_ord_rec.o_date, 'DD-MON-YYYY') || ':');
        --set out variable that will store the total to 0 
        --also set the counter needed for the strings to 1.
        v_grandTotal:= 0;
        v_counter:= 1;

        FOR c_det_rec in c_details(c_ord_rec.id) LOOP
            v_lineTotal:= c_det_rec.cost;
            v_String:= CHR(9) || v_counter || '.' ||CHR(9) || c_det_rec.description || ' - Product ' || c_det_rec.pro_id || ' (' || c_det_rec.quantity ||
                                   ' at $'|| c_det_rec.price || ' each )' ;

            dbms_output.put_line(RPAD(v_String, 60) || TO_CHAR(c_det_rec.cost, '$999,990.00')  );
            
            --add the line totals to our grand total variable
            v_GrandTotal:= v_GrandTotal + v_lineTotal;
            --go to the next counter position.
            v_counter:= v_counter + 1;
        END LOOP;
        --formatting and printing grand total.
        v_string:= RPAD(' ', 24, '=');
        dbms_output.put_line(LPAD(v_String,76));
        v_string:= 'Order Grand Total:   '|| TO_CHAR(v_GrandTotal, '$9,999,990.00');
        dbms_output.put_line(LPAD(v_string, 76));
        dbms_output.new_line();
   END LOOP;
END LOOP;
END;
