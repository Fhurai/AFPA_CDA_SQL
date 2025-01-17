use CasHorse
go
CREATE TABLE races(
   idRace INT IDENTITY,
   labelRace VARCHAR(20) NOT NULL,
   PRIMARY KEY(idRace)
);

CREATE TABLE colors(
   idColor INT IDENTITY,
   labelColor VARCHAR(20),
   PRIMARY KEY(idColor)
);

CREATE TABLE Genders(
   idGender INT IDENTITY,
   LabelGender VARCHAR(20) NOT NULL,
   PRIMARY KEY(idGender)
);

CREATE TABLE locations(
   idLocation INT IDENTITY,
   numStreetLocation VARCHAR(10) NOT NULL,
   nameStreetLocation VARCHAR(30),
   postalCodeLocation CHAR(5),
   cityLocation VARCHAR(30),
   PRIMARY KEY(idLocation)
);

CREATE TABLE people(
   idPeople INT IDENTITY,
   lastNamePeople VARCHAR(20) NOT NULL,
   firstNamePeople VARCHAR(20),
   idAddress INT NOT NULL,
   PRIMARY KEY(idPeople),
   FOREIGN KEY(idAddress) REFERENCES locations(idLocation)
);

CREATE TABLE companies(
   idCompany INT IDENTITY,
   nameCompany VARCHAR(20),
   PRIMARY KEY(idCompany)
);

CREATE TABLE fields(
   idField INT IDENTITY,
   labelField VARCHAR(20) NOT NULL,
   PRIMARY KEY(idField)
);

CREATE TABLE reunions(
   idReunions INT IDENTITY,
   dateHourReunion DATETIME2 NOT NULL,
   idField INT NOT NULL,
   PRIMARY KEY(idReunions),
   FOREIGN KEY(idField) REFERENCES fields(idField)
);

CREATE TABLE runningTypes(
   idType INT IDENTITY,
   labelType VARCHAR(20),
   PRIMARY KEY(idType)
);

CREATE TABLE types_vaccinations(
   idVaccination INT IDENTITY,
   labelTypeVaccination VARCHAR(20) NOT NULL,
   PRIMARY KEY(idVaccination)
);

CREATE TABLE owners(
   idOwner INT IDENTITY,
   dateOwner DATE NOT NULL,
   idPeople INT,
   idCompany INT,
   PRIMARY KEY(idOwner),
   FOREIGN KEY(idPeople) REFERENCES people(idPeople),
   FOREIGN KEY(idCompany) REFERENCES companies(idCompany)
);

CREATE TABLE Run(
   idRun INT IDENTITY,
   runningCount INT NOT NULL,
   distance INT,
   winnerPrize INT,
   dateBegin DATE,
   nameTask VARCHAR(20),
   idReunions INT NOT NULL,
   idType INT NOT NULL,
   PRIMARY KEY(idRun),
   FOREIGN KEY(idReunions) REFERENCES reunions(idReunions),
   FOREIGN KEY(idType) REFERENCES runningTypes(idType)
);

CREATE TABLE horses(
   idHorse INT IDENTITY,
   birthdayDate DATE NOT NULL,
   nameHorse VARCHAR(30),
   idOwner INT NOT NULL,
   idPere INT,
   idBirthLocation INT NOT NULL,
   idGender INT NOT NULL,
   idColor INT NOT NULL,
   idRace INT NOT NULL,
   idMere INT,
   PRIMARY KEY(idHorse),
   FOREIGN KEY(idOwner) REFERENCES owners(idOwner),
   FOREIGN KEY(idPere) REFERENCES horses(idHorse),
   FOREIGN KEY(idBirthLocation) REFERENCES locations(idLocation),
   FOREIGN KEY(idGender) REFERENCES Genders(idGender),
   FOREIGN KEY(idColor) REFERENCES colors(idColor),
   FOREIGN KEY(idRace) REFERENCES races(idRace),
   FOREIGN KEY(idMere) REFERENCES horses(idHorse)
);

CREATE TABLE trainings(
   idTraining INT IDENTITY,
   Date_entrainement VARCHAR(50),
   idHorse INT NOT NULL,
   idPeople INT NOT NULL,
   PRIMARY KEY(idTraining),
   FOREIGN KEY(idHorse) REFERENCES horses(idHorse),
   FOREIGN KEY(idPeople) REFERENCES people(idPeople)
);

CREATE TABLE vaccinations(
   Identifiant_Vaccination INT IDENTITY,
   dateVaccination DATE,
   idVaccination INT NOT NULL,
   idVeterinaire INT NOT NULL,
   idHorse INT NOT NULL,
   PRIMARY KEY(Identifiant_Vaccination),
   FOREIGN KEY(idVaccination) REFERENCES types_vaccinations(idVaccination),
   FOREIGN KEY(idVeterinaire) REFERENCES people(idPeople),
   FOREIGN KEY(idHorse) REFERENCES horses(idHorse)
);

CREATE TABLE participants(
   idParticipant INT IDENTITY,
   startingBlock INT NOT NULL,
   earnings DECIMAL(8,2) NOT NULL,
   handicap VARCHAR(20) NOT NULL,
   ownerColors VARCHAR(20),
   idJockey INT NOT NULL,
   idHorse INT NOT NULL,
   PRIMARY KEY(idParticipant),
   FOREIGN KEY(idJockey) REFERENCES people(idPeople),
   FOREIGN KEY(idHorse) REFERENCES horses(idHorse)
);

CREATE TABLE regrouper(
   idPeople INT,
   idCompany INT,
   PRIMARY KEY(idPeople, idCompany),
   FOREIGN KEY(idPeople) REFERENCES people(idPeople),
   FOREIGN KEY(idCompany) REFERENCES companies(idCompany)
);

CREATE TABLE Participer(
   idRun INT,
   idParticipant INT,
   PRIMARY KEY(idRun, idParticipant),
   FOREIGN KEY(idRun) REFERENCES Run(idRun),
   FOREIGN KEY(idParticipant) REFERENCES participants(idParticipant)
);
