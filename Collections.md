# PL/SQL Collections

### Associative Arrays,Nested Tables, Varrays

1. Associative Arrays 
 
   Array structure like a 1 column table that has flexible sizing, indexed by PLS_INTEGER or VARCHAR.

```SQL
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
2. Nested Arrays
 
 An array structure like a 1 column table that can be created at the database level but uses sequential indexing. 
 That is, must create an index space with EXTEND before adding elements to the array.

```SQL

DECLARE
  TYPE NA IS          --set up a nested array type
  TABLE OF m_departments%ROWTYPE;

  dept_array NA := NA();   --declare a nested array and initialize with constructor

  CURSOR dept IS         --set up a cursor 
  SELECT *
  FROM m_departments;

BEGIN

  FOR rec in dept LOOP    
    dept_array.EXTEND;      
    dept_array(dept_array.LAST).id:= rec.id;  
    dept_array(dept_array.LAST).deptname:= rec.deptname;  
  END LOOP;
 
 --print the elements in the array
  FOR i IN my_array.FIRST..my_array.LAST LOOP
    DBMS_OUTPUT.PUT_LINE (i || ' : ' || my_array(i).id ||' - ' || my_array(i).deptname);
  END LOOP;

END;

```

3. VARRAYS

  A collection with a fixed number of elements and no holes (i.e you cannot delete elements in a varray).
  However, you can write over elements in the VARRAY.

```SQL

DECLARE
  TYPE VA IS     --set up our varray type
  VARRAY(10) OF NUMBER;
  
  num_array VA := VA(22,11,55,33,77,44,22,33,44);  --declare a varray and initialize with numbers.
  v_i NUMBER;

BEGIN 

  -- print the values passed in when the varray was initialized.
   
  v_i := num_array.FIRST;
  WHILE (v_i IS NOT NULL) LOOP
    DBMS_OUTPUT.PUT_LINE (v_i || ' : ' || num_array(v_i));
    v_i:= num_array.NEXT(v_i);    
  END LOOP;  
 
 -- our VARRAY can hold a max of 10 numbers but we have only passed in 9 numbers. 
 -- Let's fill the last index position.
  
  num_array.EXTEND();
  num_array(num_array.LAST) = 88;  
  
END;
```




