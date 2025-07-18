-- Create tables
CREATE TABLE public.users (  --overlapping /total comp.
                              "userid" SERIAL PRIMARY KEY,
                              "name" VARCHAR(50) NOT NULL,
                              "surname" VARCHAR(50) NOT NULL,
                              "email" VARCHAR(50) UNIQUE NOT NULL,
                              "password" VARCHAR(255) NOT NULL,
                              "phoneno" VARCHAR(30)
);

CREATE TABLE public.adminuser (
                                  "userid" INT PRIMARY KEY,
                                  "adminprivileges" VARCHAR(50),
                                  "permissionlevel" VARCHAR(5) NOT NULL,
                                  CONSTRAINT "unique_admin_userid" FOREIGN KEY ("userid") REFERENCES public.users("userid") ON DELETE CASCADE
) INHERITS("public"."users");

CREATE TABLE public.regularuser (
                                    "userid" INT PRIMARY KEY,
                                    "regularuserprivileges" VARCHAR(50),
                                    "membershiptype" VARCHAR(10),
                                    CONSTRAINT "regularuser_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid")
) INHERITS("public"."users");



CREATE TABLE public.locations (
                                  "locationid" SERIAL PRIMARY KEY,
                                  "name" VARCHAR(100) NOT NULL,
                                  "country" VARCHAR(50) NOT NULL,
                                  "city" VARCHAR(50) NOT NULL
);

CREATE TABLE public.cities (
                               "locationid" INT PRIMARY KEY,
                               "cityname" VARCHAR(100) NOT NULL,
                               "state" VARCHAR(100),
                               CONSTRAINT "city_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid")
) INHERITS("public"."locations");

CREATE TABLE public.countries (
                                  "locationid" INT PRIMARY KEY,
                                  "countryname" VARCHAR(100) NOT NULL,
                                  "continent" VARCHAR(50),
                                  CONSTRAINT "country_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid")
) INHERITS("public"."locations");

CREATE TABLE public.payments (
                                 "paymentid" SERIAL PRIMARY KEY,
                                 "paymentdate" DATE DEFAULT CURRENT_DATE,
                                 "totalamount" NUMERIC(10, 2) NOT NULL,
                                 "paymentmethod" VARCHAR(50) NOT NULL
);

CREATE TABLE public.reservations (
                                     "reservationid" SERIAL PRIMARY KEY,
                                     "reservationdate" DATE DEFAULT CURRENT_DATE,
                                     "userid" INT NOT NULL,
                                     "paymentid" INT NOT NULL,
                                     CONSTRAINT "reservation_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid") ON DELETE CASCADE,
                                     CONSTRAINT "reservation_paymentFK" FOREIGN KEY ("paymentid") REFERENCES public.payments("paymentid") ON DELETE SET NULL
);

CREATE TABLE public.transport (
                                  "transportid" SERIAL PRIMARY KEY,
                                  "type" VARCHAR(50) NOT NULL,
                                  "departuretime" TIMESTAMP NOT NULL,
                                  "reservationid" INT NOT NULL,
                                  CONSTRAINT "transport_reservationFK" FOREIGN KEY ("reservationid") REFERENCES public.reservations("reservationid") ON DELETE CASCADE
) INHERITS("public"."reservations");

CREATE TABLE public.accommodation (
                                      "accommodationid" SERIAL PRIMARY KEY,
                                      "type" VARCHAR(50) CHECK ("type" IN ('hotel', 'hostel')),
                                      "date" DATE NOT NULL,
                                      "reservationid" INT NOT NULL,
                                      CONSTRAINT "accommodation_reservationFK" FOREIGN KEY ("reservationid") REFERENCES public.reservations("reservationid") ON DELETE CASCADE
) INHERITS("public"."reservations");

CREATE TABLE public.hotels (
                               "hotelid" SERIAL PRIMARY KEY,
                               "hotelname" VARCHAR(100) NOT NULL,
                               "starrating" INT CHECK ("starrating" BETWEEN 1 AND 5),
                               "address" TEXT NOT NULL,
                               "accommodationid" INT NOT NULL,
                               CONSTRAINT "hotel_accommodationFK" FOREIGN KEY ("accommodationid") REFERENCES public.accommodation("accommodationid") ON DELETE CASCADE
) INHERITS("public"."accommodation");

CREATE TABLE public.hostels (
                                "hostelid" SERIAL PRIMARY KEY,
                                "hostelname" VARCHAR(100) NOT NULL,
                                "starrating" INT CHECK ("starrating" BETWEEN 1 AND 5),
                                "address" TEXT NOT NULL,
                                "accommodationid" INT NOT NULL,
                                CONSTRAINT "hostel_accommodationFK" FOREIGN KEY ("accommodationid") REFERENCES public.accommodation("accommodationid") ON DELETE CASCADE
) INHERITS("public"."accommodation");

CREATE TABLE public.transportcompany (
                                         "companyid" SERIAL PRIMARY KEY,
                                         "transportid" INT NOT NULL REFERENCES public.transport("transportid") ON DELETE CASCADE ON UPDATE CASCADE,
                                         "companyname" VARCHAR(100) NOT NULL,
                                         "contactinfo" TEXT,
                                         "address" TEXT
);

CREATE TABLE public.reviews (
                                "reviewid" SERIAL PRIMARY KEY,
                                "userid" INT NOT NULL,
                                "reviewdate" DATE DEFAULT CURRENT_DATE,
                                "reviewtext" TEXT NOT NULL,
                                "reviewtype" VARCHAR(50) NOT NULL,
                                CONSTRAINT "review_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid") ON DELETE CASCADE
);

CREATE TABLE public.reservationreview (
                                          "reviewid" INT NOT NULL,
                                          "reservationid" INT NOT NULL,
                                          CONSTRAINT "reservationreviewPK" PRIMARY KEY ("reviewid", "reservationid"),
                                          CONSTRAINT "reservationreview_reservationFK" FOREIGN KEY ("reservationid") REFERENCES public.reservations("reservationid") ON DELETE CASCADE,
                                          CONSTRAINT "reservationreview_reviewFK" FOREIGN KEY ("reviewid") REFERENCES public.reviews("reviewid") ON DELETE CASCADE
) INHERITS("public"."reviews");

CREATE TABLE public.locationreview (
                                       "locationreviewid" SERIAL PRIMARY KEY,
                                       "reviewid" INT NOT NULL,
                                       "locationid" INT NOT NULL,
                                       CONSTRAINT "locationreview_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid") ON DELETE CASCADE,
                                       CONSTRAINT "locationreview_reviewFK" FOREIGN KEY ("reviewid") REFERENCES public.reviews("reviewid") ON DELETE CASCADE
) INHERITS("public"."reviews");

CREATE TABLE public.trips (
                              "tripid" SERIAL PRIMARY KEY,
                              "userid" INT NOT NULL,
                              "title" VARCHAR(100) NOT NULL,
                              "startdate" DATE NOT NULL,
                              "enddate" DATE NOT NULL,
                              "totalcost" DECIMAL(10, 2) NOT NULL,
                              "participantcount" INT CHECK ("participantcount" >= 1),
                              CONSTRAINT "trip_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid") ON DELETE CASCADE
);

CREATE TABLE public.activities (
                                   "activityid" SERIAL PRIMARY KEY,
                                   "activityname" VARCHAR(100) NOT NULL,
                                   "description" TEXT
);

CREATE TABLE public.tripactivities (
                                       "tripid" INT NOT NULL,
                                       "activityid" SERIAL,
                                       "cost" DECIMAL(10, 2) NOT NULL,
                                       "activitydate" DATE NOT NULL,
                                       CONSTRAINT "tripactivityPK" PRIMARY KEY ("tripid", "activityid"),
                                       CONSTRAINT "tripactivity_tripFK" FOREIGN KEY ("tripid") REFERENCES public.trips("tripid") ON DELETE CASCADE,
                                       CONSTRAINT "tripactivity_activityFK" FOREIGN KEY ("activityid") REFERENCES public.activities("activityid") ON DELETE CASCADE
);

CREATE TABLE public.triplocations (
                                      "tripid" INT NOT NULL,
                                      "locationid" INT NOT NULL,
                                      "type" VARCHAR(50) NOT NULL,
                                      "description" TEXT,
                                      CONSTRAINT "triplocationPK" PRIMARY KEY ("tripid", "locationid"),
                                      CONSTRAINT "triplocation_tripFK" FOREIGN KEY ("tripid") REFERENCES public.trips("tripid") ON DELETE CASCADE,
                                      CONSTRAINT "triplocation_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid") ON DELETE CASCADE
);
CREATE OR REPLACE FUNCTION add_admin_user(
    p_userid INT,
    p_name VARCHAR(50),
    p_surname VARCHAR(50),
    p_email VARCHAR(50),
    p_password VARCHAR(255),
    p_phoneno VARCHAR(30),
    p_adminprivileges VARCHAR(50),
    p_permissionlevel VARCHAR(5)
)
    RETURNS VOID AS $$
BEGIN
    -- Check if userid exists in the users table
    IF EXISTS (SELECT 1 FROM public.users WHERE userid = p_userid) THEN
        RAISE EXCEPTION 'Cannot add admin user because the UserID % already exists.', p_userid;
    END IF;

    -- Insert into the adminuser table
    INSERT INTO public.adminuser (userid, name, surname, email, password, phoneno, adminprivileges, permissionlevel)
    VALUES (
               p_userid,
               p_name,
               p_surname,
               p_email,
               p_password,
               p_phoneno,
               p_adminprivileges,
               p_permissionlevel
           );

    -- Check for PL/pgSQL language
    PERFORM * FROM pg_language WHERE lanname = 'plpgsql';

    -- Optionally, you can raise a notice for success
    RAISE NOTICE 'Admin user % % added successfully.', p_name, p_surname;
END;
$$ LANGUAGE plpgsql;



SELECT * FROM public.users WHERE userid = 101;
-----------------------------------------------------------FONK1 çalıştır
-- Foreign key kısıtlamasını geçici olarak kaldır
ALTER TABLE public.adminuser DISABLE TRIGGER ALL;

------------------> 


SELECT * FROM public.adminuser WHERE userid = ;

---------->  


SELECT delete_admin_user(); ----------------FONK2 Çalıştır


-- Foreign key kısıtlamasını tekrar etkinleştir
ALTER TABLE public.adminuser ENABLE TRIGGER ALL;


-- Function to delete admin user
CREATE OR REPLACE FUNCTION delete_admin_user(p_userid INT)
    RETURNS VOID AS $$
BEGIN
    -- Delete from the adminuser table using the provided userid
    DELETE FROM public.adminuser WHERE userid = p_userid;

    -- Optionally, raise a notice
    RAISE NOTICE 'Admin user with userid % deleted successfully.', p_userid;
END;
$$ LANGUAGE plpgsql;

-- Function to update admin user
CREATE OR REPLACE FUNCTION update_admin_user(
    p_userid INT,
    p_name VARCHAR(50),
    p_surname VARCHAR(50),
    p_email VARCHAR(50),
    p_password VARCHAR(255),
    p_phoneno VARCHAR(30),
    p_adminprivileges VARCHAR(50),
    p_permissionlevel VARCHAR(5)
)
    RETURNS VOID AS $$
BEGIN
    -- Update the adminuser table based on the provided userid
    UPDATE public.adminuser
    SET
        name = p_name,
        surname = p_surname,
        email = p_email,
        password = p_password,
        phoneno = p_phoneno,
        adminprivileges = p_adminprivileges,
        permissionlevel = p_permissionlevel
    WHERE userid = p_userid;

    -- Optionally, raise a notice
    RAISE NOTICE 'Admin user with userid % updated successfully.', p_userid;
END;
$$ LANGUAGE plpgsql;


-- Function to update user phone number
CREATE OR REPLACE FUNCTION update_user_phoneno(
    p_userid INT,
    p_new_phoneno VARCHAR(30)
)
    RETURNS VOID AS $$
BEGIN
    -- Update the user's phone number
    UPDATE public.users
    SET phoneno = p_new_phoneno
    WHERE userid = p_userid;

    -- Optionally, raise a notice
    RAISE NOTICE 'Phone number for user with userid % updated successfully.', p_userid;
END;
$$ LANGUAGE plpgsql;

-- Function to transfer reservation from one user to another
CREATE OR REPLACE FUNCTION transfer_reservation(
    p_old_userid INT,
    p_new_userid INT,
    p_reservationid INT
)
    RETURNS VOID AS $$
BEGIN
    -- Check if the old user has the reservation
    IF NOT EXISTS (SELECT 1 FROM public.reservations WHERE userid = p_old_userid AND reservationid = p_reservationid) THEN
        RAISE EXCEPTION 'Reservation with id % does not belong to user with id %.', p_reservationid, p_old_userid;
    END IF;

    -- Update the reservation to be under the new user's name
    UPDATE public.reservations
    SET userid = p_new_userid
    WHERE reservationid = p_reservationid;

    -- Optionally, raise a notice
    RAISE NOTICE 'Reservation with id % transferred from user % to user %.', p_reservationid, p_old_userid, p_new_userid;
END;
$$ LANGUAGE plpgsql;


-- Trigger function to cascade delete related reservations
CREATE OR REPLACE FUNCTION cascade_delete_reservation()
    RETURNS TRIGGER AS $$
BEGIN
    -- Cascade delete related transport and accommodation records
    DELETE FROM public.transport WHERE reservationid = OLD.reservationid;
    DELETE FROM public.accommodation WHERE reservationid = OLD.reservationid;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

----------------
CREATE OR REPLACE FUNCTION log_admin_permission_change()
    RETURNS TRIGGER AS $$
BEGIN
    -- Log admin permission changes in a log table
    INSERT INTO public.users_log (userid, action, action_date)
    VALUES (NEW.userid, 'Admin Permissions Updated', CURRENT_TIMESTAMP);
    
    -- Return the new record so that the update happens
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TABLE public.users_log (
    log_id SERIAL PRIMARY KEY,
    userid INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    action_date TIMESTAMP NOT NULL,
    FOREIGN KEY (userid) REFERENCES public.users(userid) ON DELETE CASCADE
);


CREATE TRIGGER admin_permission_change_trigger
    AFTER UPDATE ON public.users
    FOR EACH ROW
    WHEN (OLD.name IS DISTINCT FROM NEW.name OR OLD.surname IS DISTINCT FROM NEW.surname)
    EXECUTE FUNCTION log_admin_permission_change();


----------------
-- Trigger function to delete related reviews when a user is deleted
CREATE OR REPLACE FUNCTION cascade_delete_reviews()
    RETURNS TRIGGER AS $$
BEGIN
    -- Delete reviews related to the user
    DELETE FROM public.reviews WHERE userid = OLD.userid;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger definition for the 'users' table
CREATE TRIGGER trigger_cascade_delete_reviews
    AFTER DELETE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION cascade_delete_reviews();


--------------

-- Trigger function to update transport and accommodation dates when reservation date changes
CREATE OR REPLACE FUNCTION update_related_transport_accommodation()
    RETURNS TRIGGER AS $$
BEGIN
    -- Update transport date related to the reservation
    UPDATE public.transport
    SET departuretime = NEW.reservationdate
    WHERE reservationid = NEW.reservationid;

    -- Update accommodation date related to the reservation
    UPDATE public.accommodation
    SET date = NEW.reservationdate
    WHERE reservationid = NEW.reservationid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger definition for the 'reservations' table
CREATE TRIGGER trigger_update_related_transport_accommodation
    AFTER UPDATE OF reservationdate ON public.reservations
    FOR EACH ROW
    WHEN (OLD.reservationdate IS DISTINCT FROM NEW.reservationdate)
    EXECUTE FUNCTION update_related_transport_accommodation();

CREATE OR REPLACE FUNCTION set_default_name()
RETURNS TRIGGER AS $$
BEGIN
    -- Eğer isim verilmemişse, varsayılan bir isim belirle
    IF NEW.name IS NULL THEN
        NEW.name := 'Default Name';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_name_trigger
BEFORE INSERT
ON public.adminuser
FOR EACH ROW
EXECUTE FUNCTION set_default_name();



INSERT INTO public.users ("userid", "name", "surname", "email", "password", "phoneno")
VALUES (6, 'Alex', 'Morgan', 'amorgan7@abc.com', 'Xy7!pZ3b', '+1 (312) 485-2938');

INSERT INTO public.users ("userid", "name", "surname", "email", "password", "phoneno")
VALUES (2, 'Sam', 'Tanner', 'stanner2@xyz.org', 'Qw3@RtY9', '+1 (561) 307-8234');

INSERT INTO public.users ("userid", "name", "surname", "email", "password", "phoneno")
VALUES (3, 'Jordan', 'Lee', 'jlee8@company.net', 'Pq2@Jh8o', '+1 (415) 652-9726');

INSERT INTO public.users ("userid", "name", "surname", "email", "password", "phoneno")
VALUES (4, 'Chris', 'Henderson', 'chenderson5@demo.edu', 'Lx4!Fg7v', '+1 (555) 107-4829');

INSERT INTO public.users ("userid", "name", "surname", "email", "password", "phoneno")
VALUES (7, 'Taylor', 'Davis', 'tdavis1@service.com', 'Bf9!TuX3', '+1 (408) 305-2013');
