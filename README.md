README.md

Demand generation (MATLAB scripts)
- conversion of the SimMobility MidTerm demand (activity-based schedules) to AMOD trips 

Generating the demand using a new activity-schedule file from SimMobilityMT.

Every person performs activities over the day. Each person has a unique id and performs tours. Tour is always from home to home. Tour is to perform a Primary Activity and (optional) intermediate activities. Tour consists of trips to activities.

Header of each column in the activity-schedule file:

-   person_id character varying - unique id for each person
-   tour_no integer - describes if it is 1 or 2 or 3…tour in the day
-   tour_type character varying - purpose of the trip (in therms of the Primary Activity): work/shop/education/other
-   stop_no integer - stop to perform activities
-   stop_type character varying - what is the current activity the person performs
-   stop_location integer, // node id of the trip destination
-   stop_zone integer, // TAZ zone
-   stop_mode character varying, //trip mode
-   primary_stop boolean,
-   arrival_time numeric, // START TIME OF THE ACTIVITY
-   departure_time numeric, // END TIME OF THE ACTIVITY
-   prev_stop_location integer, //trip origin node
-   prev_stop_zone integer,
-   prev_stop_departure_time numeric, //trip start time
-   pid bigserial NOT NULL

Time within the activity-based schedule
day starts at 3am and finishes at 26hr
the time for trips is in 30 minutes intervals and coded as following:
- 3.25 -> trips between 3-3:30am
- 3.75 -> trips between 3:30-4am etc up to 26.75 for the trips between 2:30-3am