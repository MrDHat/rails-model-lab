Patients keep ending up with two records, and the app's sign-in can't find
people it should. The app sends phone numbers however the patient typed them
("(11) 98765-4321", "11 98765 4321", "+55 11 98765-4321"), and reception types
them their own way on the staff pages, so the same number is stored several
ways.

Store every patient's phone number as E.164 ("+5511987654321") however it was
entered, and make `GET /api/patients/lookup?phone=...` find the patient
whichever way the number is written. A number that already belongs to another
patient is refused with "Phone has already been taken".
