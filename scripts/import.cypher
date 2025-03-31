:param {
  // Define the file path root and the individual file names required for loading.
  // https://neo4j.com/docs/operations-manual/current/configuration/file-locations/
  file_path_root: 'https://raw.githubusercontent.com/eyal-mishor/poc-data/refs/heads/main/data/', // Change this to the folder your script can access the files at.
  file_0: 'agents.csv',
  file_1: 'datastores.csv',
  file_2: 'services.csv',
  file_3: 'service_tools.csv',
  file_4: 'datastore_tools.csv',
  file_5: 'networks.csv',
  file_6: 'network_services.csv'
};

// CONSTRAINT creation
// -------------------
//
// Create node uniqueness constraints, ensuring no duplicates for the given node label and ID property exist in the database. This also ensures no duplicates are introduced in future.
//
// NOTE: The following constraint creation syntax is generated based on the current connected database version 5.27.0.
CREATE CONSTRAINT `Name_Agent_uniq` IF NOT EXISTS
FOR (n: `Agent`)
REQUIRE (n.`Name`) IS UNIQUE;
CREATE CONSTRAINT `Name_Datastore_uniq` IF NOT EXISTS
FOR (n: `Datastore`)
REQUIRE (n.`Name`) IS UNIQUE;
CREATE CONSTRAINT `Name_Service_uniq` IF NOT EXISTS
FOR (n: `Service`)
REQUIRE (n.`Name`) IS UNIQUE;

:param {
  idsToSkip: []
};

// NODE load
// ---------
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`Name` IN $idsToSkip AND NOT row.`Name` IS NULL
CALL {
  WITH row
  MERGE (n: `Agent` { `Name`: row.`Name` })
  SET n.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`Name` IN $idsToSkip AND NOT row.`Name` IS NULL
CALL {
  WITH row
  MERGE (n: `Datastore` { `Name`: row.`Name` })
  SET n.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.`Name` IN $idsToSkip AND NOT row.`Name` IS NULL
CALL {
  WITH row
  MERGE (n: `Service` { `Name`: row.`Name` })
  SET n.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_5) AS row
WITH row
WHERE NOT row.`Name` IN $idsToSkip AND NOT row.`Name` IS NULL
CALL {
  WITH row
  MERGE (n: `Network` { `Name`: row.`Name` })
  SET n.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

// TOOL RELATIONSHIP
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Agent` { `Name`: row.`Agent` })
  MATCH (target: `Service` { `Name`: row.`Service` })
  CREATE (source)-[r: `TOOL`]->(target)
  SET r.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_4) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Agent` { `Name`: row.`Agent` })
  MATCH (target: `Datastore` { `Name`: row.`Datastore` })
  CREATE (source)-[r: `TOOL`]->(target)
  SET r.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

// ACCESS RELATIONSHIP
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Network` { `Name`: row.`Network` })
  MATCH (target: `Service` { `Name`: row.`Service` })
  CREATE (source)-[r: `ACCESS`]->(target)
  SET r.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;