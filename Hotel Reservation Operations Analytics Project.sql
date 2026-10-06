CREATE DATABASE IF NOT EXISTS staypoint_hospitality;

USE staypoint_hospitality;

-- Creation of tables

CREATE TABLE guests (
    guest_id VARCHAR(20) PRIMARY KEY,
    guest_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    guest_type VARCHAR(20),
    preferred_room_type VARCHAR(20),
    loyalty_tier VARCHAR(20),
    account_since DATE
);

CREATE TABLE hotels (
    hotel_id VARCHAR(20) PRIMARY KEY,
    hotel_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    star_rating INT,
    total_rooms INT,
    opened_date DATE
);

CREATE TABLE staff (
    staff_id VARCHAR(20) PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    hire_date DATE,
    rating DECIMAL(3,2),
    department VARCHAR(30),
    is_active VARCHAR(3) DEFAULT 'Yes'
);

CREATE TABLE rooms (
    room_id VARCHAR(20) PRIMARY KEY,
    hotel_id VARCHAR(20) NOT NULL,
    room_type VARCHAR(20),
    floor_num INT,
    max_occupancy INT,
    price_per_night DECIMAL(10,2),
    is_active VARCHAR(3) DEFAULT 'Yes',

    CONSTRAINT fk_rooms_hotel
        FOREIGN KEY (hotel_id)
        REFERENCES hotels(hotel_id)
);

CREATE TABLE bookings (
    booking_id VARCHAR(20) PRIMARY KEY,
    guest_id VARCHAR(20) NOT NULL,
    hotel_id VARCHAR(20) NOT NULL,
    booking_date DATE,
    room_type_requested VARCHAR(20),
    booking_channel VARCHAR(30),
    nights_booked INT,
    total_amount DECIMAL(12,2),

    CONSTRAINT fk_bookings_guest
        FOREIGN KEY (guest_id)
        REFERENCES guests(guest_id),

    CONSTRAINT fk_bookings_hotel
        FOREIGN KEY (hotel_id)
        REFERENCES hotels(hotel_id)
);

CREATE TABLE stays (
    stay_id VARCHAR(20) PRIMARY KEY,
    booking_id VARCHAR(20) NOT NULL,
    room_id VARCHAR(20) NOT NULL,
    staff_id VARCHAR(20) NOT NULL,
    check_in_date DATE,
    check_out_date DATE,
    status VARCHAR(20),
    nights_stayed INT,
    service_requests INT,
    stay_duration_hrs INT,

    CONSTRAINT fk_stays_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id),

    CONSTRAINT fk_stays_room
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id),

    CONSTRAINT fk_stays_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
);

SELECT * FROM guests LIMIT 10;

SELECT * FROM hotels LIMIT 10;

SELECT * FROM rooms LIMIT 10;

SELECT * FROM bookings LIMIT 10;

SELECT * FROM stays LIMIT 10;

SELECT * FROM staff LIMIT 10;

SHOW TABLES;

-- Sprint 3

-- 1. What is the total number of guests?
SELECT COUNT(*) AS total_guests
FROM guests;

-- 2. What is the total number of bookings?
SELECT COUNT(*) AS total_bookings
FROM bookings;

-- 3. What is the total number of stays?
SELECT COUNT(*) AS total_stays
FROM stays;

-- 4. What are the different room types available?
SELECT DISTINCT room_type
FROM rooms
ORDER BY room_type;

-- 5. How many staff members are currently active?
SELECT COUNT(*) AS active_staff
FROM staff
WHERE LOWER(is_active) = 'yes';

-- 6. What are the different booking channels?
SELECT DISTINCT booking_channel
FROM bookings
ORDER BY booking_channel;

-- 7. What is the total booking amount across all bookings?
SELECT
    SUM(total_amount) AS total_booking_amount
FROM bookings;

-- 8. What is the average nights booked per booking?
SELECT
    ROUND(AVG(nights_booked), 2) AS average_nights_booked
FROM bookings;

# Sprint 4
-- 4.1 UNDERSTAND BOOKING DEMAND
-- Which hotels receive the highest number of bookings?
SELECT
    h.hotel_id,
    h.hotel_name,
    h.city,
    COUNT(b.booking_id) AS total_bookings
FROM hotels h
LEFT JOIN bookings b
    ON h.hotel_id = b.hotel_id
GROUP BY
    h.hotel_id,
    h.hotel_name,
    h.city
ORDER BY total_bookings DESC;

-- Which booking channels generate the most bookings?
SELECT
    booking_channel,
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY booking_channel
ORDER BY total_bookings DESC;

-- Which booking channels generate the highest booking value?
SELECT
    booking_channel,
    COUNT(*) AS total_bookings,
    SUM(total_amount) AS total_booking_amount,
    ROUND(AVG(total_amount), 2) AS average_booking_amount
FROM bookings
GROUP BY booking_channel
ORDER BY total_booking_amount DESC;

-- Which room types are requested most frequently?
SELECT
    room_type_requested,
    COUNT(*) AS total_requests
FROM bookings
GROUP BY room_type_requested
ORDER BY total_requests DESC;

-- How does booking volume change over time?
SELECT
    YEAR(booking_date) AS booking_year,
    MONTH(booking_date) AS booking_month,
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY
    YEAR(booking_date),
    MONTH(booking_date)
ORDER BY
    booking_year,
    booking_month;
    
-- Which hotels generate the highest total booking amount?
SELECT
    h.hotel_name,
    h.city,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_booking_amount
FROM hotels h
JOIN bookings b
    ON h.hotel_id = b.hotel_id
GROUP BY
    h.hotel_id,
    h.hotel_name,
    h.city
ORDER BY total_booking_amount DESC;

-- Which hotels have the highest average booking value?
SELECT
    h.hotel_name,
    ROUND(AVG(b.total_amount), 2) AS average_booking_amount
FROM hotels h
JOIN bookings b
    ON h.hotel_id = b.hotel_id
GROUP BY
    h.hotel_id,
    h.hotel_name
ORDER BY average_booking_amount DESC;

-- Which hotels have the highest demand relative to their room capacity?
SELECT
    h.hotel_name,
    h.total_rooms,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(
        COUNT(b.booking_id) / NULLIF(h.total_rooms, 0),
        2
    ) AS bookings_per_room
FROM hotels h
LEFT JOIN bookings b
    ON h.hotel_id = b.hotel_id
GROUP BY
    h.hotel_id,
    h.hotel_name,
    h.total_rooms
ORDER BY bookings_per_room DESC;

# 4.2 UNDERSTAND GUEST BOOKING BEHAVIOUR
-- Which guests have made multiple bookings?
SELECT
    g.guest_id,
    g.guest_name,
    COUNT(b.booking_id) AS total_bookings
FROM guests g
JOIN bookings b
    ON g.guest_id = b.guest_id
GROUP BY
    g.guest_id,
    g.guest_name
HAVING COUNT(b.booking_id) > 1
ORDER BY total_bookings DESC;

-- Which guests have generated the highest total booking amount?
SELECT
    g.guest_id,
    g.guest_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_spent
FROM guests g
JOIN bookings b
    ON g.guest_id = b.guest_id
GROUP BY
    g.guest_id,
    g.guest_name
ORDER BY total_spent DESC;

-- How does booking activity differ between Individual and Corporate guests?
SELECT
    g.guest_type,
    COUNT(b.booking_id) AS total_bookings,
    COUNT(DISTINCT g.guest_id) AS unique_guests,
    SUM(b.total_amount) AS total_booking_amount,
    ROUND(AVG(b.total_amount), 2) AS average_booking_amount,
    ROUND(AVG(b.nights_booked), 2) AS average_nights_booked
FROM guests g
JOIN bookings b
    ON g.guest_id = b.guest_id
GROUP BY g.guest_type
ORDER BY total_booking_amount DESC;

-- Which hotels are most preferred by guests?
SELECT
    h.hotel_name,
    COUNT(b.booking_id) AS total_bookings,
    COUNT(DISTINCT b.guest_id) AS unique_guests
FROM bookings b
JOIN hotels h
    ON b.hotel_id = h.hotel_id
GROUP BY
    h.hotel_id,
    h.hotel_name
ORDER BY total_bookings DESC;

-- Which guests have the longest total requested stay duration?
SELECT
    g.guest_id,
    g.guest_name,
    SUM(b.nights_booked) AS total_nights_booked
FROM guests g
JOIN bookings b
    ON g.guest_id = b.guest_id
GROUP BY
    g.guest_id,
    g.guest_name
ORDER BY total_nights_booked DESC;

-- Which guest types use different booking channels?
SELECT
    g.guest_type,
    b.booking_channel,
    COUNT(*) AS total_bookings
FROM guests g
JOIN bookings b
    ON g.guest_id = b.guest_id
GROUP BY
    g.guest_type,
    b.booking_channel
ORDER BY
    g.guest_type,
    total_bookings DESC;

-- How does booking behaviour change over time by guest type?
SELECT
    YEAR(b.booking_date) AS booking_year,
    MONTH(b.booking_date) AS booking_month,
    g.guest_type,
    COUNT(*) AS total_bookings,
    SUM(b.total_amount) AS total_booking_amount
FROM guests g
JOIN bookings b
    ON g.guest_id = b.guest_id
GROUP BY
    YEAR(b.booking_date),
    MONTH(b.booking_date),
    g.guest_type
ORDER BY
    booking_year,
    booking_month,
    g.guest_type;
    
-- What is the average booking value for Individual and Corporate guests?
SELECT
    g.guest_type,
    ROUND(AVG(b.total_amount), 2) AS average_booking_value
FROM guests g
JOIN bookings b
    ON g.guest_id = b.guest_id
GROUP BY g.guest_type;

# 4.3 EVALUATE STAY PERFORMANCE
-- What is the distribution of stay statuses?
SELECT
    status,
    COUNT(*) AS total_stays,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stays),
        2
    ) AS percentage_of_stays
FROM stays
GROUP BY status
ORDER BY total_stays DESC;

-- What are the stay outcomes across hotels?
SELECT
    h.hotel_name,
    s.status,
    COUNT(*) AS total_stays
FROM stays s
JOIN bookings b
    ON s.booking_id = b.booking_id
JOIN hotels h
    ON b.hotel_id = h.hotel_id
GROUP BY
    h.hotel_id,
    h.hotel_name,
    s.status
ORDER BY
    h.hotel_name,
    total_stays DESC;
    
-- Which hotels have the highest number of cancelled stays?
SELECT
    h.hotel_name,
    COUNT(*) AS cancelled_stays
FROM stays s
JOIN bookings b
    ON s.booking_id = b.booking_id
JOIN hotels h
    ON b.hotel_id = h.hotel_id
WHERE LOWER(s.status) = 'cancelled'
GROUP BY
    h.hotel_id,
    h.hotel_name
ORDER BY cancelled_stays DESC;

-- Which hotels have the highest number of no-shows?
SELECT
    h.hotel_name,
    COUNT(*) AS no_show_stays
FROM stays s
JOIN bookings b
    ON s.booking_id = b.booking_id
JOIN hotels h
    ON b.hotel_id = h.hotel_id
WHERE LOWER(s.status) = 'no-show'
GROUP BY
    h.hotel_id,
    h.hotel_name
ORDER BY no_show_stays DESC;

-- What is the average number of nights actually stayed?
SELECT
    ROUND(AVG(nights_stayed), 2) AS average_nights_stayed
FROM stays
WHERE nights_stayed IS NOT NULL;

-- How does actual stay duration compare with booked duration?
SELECT
    ROUND(AVG(b.nights_booked), 2) AS avg_nights_booked,
    ROUND(AVG(s.nights_stayed), 2) AS avg_nights_stayed
FROM bookings b
JOIN stays s
    ON b.booking_id = s.booking_id;

-- How do stay outcomes change over time?
SELECT
    YEAR(check_in_date) AS stay_year,
    MONTH(check_in_date) AS stay_month,
    status,
    COUNT(*) AS total_stays
FROM stays
GROUP BY
    YEAR(check_in_date),
    MONTH(check_in_date),
    status
ORDER BY
    stay_year,
    stay_month,
    status;
    
# 4.4 UNDERSTAND STAFF AND ROOM PERFORMANCE
-- Which staff members handle the highest number of stays?
SELECT
    st.staff_id,
    st.staff_name,
    st.department,
    COUNT(s.stay_id) AS stays_handled
FROM staff st
JOIN stays s
    ON st.staff_id = s.staff_id
GROUP BY
    st.staff_id,
    st.staff_name,
    st.department
ORDER BY stays_handled DESC;

-- Which staff members have the highest recorded ratings?
SELECT
    staff_id,
    staff_name,
    department,
    rating
FROM staff
ORDER BY rating DESC;

-- Compare staff workload and rating.
SELECT
    st.staff_id,
    st.staff_name,
    st.department,
    st.rating,
    COUNT(s.stay_id) AS stays_handled
FROM staff st
LEFT JOIN stays s
    ON st.staff_id = s.staff_id
GROUP BY
    st.staff_id,
    st.staff_name,
    st.department,
    st.rating
ORDER BY stays_handled DESC;

-- What are the stay outcomes handled by each staff member?
SELECT
    st.staff_name,
    s.status,
    COUNT(*) AS total_stays
FROM staff st
JOIN stays s
    ON st.staff_id = s.staff_id
GROUP BY
    st.staff_id,
    st.staff_name,
    s.status
ORDER BY
    st.staff_name,
    total_stays DESC;
    
-- Which room types are used most frequently?
SELECT
    r.room_type,
    COUNT(s.stay_id) AS total_stays
FROM rooms r
JOIN stays s
    ON r.room_id = s.room_id
GROUP BY r.room_type
ORDER BY total_stays DESC;

-- Are larger-capacity rooms associated with more service requests?
SELECT
    r.max_occupancy,
    COUNT(s.stay_id) AS total_stays,
    ROUND(AVG(s.service_requests), 2) AS avg_service_requests
FROM rooms r
JOIN stays s
    ON r.room_id = s.room_id
GROUP BY r.max_occupancy
ORDER BY r.max_occupancy;

# 4.5 IDENTIFY BOOKING AND STAY PROBLEMS

-- How many stays fall into each outcome category?
SELECT
    status,
    COUNT(*) AS total_stays
FROM stays
GROUP BY status
ORDER BY total_stays DESC;

-- Which bookings resulted in cancellations or no-shows?
SELECT
    b.booking_id,
    b.guest_id,
    b.hotel_id,
    b.booking_date,
    b.booking_channel,
    b.nights_booked,
    b.total_amount,
    s.status
FROM bookings b
JOIN stays s
    ON b.booking_id = s.booking_id
WHERE LOWER(s.status) IN ('cancelled', 'no-show')
ORDER BY b.booking_date;

-- What is the average service-request count by stay status?
SELECT
    status,
    COUNT(*) AS total_stays,
    ROUND(AVG(service_requests), 2) AS avg_service_requests
FROM stays
GROUP BY status
ORDER BY avg_service_requests DESC;

-- Which bookings have high service-request counts?
SELECT
    s.stay_id,
    s.booking_id,
    s.room_id,
    s.staff_id,
    s.status,
    s.service_requests
FROM stays s
WHERE s.service_requests >= 5
ORDER BY s.service_requests DESC;
