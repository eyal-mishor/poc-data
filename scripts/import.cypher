:param {
  // Define the file path root and the individual file names required for loading.
  // https://neo4j.com/docs/operations-manual/current/configuration/file-locations/
  file_path_root: 'https://raw.githubusercontent.com/eyal-mishor/poc-data/refs/heads/main/data/', // Change this to the folder your script can access the files at.
  file_0: 'agents.csv',
  file_1: 'datastores.csv',
  file_2: 'services.csv',
  file_3: 'service_tools.csv',
  file_4: 'datastore_tools.csv'
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
//
// Load nodes in batches, one node label at a time. Nodes will be created using a MERGE statement to ensure a node with the same label and ID property remains unique. Pre-existing nodes found by a MERGE statement will have their other properties set to the latest values encountered in a load file.
//
// NOTE: Any nodes with IDs in the 'idsToSkip' list parameter will not be loaded.
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


// RELATIONSHIP load
// -----------------
//
// Load relationships in batches, one relationship type at a time. Relationships are created using a MERGE statement, meaning only one relationship of a given type will ever be created between a pair of nodes.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Agent` { `Name`: row.`Agent` })
  MATCH (target: `Service` { `Name`: row.`Service` })
  MERGE (source)-[r: `TOOL`]->(target)
  SET r.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_4) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Agent` { `Name`: row.`Agent` })
  MATCH (target: `Datastore` { `Name`: row.`Datastore` })
  MERGE (source)-[r: `TOOL`]->(target)
  SET r.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;
