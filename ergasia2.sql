#1 /*Βρείτε τους αριθμούς των αεροσκαφών της κατασκευάστριας εταιρείας Airbus που πετούν για την αεροπορική εταιρεία Lufthansa*/

SELECT DISTINCT airplanes.number
FROM airlines, airplanes, airlines_has_airplanes AS aha
WHERE aha.airlines_id = airlines.id AND aha.airplanes_id = airplanes.id
	AND airlines.name = "Lufthansa" AND airplanes.manufacturer = "Airbus";

#2 /*Βρείτε τα ονόματα των αεροπορικών εταιρειών με δρομολόγιο από Athens προς Prague.*/

SELECT airlines.name
FROM airlines, routes, airports AS a1, airports AS a2
WHERE routes.airlines_id = airlines.id AND routes.source_id = a1.id AND routes.destination_id = a2.id
	AND a1.city = "Athens" AND a2.city = "Prague";
    
#3 /*Πόσοι επιβάτες ταξίδεψαν την ημερομηνία 2012-02-19 με πτήσεις της Aegean Airlines;*/

SELECT COUNT(DISTINCT fhp.passengers_id) AS number
FROM flights, airlines, routes, flights_has_passengers AS fhp
WHERE routes.id = flights.routes_id AND routes.airlines_id = airlines.id AND fhp.flights_id = flights.id
	AND airlines.name = "Aegean Airlines" AND flights.date = "2012-02-19";

#4 /*Ελέγξτε αν υπήρξε πτήση της “Olympic Airways” την ημερομηνία 2014-12-12 από Athens El. Venizelos σε London Gatwick.
(Το ερώτημα θα πρέπει να επιστρέφει ως απάντηση μια σχέση με μια πλειάδα και μια στήλη με τιμή yes ή no). 
Απαγορεύεται η χρήση Flow Control Operators (δηλαδή, if, case, κλπ.).*/

SELECT "yes" AS result
WHERE EXISTS(SELECT * FROM flights, routes, airlines, airports AS a1, airports AS a2
				WHERE flights.routes_id = routes.id AND routes.airlines_id = airlines.id AND
					a1.id = routes.source_id AND a2.id = routes.destination_id AND
						airlines.name = "Olympic Airways" AND flights.date = "2014-12-12" AND
							a1.name = "Athens El. Venizelos" AND a2.name = "London Gatwick")
UNION
SELECT "no" AS result
WHERE NOT EXISTS(SELECT * FROM flights, routes, airlines, airports AS a1, airports AS a2
				WHERE flights.routes_id = routes.id AND routes.airlines_id = airlines.id AND
					a1.id = routes.source_id AND a2.id = routes.destination_id AND
						airlines.name = "Olympic Airways" AND flights.date = "2014-12-12" AND
							a1.name = "Athens El. Venizelos" AND a2.name = "London Gatwick");

#5 /*Ποια είναι η μέση ηλικίας των επισκεπτών της πόλης Berlin;*/

SELECT AVG(2022 - passengers.year_of_birth) AS age
FROM flights, passengers, flights_has_passengers AS fhp, routes, airports
WHERE fhp.flights_id = flights.id AND fhp.passengers_id = passengers.id AND flights.routes_id = routes.id
	AND routes.destination_id = airports.id AND airports.city = "Berlin";

#6 /*Βρείτε τα ονόματα και τα επίθετα των επιβατών που έχουν κάνει όλα τα ταξίδια τους με το ίδιο αεροπλάνο.*/

SELECT passengers.name, passengers.surname
FROM flights, passengers, flights_has_passengers AS fhp
WHERE fhp.flights_id = flights.id AND fhp.passengers_id = passengers.id
GROUP BY passengers.id
HAVING COUNT(DISTINCT flights.airplanes_id) = 1;

#7 /*Βρείτε την πόλη άφιξης και προορισμού σε πτήσεις που έχουν πραγματοποιηθεί ανάμεσα στις ημερομηνίες 2010-03-01 και 2014-07-17 εφόσον οι πτήσεις αυτές 
είχαν πάνω από 5 επιβάτες.*/

SELECT a1.city AS "#from" , a2.city AS "to"
FROM flights, routes, airports AS a1, airports AS a2, flights_has_passengers AS fhp
WHERE fhp.flights_id = flights.id AND flights.routes_id = routes.id AND
	a1.id = routes.source_id AND a2.id = routes.destination_id AND
		flights.date >= "2010-03-01" AND flights.date <= "2014-07-17"
GROUP BY fhp.flights_id
HAVING COUNT(fhp.passengers_id) > 5;

#8 /*Για κάθε αεροπορική εταιρεία που έχει ακριβώς 4 αεροσκάφη, βρείτε το όνομα και τον κωδικό της καθώς και τον αριθμό των δρομολογίων που διαθέτει.*/

SELECT airlines.name, airlines.code, COUNT(DISTINCT routes.id)
FROM airlines, airplanes, airlines_has_airplanes AS aha, routes
WHERE aha.airlines_id = airlines.id AND aha.airplanes_id = airplanes.id AND routes.airlines_id = airlines.id
GROUP BY aha.airlines_id
HAVING COUNT(DISTINCT aha.airplanes_id) = 4;

#9 /*Βρείτε τα ονοματεπώνυμα των επιβατών που έχουν πετάξει με όλες τις αεροπορικές εταιρείες που είναι ενεργές*/

SELECT passengers.name, passengers.surname
FROM passengers
WHERE NOT EXISTS(SELECT airlines.id FROM airlines
					WHERE airlines.active = "Y" AND NOT EXISTS(SELECT passengers.id FROM flights, flights_has_passengers AS fhp, routes
																	WHERE fhp.flights_id = flights.id AND fhp.passengers_id = passengers.id
                                                                    AND flights.routes_id = routes.id AND routes.airlines_id = airlines.id));

#10 /*Βρείτε τα ονόματα και τα επίθετα των επιβατών που έχουν πετάξει μόνο με την 
εταιρεία “Aegean Airlines” και αυτά που έχουν κάνει πάνω από ένα ταξίδι στο 
χρονικό διάστημα 2011-01-02 έως 2013-12-31.*/

(
SELECT passengers.name, passengers.surname
FROM passengers
WHERE EXISTS(SELECT * FROM flights, flights_has_passengers AS fhp, routes, airlines
				WHERE fhp.flights_id = flights.id AND fhp.passengers_id = passengers.id AND
				flights.routes_id = routes.id AND routes.airlines_id = airlines.id AND
				airlines.name = "Aegean Airlines")
AND NOT EXISTS(SELECT * FROM flights, flights_has_passengers AS fhp, routes, airlines
				WHERE fhp.flights_id = flights.id AND fhp.passengers_id = passengers.id AND
				flights.routes_id = routes.id AND routes.airlines_id = airlines.id AND
				airlines.name != "Aegean Airlines")
)
UNION
(
SELECT passengers.name, passengers.surname
FROM flights, passengers, flights_has_passengers AS fhp
WHERE fhp.flights_id = flights.id AND fhp.passengers_id = passengers.id
	AND flights.date >= "2011-01-02" AND flights.date <= "2013-12-31"
GROUP BY passengers.id
HAVING COUNT(flights.id) > 1
);

##### for checking #####
SELECT routes.id, airlines.name
FROM passengers, flights, flights_has_passengers AS fhp, routes, airlines
WHERE fhp.passengers_id = passengers.id AND fhp.flights_id = flights.id AND flights.routes_id = routes.id
	AND routes.airlines_id = airlines.id AND passengers.name = "Lerkimen" AND passengers.surname = "Boiphtan";
