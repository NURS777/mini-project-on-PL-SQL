select * from bookings;
select * from organizations;
select * from events;
select * from feedbacks;
select * from organizations;
select * from topics;

------trigger before in sert to event
CREATE OR REPLACE TRIGGER events_count_trigger
BEFORE INSERT ON events
FOR EACH ROW
DECLARE
  events_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO events_count FROM events;
  DBMS_OUTPUT.PUT_LINE('Number of events before insert: ' || events_count);
END;

-------create event
CREATE OR REPLACE PROCEDURE create_event(
   p_name IN VARCHAR2,
   p_description IN VARCHAR2,
   p_event_date IN DATE,
   p_price IN NUMBER,
   p_city_id IN NUMBER,
   p_organization_id IN NUMBER,
   p_topic_id IN NUMBER
) IS
    name_length EXCEPTION;
BEGIN
  IF LENGTH(p_name) > 8 THEN
    RAISE name_length;
  ELSE
    INSERT INTO events (name, description, event_date, price, city_id, organization_id, topic_id)
    VALUES (p_name, p_description, p_event_date, p_price, p_city_id, p_organization_id, p_topic_id);
  END IF;
EXCEPTION
  WHEN name_length THEN
    DBMS_OUTPUT.PUT_LINE('Event name maximum be 8 characters long.');
END;

------get events by city
CREATE OR REPLACE FUNCTION get_events_by_city(p_city_name IN cities.name%TYPE)
  RETURN SYS_REFCURSOR
IS
  v_events_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_events_cursor FOR
    SELECT e.id as event_id, e.name as event_name, e.description as event_description, e.event_date, e.price, t.name as topic_name, o.name as event_organization_name
    FROM events e
    JOIN topics t ON e.topic_id = t.id
    JOIN organizations o ON e.organization_id = o.id
    JOIN cities c ON e.city_id = c.id
    WHERE c.name = p_city_name;

  RETURN v_events_cursor;
END;

------get event by topic
CREATE OR REPLACE FUNCTION get_events_by_topic(p_topic_name IN topics.name%TYPE)
  RETURN SYS_REFCURSOR
IS
  v_events_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_events_cursor FOR
    SELECT e.id, e.name AS event_name, e.description AS event_description, e.event_date, e.price, t.name AS topic_name, o.name AS organization_name
    FROM events e
    JOIN topics t ON e.topic_id = t.id
    JOIN organizations o ON e.organization_id = o.id
    WHERE t.name = p_topic_name;

  RETURN v_events_cursor;
END;

-----book event
CREATE OR REPLACE PROCEDURE book_event(
  event_id IN events.id%TYPE,
  user_id IN users.id%TYPE
)
AS
BEGIN

  INSERT INTO booking (events_id, users_id)
  VALUES (event_id, user_id);

  COMMIT;
END;

------get user's booking
CREATE OR REPLACE FUNCTION getUserBooking(
  user_id NUMBER
) RETURN SYS_REFCURSOR IS
  cur SYS_REFCURSOR;
BEGIN
  OPEN cur FOR
    SELECT e.id, e.name, e.description, e.event_date, e.price, e.city_id, e.organization_id, e.topic_id
    FROM events e
    INNER JOIN booking b ON e.id = b.events_id
    WHERE b.users_id = user_id;
  RETURN cur;
END;

---number of records of bookings
CREATE OR REPLACE FUNCTION count_bookings
RETURN NUMBER
AS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM booking;
  
  RETURN v_count;
END;

----add feedback procedure
CREATE OR REPLACE PROCEDURE add_feedback(
  p_user_comment IN feedbacks.user_comment%TYPE,
  p_user_id IN feedbacks.user_id%TYPE
)
IS
BEGIN
  INSERT INTO feedbacks (user_comment, user_id)
  VALUES (p_user_comment, p_user_id);
  DBMS_OUTPUT.PUT_LINE('Number of feedbacks added: ' || SQL%ROWCOUNT);
END;

---------------------------------------------------------------------------------
--calling procedure
begin 
  create_event('dggbdfb','yaydfbayay','06-06-2023',2800,17,1,6);
end;
  
---get event by city 
DECLARE
  v_event_cursor SYS_REFCURSOR;
  v_event_id events.id%TYPE;
  v_event_name events.name%TYPE;
  v_event_description events.description%TYPE;
  v_event_date events.event_date%TYPE;
  v_price events.price%TYPE;
  v_topic_name topics.name%TYPE;
  v_event_organization_name organizations.name%TYPE;
BEGIN
  v_event_cursor := get_events_by_city('Taraz');
  LOOP
    FETCH v_event_cursor INTO v_event_id, v_event_name, v_event_description, v_event_date, v_price, v_topic_name, v_event_organization_name;
    EXIT WHEN v_event_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('-----------Events in this City--------------');
    DBMS_OUTPUT.PUT_LINE(v_event_id||','||v_event_name||','||v_event_description||','||v_event_date||','||v_price || 'kzt' || v_topic_name||','||v_event_organization_name);
   
  END LOOP;

  CLOSE v_event_cursor;
END;

---get event by topic
DECLARE
  v_events SYS_REFCURSOR;
  v_event_id events.id%TYPE;
  v_event_name events.name%TYPE;
  v_event_description events.description%TYPE;
  v_event_date events.event_date%TYPE;
  v_price events.price%TYPE;
  v_topic_name topics.name%TYPE;
  v_organization_name organizations.name%TYPE;
BEGIN
  v_events := get_events_by_topic('Music');
  
  LOOP
    FETCH v_events INTO v_event_id, v_event_name, v_event_description, v_event_date, v_price, v_topic_name, v_organization_name;
    EXIT WHEN v_events%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('-----------Events in this topic--------------');
    DBMS_OUTPUT.PUT_LINE(v_event_id || ', ' || v_event_name || ', ' || v_event_description || ', ' || v_event_date || ', ' || v_price || ', ' || v_topic_name || ', ' || v_organization_name);
  END LOOP;
  
  CLOSE v_events;
END;

---book event
BEGIN
  book_event(4,42);
END;

--count of booking table
SELECT count_bookings() FROM DUAL;

-----
begin
    add_feedback('gyu',53);
end;

----
select * from users;

---user's books
VAR result REFCURSOR;
EXEC :result := getUserBooking(42);
PRINT result;

select * from users;




















