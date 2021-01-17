# Collections

### Exploring pl/sql collections: Associative Arrays, Varrays, and Nested Tables

1. Associative Arrays 
Flexible 

```PLSQL
SET SERVEROUTPUT ON;

DECLARE

  TYPE AA IS
  TABLE OF M_Departments%ROWTYPE  --set up or associative array type 
  INDEX BY PLS_INTEGER;
    
  dep_array AA; --declare an array
    
  v_i PLS_INTEGER; --variable for indexing the array
    
  CURSOR dept IS --set up a cursor 
  SELECT *
  FROM m_departments;

BEGIN

  v_i:= 1;

  FOR rec in dept LOOP --open and loop through the cursor to fill the array
    dep_array(v_i).id := rec.id;
    dep_array(v_i).deptname:= rec.deptname;
    v_i:= v_i + 1;
  END LOOP;

 --let's print the values stored in our array
  v_i:= dep_array.FIRST; --grab the first index position in our array
 
  WHILE (v_i IS NOT NULL) LOOP
    DBMS_OUTPUT.PUT_LINE (  'INDEX '||v_i || ' : ' || darray(v_i).deptname);
    v_i:= dep_arr.NEXT(v_i);
  END LOOP;

--let's print this backwards
  v_i:= darray.LAST;

  WHILE (v_i IS NOT NULL) LOOP
    DBMS_OUTPUT.PUT_LINE (  'INDEX '||v_i || ' : ' || darray(v_i).deptname);
    v_i:= darray.PRIOR(v_i);
  END LOOP;

END;

```



/* NESTED ARRAYS */

--this is a pl/sql table but it can declared at the database level
--uses sequential indexing 

DECLARE
  TYPE NA IS 
  TABLE OF m_departments%ROWTYPE;

  my_array NA := NA();-- must pass it a constructor

  CURSOR dept IS
    SELECT *
    FROM m_departments;

BEGIN

  FOR rec in dept LOOP
    dbms_output.put_line('Before Extend: Last -> ' || my_array.LAST || '  First -> ' || my_array.FIRST);
    my_array.EXTEND;
    my_array.EXTEND;
    dbms_output.put_line('After Extend: Last -> ' || my_array.last || '  First -> ' || my_array.first);
    my_array(my_array.LAST).id:= rec.id;
    my_array(my_array.LAST).deptname:= rec.deptname;
    dbms_output.put_line('After Rec Added: Last -> ' || my_array.LAST || '  First -> ' || my_array.FIRST);  
    dbms_output.put_line('');
    dbms_output.put_line('Next iteration:');
  END LOOP;
 
  FOR i IN my_array.FIRST..my_array.LAST LOOP
    DBMS_OUTPUT.PUT_LINE (i || ' : ' || my_array(i).id ||' - ' || my_array(i).deptname);
  END LOOP;


END;


--another nested array

DECLARE 
  TYPE NA IS
  TABLE OF NUMBER;

  array_1 NA:= NA(7,10,2,5);

BEGIN
  dbms_output.put_line('Last ->' || array_1.last || '  First -> ' || array_1.first);
  array_1.EXTEND(5);
  
  array_1.delete(1);
  dbms_output.put_line('Last ->' || array_1.last || '  First -> ' || array_1.first);
END;



/*VARRAYS*/
--a collection with a fixed number of elements and no gaps
--i.e. you cannot delete varray elements

DECLARE
  TYPE va IS 
  VARRAY(10) OF NUMBER;
  array_2 va := va(22,11,55,33,77,44,22,33,44);
  v_i NUMBER;

BEGIN 
  dbms_output.put_line('Last ->' || array_2.last || '  First -> ' || array_2.first);
  
  v_i := array_2.FIRST;

  WHILE (v_i IS NOT NULL) LOOP
    DBMS_OUTPUT.PUT_LINE (v_i || ' : ' || array_2(v_i));
    v_i:= array_2.NEXT(v_i);    
  END LOOP;
  
  dbms_output.put_line('Last ->' || array_2.last || '  First -> ' || array_2.first);
  
  array_2.EXTEND(2);
  
  dbms_output.put_line('Last ->' || array_2.last || '  First -> ' || array_2.first);
--array_2.delete(3); --nope cannot delete this index, not allowed
  array_2(3):=111;

  v_i := array_2.FIRST;
  WHILE (v_i IS NOT NULL) LOOP
    DBMS_OUTPUT.PUT_LINE (v_i || ' : ' || array_2(v_i));
    v_i:= array_2.NEXT(v_i);    
  END LOOP;
END;


---------------------------------------------------



