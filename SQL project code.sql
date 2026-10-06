-- 1.4 Analytical Thinking from the ER Diagram
-- 1. Management wants to find guests who have made multiple bookings. What information would you need to identify them?
-- 
-- 2. The Operations team wants to identify stays that were checked in but later marked as no-show or cancelled. Where would you find the information needed to investigate this?
-- 3. The Guest Experience team wants to compare Individual and Corporate guests based on their booking activity. Which tables and columns would you need?
-- 4. The Operations team wants to compare different booking channels based on how many nights guests stay and how much they spend. Which tables would you need to connect?
-- 5. The team wants to identify which staff members have handled stays and examine their recorded ratings. What information would you need?
-- 6. Operations wants to understand whether different room types are being booked for different stay durations. Which tables and columns would you need?
-- 7. Management wants to compare booking performance across different hotels. What information would you need from the database?
-- 8. The Operations team wants to investigate whether larger room capacities are associated with higher service requests during a stay. Which information would you need, and where would you find it?
-- 9. Management wants to understand whether stay outcomes differ across booking channels. What tables and information would you bring together?
-- 10. The Operations team wants to understand which guests have made bookings and how their stays are being handled. What information would you need to connect a guest with their bookings and stays?

-- Sprint 2: Database Setup
CREATE DATABASE Hotel_Reservation;
use Hotel_Reservation;

-- 1. HOTELS
CREATE TABLE hotels (
    hotel_id VARCHAR(20) PRIMARY KEY,
    hotel_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    star_rating INT NOT NULL,
    total_rooms INT NOT NULL,
    opened_date DATE 
);

select * from hotels;

-- 2. GUESTS
CREATE TABLE guests (
    guest_id VARCHAR(20) PRIMARY KEY,
    guest_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    guest_type VARCHAR(20) NOT NULL,
    preferred_room_type VARCHAR(20),
    loyalty_tier VARCHAR(20),
    account_since DATE 
);

select * from guests;


-- 3. STAFF
CREATE TABLE staff (
    staff_id VARCHAR(20) PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    hire_date VARCHAR(20) NOT NULL,
    rating DECIMAL(3, 2),
    department VARCHAR(30) NOT NULL,
    is_active VARCHAR(3) NOT NULL
);

select * from staff;


-- 4. ROOMS
CREATE TABLE rooms (
    room_id VARCHAR(20) PRIMARY KEY,
    hotel_id VARCHAR(20) NOT NULL,
    room_type VARCHAR(20) NOT NULL,
    floor_number INT NOT NULL,
    max_occupancy INT NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    is_active VARCHAR(3) NOT NULL,
    FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
);

select * from rooms;


-- 5. BOOKINGS
CREATE TABLE bookings (
    booking_id VARCHAR(20) PRIMARY KEY,
    guest_id VARCHAR(20) NOT NULL,
    hotel_id VARCHAR(20) NOT NULL,
    booking_date VARCHAR(20) NOT NULL,
    room_type_requested VARCHAR(20) NOT NULL,
    booking_channel VARCHAR(30) NOT NULL,
    nights_booked INT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
);

select * from bookings;


-- 6. STAYS
CREATE TABLE stays (
    stay_id VARCHAR(20) PRIMARY KEY,
    booking_id VARCHAR(20) NOT NULL,
    room_id VARCHAR(20) NOT NULL,
    staff_id VARCHAR(20) NOT NULL,
    check_in_date VARCHAR(20),
    check_out_date VARCHAR(20),
    status VARCHAR(20) NOT NULL,
    nights_stayed INT,
    service_requests INT,
    stay_duration_hrs INT,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

select * from stays;


-- Sprint 3: Basic Analysis / Data Exploration
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
ORDER BY room_type ASC;

-- 5. How many staff members are currently active?
SELECT COUNT(*) AS active_staff_count 
FROM staff
WHERE is_active = 'Yes';

-- 6. What are the different booking channels?
SELECT DISTINCT booking_channel 
FROM bookings
ORDER BY booking_channel ASC;

-- 7. What is the total booking amount across all bookings?
SELECT ROUND(SUM(total_amount), 2) AS grand_total_booking_amount 
FROM bookings;

-- 8. What is the average nights booked per booking?
SELECT ROUND(AVG(nights_booked), 2) AS avg_nights_per_booking 
FROM bookings;


